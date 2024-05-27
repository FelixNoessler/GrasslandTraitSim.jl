"""
    actual_height!(; container)

TBW
"""
function actual_height!(; container, biomass)
    @unpack β_lowB, α_lowB = container.p
    @unpack height, abp = container.traits
    @unpack above_biomass, actual_height = container.calc

    @. above_biomass = abp * biomass
    @. actual_height = height * 1.0 / (1.0 + exp(-β_lowB * (above_biomass - α_lowB)))

    return nothing
end
