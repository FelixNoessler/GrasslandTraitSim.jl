function input_nutrients!(; container)
    @unpack nutrients = container.patch_variables
    @unpack totalN = container.site
    @unpack included = container.simp
    @unpack N_max = container.p

    if included.nutrient_growth_reduction
        @. nutrients = totalN / N_max
    end

    return nothing
end

"""
Calculate differences of all state variables for one day.

## Biomass change during one day

```math
B_{t+1xys} = B_{txys} + G_{act, txys} - S_{txys} - M_{txys}
```

- ``B_{txys}`` biomass of species ``s`` at time ``t`` and patch ``xy`` [kg ha⁻¹]
    - output is stored in `output.biomass```_{txys}``, current state in
        `u.u_biomass```_{xys}``, change of biomass in `u.du_biomass```_{xys}``
- ``G_{act, txys}`` actual growth of species ``s`` at time ``t`` and patch ``xy`` [kg ha⁻¹]
    - `calc.act_growth```_{s}`` is then directly added to `u.du_biomass` for each patch
- ``S_{txys}`` senescence of species ``s`` at patch ``xy`` [kg ha⁻¹]
    - `calc.senescence```_{s}`` is then directly added to `u.du_biomass` for each patch
- ``M_{txys}`` defoliation due to management of species ``s`` at time ``t`` at patch
    ``xy`` [kg ha⁻¹]
    - `calc.defoliation```_{s}`` is then directly added to `u.du_biomass` for each patch

> **Note:** for an overview of all biomass processes, see [Biomass dynamics](@ref)

## Soil water change during one day

```math
W_{t+1xy} = W_{txy} + P_{txy} - AET_{txy} - R_{txy}
```

- ``W_{txy}``: soil water content at time ``t`` at patch ``xy`` [mm]
    - output is stored in `output.water```_{txy}``, current state in `u.u_water```_{xy}``,
        change of water in `u.du_water```_{xy}``
- ``P_{txy}``: precipitation at time ``t`` at patch ``xy`` [mm]
    - `input.precipitation```_{txy}``
- ``AET_{txy}``: actual evapotranspiration at time ``t`` at patch ``xy`` [mm]
    - `AET` in [`change_water_reserve`](@ref)
- ``R_{txy}``: surface run-off and drainage of water from the soil at time ``t``
    at patch ``xy`` [mm]
    - `drain` in [`change_water_reserve`](@ref)


> **Note:** for more details see [`change_water_reserve`](@ref)

## Main procedure (in the following order)

if npatches > 1

- [clonal growth](@ref clonalgrowth!) at day of the year = 250

loop over patches:

- set very low or negative biomass (< 1e-30 kg ha⁻¹) to zero
- defoliation ([mowing](@ref mowing!), [grazing](@ref grazing!))
- [growth](@ref growth!)
- [senescence](@ref senescence!)
- [soil water dynamics](@ref change_water_reserve)
"""
function one_day!(; t, container)
    @unpack input, output, traits = container
    @unpack npatches, patch_xdim, patch_ydim, nspecies, included = container.simp
    @unpack u_biomass, u_above_biomass, u_below_biomass, u_water, u_height,
            du_biomass, du_above_biomass, du_below_biomass, du_water, du_height = container.u
    @unpack WHC, PWP, nutrients = container.patch_variables
    @unpack com, act_growth, senescence, mown, grazed, defoliation,
        light_competition, Nutred, Waterred, root_invest, allocation_above, above_proportion,
        height_gain, height_loss_mowing, height_loss_grazing = container.calc

    ## -------- loop over patches
    for x in Base.OneTo(patch_xdim)
        for y in Base.OneTo(patch_ydim)

            # --------------------- biomass dynamics
            patch_biomass = @view u_biomass[x, y, :]
            patch_above_biomass = @view u_above_biomass[x, y, :]
            patch_below_biomass = @view u_below_biomass[x, y, :]
            patch_height = @view u_height[x, y, :]

            for i in eachindex(patch_biomass)
                if patch_biomass[i] < 1e-30u"kg / ha" && !iszero(patch_biomass[i])
                    patch_biomass[i] = 0.0u"kg / ha"
                end

                if patch_above_biomass[i] < 1e-30u"kg / ha" && !iszero(patch_above_biomass[i])
                    patch_above_biomass[i] = 0.0u"kg / ha"
                end

                if patch_below_biomass[i] < 1e-30u"kg / ha" && !iszero(patch_below_biomass[i])
                    patch_below_biomass[i] = 0.0u"kg / ha"
                end

                if patch_height[i] < 1e-30u"m" && !iszero(patch_height[i])
                    patch_height[i] = 0.0u"m"
                end
            end

            for s in 1:nspecies
                if iszero(patch_biomass[s])
                    above_proportion[s] = 0.0
                else
                    above_proportion[s] = patch_above_biomass[s] / patch_biomass[s]
                end
            end
            @. allocation_above = 1 - above_proportion / traits.abp

            defoliation .= 0.0u"kg / ha"
            act_growth .= 0.0u"kg / ha"
            senescence .= 0.0u"kg / ha"
            grazed .= 0.0u"kg / ha"
            mown .= 0.0u"kg / ha"

            if !iszero(sum(patch_biomass)) && !iszero(sum(patch_above_biomass))
                # ------------------------------------------ growth
                growth!(; t, container,
                    above_biomass = patch_above_biomass,
                    total_biomass = patch_biomass,
                    actual_height = patch_height,
                    W = u_water[x, y],
                    nutrients = nutrients[x, y],
                    WHC = WHC[x, y],
                    PWP = PWP[x, y])

                # ------------------------------------------ senescence
                senescence!(; container,
                    ST = input.temperature_sum[t],
                    total_biomass = patch_biomass)

                # ------------------------------------------ mowing
                if included.mowing
                    mowing_height = if input.CUT_mowing isa Vector
                        input.CUT_mowing[t]
                    else
                        input.CUT_mowing[t, x, y]
                    end

                    if !isnan(mowing_height)
                        mowing!(; container, mowing_height,
                                above_biomass = patch_above_biomass,
                                actual_height = patch_height)
                    end
                end

                # ------------------------------------------ grazing
                if included.grazing
                    LD = if input.LD_grazing isa Vector
                        input.LD_grazing[t]
                    else
                        input.LD_grazing[t, x, y]
                    end

                    if !isnan(LD)
                        grazing!(; container, LD, above_biomass = patch_above_biomass,
                                   actual_height = patch_height)
                    end
                end
            end

            # -------------- net growth
            @. du_biomass[x, y, :] = act_growth - senescence - defoliation
            @. du_above_biomass[x, y, :] = allocation_above * act_growth - (1-allocation_above) * senescence - defoliation
            @. du_below_biomass[x, y, :] = (1-allocation_above) * act_growth - allocation_above * senescence

            # --------------------- height dynamic
            height_dynamic!(; container, actual_height = patch_height,
                              above_biomass = patch_above_biomass,
                              allocation_above)
            @. du_height[x, y, :] = height_gain - height_loss_mowing - height_loss_grazing

            # --------------------- water dynamics
            du_water[x, y] = change_water_reserve(; container, patch_above_biomass,
                water = u_water[x, y],
                precipitation = input.precipitation[t],
                PET = input.PET_sum[t],
                WHC = WHC[x, y],
                PWP = PWP[x, y])

            ######################### write outputs
            output.community_pot_growth[t, x, y] = com.potgrowth_total
            output.community_height_reducer[t, x, y] = com.self_shading
            output.radiation_reducer[t, x, y] = com.RAD
            output.seasonal_growth[t, x, y] = com.SEA
            output.temperature_reducer[t, x, y] = com.TEMP
            output.seasonal_senescence[t, x, y] = com.SEN_season
            output.fodder_supply[t, x, y] = com.fodder_supply

            for s in 1:nspecies
                output.act_growth[t, x, y, s] = act_growth[s]
                output.mown[t, x, y, s] = mown[s]
                output.grazed[t, x, y, s] = grazed[s]
                output.senescence[t, x, y, s] = senescence[s]
                output.light_growth[t, x, y, s] = light_competition[s]
                output.water_growth[t, x, y, s] = Waterred[s]
                output.nutrient_growth[t, x, y, s] = Nutred[s]
                output.root_invest[t, x, y, s] = root_invest[s]
            end

        end
    end

    return nothing
end
