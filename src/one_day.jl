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

- [calculate relative biomass per patch](@ref calculate_relbiomass!),
  this is needed for [grazing](@ref grazing!) and [trampling](@ref trampling!)
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
    @unpack u_biomass, u_water, du_biomass, du_water,
            WHC, PWP, nutrients, cutted_biomass = container.u
    @unpack very_low_biomass, nan_biomass = container.calc
    @unpack act_growth, sen, defoliation, relbiomass = container.calc
    @unpack biomass_cutting_t = container.output_validation

    LAItot = 0.0

    ## -------- clonal growth
    if doy[t] == 250 && npatches > 1
        clonalgrowth!(; container)
    end

    ## -------- cutted biomass
    if t ∈ biomass_cutting_t
        cutted_biomass[t = At(t)]  =
            mowing!(; t, container, mowing_height = 0.04u"m",
                biomass = mean(u_biomass; dims = (:x, :y)),
                mowing_all = daily_input.mowing,
                return_mowing = true)
    end

    ## -------- loop over patches
    for x in Base.OneTo(patch_xdim)
        for y in Base.OneTo(patch_ydim)

            # --------------------- biomass dynamics
            ### this line is needed because it is possible
            ## that there are numerical errors
            patch_biomass = @view u_biomass[x, y, :]
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
                    mowing_height = NaN * u"m"

                    if daily_input.mowing isa Vector
                        mowing_height = daily_input.mowing[t]
                    else
                        mowing_height = daily_input.mowing[t, x, y]
                    end

                    if !isnan(mowing_height)
                        mowing!(; t, x, y, container, mowing_height,
                            biomass = patch_biomass,
                            mowing_all = daily_input.mowing)
                    end
                end

                # ------------------------------------------ grazing & trampling
                if included.grazing_included
                    LD = NaN * u"1 / ha"

                    if daily_input.grazing isa Vector
                        LD = daily_input.grazing[t]
                    else
                        LD = daily_input.grazing[t, x, y]
                    end

                    if !isnan(LD)
                        grazing!(; t, x, y, container, LD,
                            biomass = patch_biomass)
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
                if included.senescence_included
                    senescence!(; container,
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
