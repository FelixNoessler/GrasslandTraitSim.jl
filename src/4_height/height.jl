function height_dynamic!(; container, actual_height, above_biomass, allocation_above)
    @unpack height = container.traits
    @unpack mown, grazed, act_growth,
        height_gain, height_loss_grazing, height_loss_mowing = container.calc
    @unpack nspecies = container.simp

    for s in 1:nspecies
        if iszero(above_biomass[s])
            height_gain[s] = 0u"m"
            height_loss_mowing[s] = 0u"m"
            height_loss_grazing[s] = 0u"m"
        else
            height_gain[s] = (allocation_above[s] * act_growth[s]) / above_biomass[s] * (1 - actual_height[s] / height[s]) * actual_height[s]
            height_loss_mowing[s] = mown[s] / above_biomass[s] * actual_height[s]
            height_loss_grazing[s] = grazed[s] / above_biomass[s] * actual_height[s]
        end
    end

    return nothing
end
