"""
Caculates the change in the plant height of each species during one time step.
"""
function height_dynamic!(; container, actual_height, above_biomass, allocation_above)
    @unpack mown, grazed, growth_act,
        height_gain, height_loss_grazing, height_loss_mowing = container.calc
    @unpack nspecies = container.simp

    for s in 1:nspecies
        if iszero(above_biomass[s])
            height_gain[s] = 0u"m"
            height_loss_mowing[s] = 0u"m"
            height_loss_grazing[s] = 0u"m"
        else
            height_gain[s] = (allocation_above[s] * growth_act[s]) / above_biomass[s] * actual_height[s]
            height_loss_mowing[s] = mown[s] / above_biomass[s] * actual_height[s]
            height_loss_grazing[s] = grazed[s] / above_biomass[s] * actual_height[s]
        end
    end

    return nothing
end
