@doc raw"""
    one_day!(; container, p, t)

Calculate the density differences of all state variables of one day.

Density differences for biomass:

```math
\text{du_biomass} = \text{growth} - \text{senescence} - \text{defoliation}
```

Density differences for water:

```math
\text{du_water} = \text{precipitation} - \text{drainage} - \text{actual_evapotranspiration}
```

**Main procedure (in the following order):**

if npatches > 1

- [clonal growth](@ref clonalgrowth!) at day of the year = 250

loop over patches:

- set very low biomass (< 1e-30 kg ha⁻¹) to zero
- defoliation ([mowing](@ref mowing!), [grazing](@ref grazing!),
  [trampling](@ref trampling!))
- [growth](@ref growth!)
- [senescence](@ref senescence!)
- [soil water dynamics](@ref change_water_reserve)
"""
function one_day!(; t, container)
    @unpack doy, daily_input, traits = container
    @unpack npatches, patch_xdim, patch_ydim, included = container.simp
    @unpack u_biomass, u_water, du_biomass, du_water = container.u
    @unpack WHC, PWP, nutrients = container.patch_variables
    @unpack very_low_biomass, nan_biomass = container.calc
    @unpack act_growth, sen, defoliation = container.calc


    LAItot = 0.0

    ## -------- clonal growth
    if doy[t] == 250 && npatches > 1 && included.clonalgrowth
        clonalgrowth!(; container)
    end

    ## -------- loop over patches
    for x in Base.OneTo(patch_xdim)
        for y in Base.OneTo(patch_ydim)

            # --------------------- biomass dynamics
            ### this line is needed because it is possible
            ## that there are numerical errors
            patch_biomass = @view u_biomass[x, y, :]
            # very_low_biomass .= patch_biomass .< 1e-30u"kg / ha" .&&
            #                     .!iszero.(patch_biomass)
            for i in eachindex(patch_biomass)
                if patch_biomass[i] < 1e-30u"kg / ha" && !iszero(patch_biomass[i])
                    patch_biomass[i] = 0.0u"kg / ha"
                end

                # if isnan(patch_biomass[i])
                #     @error "Patch biomass isnan: $patch_biomass" maxlog=2
                # end
            end

            defoliation .= 0.0u"kg / (ha * d)"

            if !iszero(sum(patch_biomass))
                # ------------------------------------------ mowing
                if included.mowing
                    mowing_height = if daily_input.mowing isa Vector
                        daily_input.mowing[t]
                    else
                        daily_input.mowing[t, x, y]
                    end

                    if !isnan(mowing_height)
                        mowing!(; t, x, y, container, mowing_height,
                            biomass = patch_biomass,
                            mowing_all = daily_input.mowing)
                    end
                end

                # ------------------------------------------ grazing & trampling
                LD = if daily_input.grazing isa Vector
                    daily_input.grazing[t]
                else
                    daily_input.grazing[t, x, y]
                end

                if !isnan(LD)
                    if included.grazing
                        grazing!(; t, x, y, container, LD,
                            biomass = patch_biomass)
                    end

                    if included.trampling
                        trampling!(; container, LD,
                            biomass = patch_biomass)
                    end
                end

                # ------------------------------------------ growth
                LAItot = growth!(; t, container,
                    biomass = patch_biomass,
                    W = u_water[x, y],
                    nutrients = nutrients[x, y],
                    WHC = WHC[x, y],
                    PWP = PWP[x, y])

                # ------------------------------------------ senescence
                if included.senescence
                    senescence!(; container,
                        ST = daily_input.temperature_sum[t],
                        biomass = patch_biomass)
                end

            else
                # @warn "Sum of patch biomass = 0" maxlog=10
                act_growth .= 0.0u"kg / (ha * d)"
                sen .= 0.0u"kg / (ha * d)"

                ## is already 0:
                # defoliation .= 0.0u"kg / (ha * d)"
            end

            # -------------- net growth
            @. du_biomass[x, y, :] = act_growth - sen - defoliation

            # --------------------- water dynamics
            du_water[x, y] = change_water_reserve(; container, patch_biomass, LAItot,
                water = u_water[x, y],
                precipitation = daily_input.precipitation[t],
                PET = daily_input.PET[t],
                WHC = WHC[x, y],
                PWP = PWP[x, y])
        end
    end

    return nothing
end
