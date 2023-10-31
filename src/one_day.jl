@doc raw"""
    one_day!(; calc, p, t)

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

- [calculate relative biomass per patch](@ref Growth.calculate_relbiomass!),
  this is needed for grazing
- [clonal growth](@ref Growth.clonalgrowth!) at day of the year = 250

loop over patches:

- set very low biomass (< 1e-30 kg ha⁻¹) to zero
- defoliation ([mowing](@ref Growth.mowing!), [grazing](@ref Growth.grazing!),
  [trampling](@ref Growth.trampling!))
- [growth](@ref Growth.growth!)
- [senescence](@ref Growth.senescence!)
- [soil water dynamics](@ref Water.change_water_reserve)
"""
function one_day!(; t, container)
    @unpack doy, daily_input, traits = container
    @unpack npatches, included = container.simp
    @unpack WHC, PWP, nutrients = container.patch
    @unpack u_biomass, u_water = container.u
    @unpack du_biomass, du_water = container.du
    @unpack very_low_biomass, nan_biomass = container.calc
    @unpack act_growth, sen, defoliation, relbiomass = container.calc

    LAItot = 0.0

    ## -------- relative biomass per patch -> is needed for grazing
    if npatches > 1
        Growth.calculate_relbiomass!(; container)
    end

    ## -------- clonal growth
    if doy[t] == 250 && npatches > 1
        Growth.clonalgrowth!(; container)
    end

    for pa in Base.OneTo(npatches)
        # --------------------- biomass dynamics
        ### this line is needed because it is possible
        ## that there are numerical errors
        patch_biomass = @view u_biomass[pa, :]
        very_low_biomass .= patch_biomass .< 1e-30u"kg / ha" .&&
                            .!iszero.(patch_biomass)
        for i in eachindex(very_low_biomass)
            if very_low_biomass[i]
                patch_biomass[i] = 0u"kg / ha"
            end
        end

        defoliation .= 0.0u"kg / (ha * d)"

        nan_biomass .= isnan.(patch_biomass)
        if any(nan_biomass)
            @error "Patch biomass isnan: $patch_biomass" maxlog=20
        end

        if !iszero(sum(patch_biomass))

            # ------------------------------------------ mowing
            if included.mowing_included
                mowing_height = daily_input.mowing[t]
                if !isnan(mowing_height)
                    tstart = t - 200
                    tstart = tstart < 1 ? 1 : tstart
                    mowing_last200 = @view daily_input.mowing[tstart:t]
                    days_since_last_mowing = 200
                    for i in reverse(eachindex(mowing_last200))
                        if !iszero(mowing_last200[i]) && i != 201
                            days_since_last_mowing = 201 - i
                            break
                        end
                    end
                    Growth.mowing!(; container, mowing_height,
                        days_since_last_mowing,
                        biomass = patch_biomass)
                end
            end

            # ------------------------------------------ grazing & trampling
            if included.grazing_included
                LD = daily_input.grazing[t]
                if !isnan(LD)
                    Growth.grazing!(; container, LD,
                        biomass = patch_biomass,
                        relbiomass = relbiomass[pa],)
                    Growth.trampling!(; container, LD,
                        biomass = patch_biomass,
                        relbiomass = relbiomass[pa])
                end
            end

            # ------------------------------------------ growth
            LAItot = Growth.growth!(; t, container,
                biomass = patch_biomass,
                WR = u_water[pa],
                nutrients = nutrients[pa],
                WHC = WHC[pa],
                PWP = PWP[pa])

            # ------------------------------------------ senescence
            if included.senescence_included
                Growth.senescence!(; container,
                    ST = daily_input.temperature_sum[t],
                    biomass = patch_biomass)
            end

        else
            @warn "Sum of patch biomass = 0" maxlog=10
            act_growth .= 0.0u"kg / (ha * d)"
            sen .= 0.0u"kg / (ha * d)"

            ## is already 0:
            # defoliation .= 0.0u"kg / (ha * d)"
        end

        # -------------- net growth
        @. du_biomass[pa, :] = act_growth - sen - defoliation

        # --------------------- water dynamics
        du_water[pa] = Water.change_water_reserve(;
            container,
            patch_biomass,
            WR = u_water[pa],
            precipitation = daily_input.precipitation[t],
            LAItot,
            PET = daily_input.PET[t],
            WHC = WHC[pa],
            PWP = PWP[pa])
    end

    return nothing
end
