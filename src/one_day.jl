"""
Calculate differences of all state variables for one time step (one day).
"""
function one_day!(; t, container)
    @unpack input, output, traits = container
    @unpack npatches, patch_xdim, patch_ydim, nspecies, included, mean_input_year = container.simp
    @unpack u_biomass, u_above_biomass, u_below_biomass, u_water, u_height,
            du_biomass, du_above_biomass, du_below_biomass, du_water, du_height = container.u
    @unpack WHC, PWP, nutrients = container.patch_variables
    @unpack com, growth_act, senescence, mown, grazed, defoliation,
        LIG, NUT, WAT, ROOT, allocation_above, above_proportion, nutrients_splitted,
        height_gain, height_loss_mowing, height_loss_grazing = container.calc

    year = mean_input_year[t]

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
            growth_act .= 0.0u"kg / ha"
            senescence .= 0.0u"kg / ha"
            grazed .= 0.0u"kg / ha"
            mown .= 0.0u"kg / ha"

            if !iszero(sum(patch_biomass)) && !iszero(sum(patch_above_biomass))
                # ------------------------------------------ growth
                growth!(; t, x, y, container,
                    above_biomass = patch_above_biomass,
                    total_biomass = patch_biomass,
                    actual_height = patch_height,
                    W = u_water[x, y],
                    nutrients = nutrients[year = At(year), x = At(x), y = At(y)],
                    WHC = WHC[year = At(year), x = At(x), y = At(y)],
                    PWP = PWP[year = At(year), x = At(x), y = At(y)])

                # ------------------------------------------ senescence
                senescence!(; container,
                    ST = input[:temperature_sum][t, x, y],
                    total_biomass = patch_biomass)

                # ------------------------------------------ mowing
                if included.mowing
                    mowing_height = input[:CUT_mowing][t, x, y]
                    if !ismissing(mowing_height)
                        mowing!(; container, mowing_height,
                                above_biomass = patch_above_biomass,
                                actual_height = patch_height)
                    end
                end

                # ------------------------------------------ grazing
                if included.grazing
                    LD = input[:LD_grazing][t, x, y]
                    if !ismissing(LD)
                        grazing!(; container, LD, above_biomass = patch_above_biomass,
                                   actual_height = patch_height)
                    end
                end
            end

            # -------------- net growth
            @. du_biomass[x, y, :] = growth_act - senescence - defoliation
            @. du_above_biomass[x, y, :] = allocation_above * growth_act - (1-allocation_above) * senescence - defoliation
            @. du_below_biomass[x, y, :] = (1-allocation_above) * growth_act - allocation_above * senescence

            # --------------------- height dynamic
            height_dynamic!(; container, actual_height = patch_height,
                              above_biomass = patch_above_biomass,
                              allocation_above)

            @. du_height[x, y, :] = height_gain - height_loss_mowing - height_loss_grazing
            for s in 1:nspecies
                if patch_height[s] + du_height[x, y, s] > traits.maxheight[s]
                    du_height[x, y, s] = traits.maxheight[s] - patch_height[s]
                end
            end

            # --------------------- water dynamics
            du_water[x, y] = change_water_reserve(; container,
                water = u_water[x, y],
                precipitation = input[:precipitation][t, x, y],
                PET = input[:PET_sum][t, x, y],
                WHC = WHC[year = At(year), x = At(x), y = At(y)],
                PWP = PWP[year = At(year), x = At(x), y = At(y)])

            ######################### write outputs
            output.community_pot_growth[t, x, y] = com.growth_pot_total
            output.community_height_reducer[t, x, y] = com.RUE_community_height
            output.radiation_reducer[t, x, y] = com.RAD
            output.seasonal_growth[t, x, y] = com.SEA
            output.temperature_reducer[t, x, y] = com.TEMP
            output.seasonal_senescence[t, x, y] = com.SEN_season
            output.fodder_supply[t, x, y] = com.fodder_supply
            output.mean_nutrient_index[t, x, y] = min(max(mean(nutrients_splitted), 0.0), 1.0)

            for s in 1:nspecies
                output.growth_act[t, x, y, s] = growth_act[s]
                output.mown[t, x, y, s] = mown[s]
                output.grazed[t, x, y, s] = grazed[s]
                output.senescence[t, x, y, s] = senescence[s]
                output.light_growth[t, x, y, s] = LIG[s]
                output.water_growth[t, x, y, s] = WAT[s]
                output.nutrient_growth[t, x, y, s] = NUT[s]
                output.root_invest[t, x, y, s] = ROOT[s]
            end

        end
    end

    return nothing
end
