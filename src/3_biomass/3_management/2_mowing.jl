"""
Simulate the mown biomass of each plant species.
"""
function mowing!(; container, mowing_height, above_biomass, actual_height)
    @unpack defoliation, mown, proportion_mown  = container.calc

    # --------- proportion of plant height that is mown
    for i in eachindex(proportion_mown)
        if actual_height[i] > mowing_height
            proportion_mown[i] = (actual_height[i] - mowing_height) / actual_height[i]
        else
            proportion_mown[i] = 0.0
        end
    end

    # --------- add the removed biomass to the defoliation vector
    @. mown = proportion_mown * above_biomass
    defoliation .+= mown

    return nothing
end
