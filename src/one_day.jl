"""
Calculate differences of all state variables for one time step (one day).
"""
function one_day!(; t, container)
    @unpack input, output, traits, state_water = container
    @unpack nspecies, included, mean_input_year = container.simp
    @unpack u_biomass, u_above_biomass, u_below_biomass, u_height,
            du_biomass, du_above_biomass, du_below_biomass, du_height = container.u
    @unpack WHC, PWP, nutrients = container.soil_variables
    @unpack com, growth_act, senescence, mown, grazed, defoliation,
        LIG, NUT, WAT, ROOT, allocation_above, above_proportion, nutrients_splitted,
        height_gain, height_loss_mowing, height_loss_grazing = container.calc

    year = mean_input_year[t]

    # --------------------- biomass dynamics
    for i in eachindex(u_biomass)
        if u_biomass[i] < 1e-30u"kg / ha" && !iszero(u_biomass[i])
            u_biomass[i] = 0.0u"kg / ha"
        end

        if u_above_biomass[i] < 1e-30u"kg / ha" && !iszero(u_above_biomass[i])
            u_above_biomass[i] = 0.0u"kg / ha"
        end

        if u_below_biomass[i] < 1e-30u"kg / ha" && !iszero(u_below_biomass[i])
            u_below_biomass[i] = 0.0u"kg / ha"
        end

        if u_height[i] < 1e-30u"m" && !iszero(u_height[i])
            u_height[i] = 0.0u"m"
        end
    end

    for s in 1:nspecies
        if iszero(u_biomass[s])
            above_proportion[s] = 0.0
        else
            above_proportion[s] = u_above_biomass[s] / u_biomass[s]
        end
    end
    @. allocation_above = 1 - above_proportion / traits.abp

    defoliation .= 0.0u"kg / ha"
    growth_act .= 0.0u"kg / ha"
    senescence .= 0.0u"kg / ha"
    grazed .= 0.0u"kg / ha"
    mown .= 0.0u"kg / ha"

    if !iszero(sum(u_biomass)) && !iszero(sum(u_above_biomass))
        # ------------------------------------------ growth
        growth!(; t, container,
            above_biomass = u_above_biomass,
            total_biomass = u_biomass,
            actual_height = u_height,
            W = state_water.u_water,
            nutrients = nutrients[year = At(year)],
            WHC = WHC[year = At(year)],
            PWP = PWP[year = At(year)])

        # ------------------------------------------ senescence
        senescence!(; container,
            ST = input[:temperature_sum][t],
            total_biomass = u_biomass)

        # ------------------------------------------ mowing
        if included.mowing
            mowing_height = input[:CUT_mowing][t]
            if !ismissing(mowing_height)
                mowing!(; container, mowing_height,
                        above_biomass = u_above_biomass,
                        actual_height = u_height)
            end
        end

        # ------------------------------------------ grazing
        if included.grazing
            LD = input[:LD_grazing][t]
            if !ismissing(LD)
                grazing!(; container, LD, above_biomass = u_above_biomass,
                            actual_height = u_height)
            end
        end
    end

    # -------------- net growth



    @. du_biomass = growth_act - senescence - defoliation
    @. du_above_biomass = allocation_above * growth_act - (1-allocation_above) * senescence - defoliation
    @. du_below_biomass = (1-allocation_above) * growth_act - allocation_above * senescence

    # --------------------- height dynamic
    height_dynamic!(; container, actual_height = u_height,
                        above_biomass = u_above_biomass,
                        allocation_above)

    @. du_height = height_gain - height_loss_mowing - height_loss_grazing

    for s in 1:nspecies
        if u_height[s] + du_height[s] > traits.maxheight[s]
            du_height[s] = traits.maxheight[s] - u_height[s]
        end
    end

    # --------------------- water dynamics
    state_water.du_water = change_water_reserve(; container,
        water = state_water.u_water,
        precipitation = input[:precipitation][t],
        PET = input[:PET_sum][t],
        WHC = WHC[year = At(year)],
        PWP = PWP[year = At(year)])

    ######################### write outputs
    output.community_pot_growth[t] = com.growth_pot_total
    output.community_height_reducer[t] = com.RUE_community_height
    output.radiation_reducer[t] = com.RAD
    output.seasonal_growth[t] = com.SEA
    output.temperature_reducer[t] = com.TEMP
    output.seasonal_senescence[t] = com.SEN_season
    output.fodder_supply[t] = com.fodder_supply
    output.mean_nutrient_index[t] = min(max(mean(nutrients_splitted), 0.0), 1.0)

    for s in 1:nspecies
        output.growth_act[t, s] = growth_act[s]
        output.mown[t, s] = mown[s]
        output.grazed[t, s] = grazed[s]
        output.senescence[t, s] = senescence[s]
        output.light_growth[t, s] = LIG[s]
        output.water_growth[t, s] = WAT[s]
        output.nutrient_growth[t, s] = NUT[s]
        output.root_invest[t, s] = ROOT[s]
    end

    return nothing
end
