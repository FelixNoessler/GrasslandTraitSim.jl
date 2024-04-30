include("growth_reducers.jl")
include("defoliation.jl")
include("senescence.jl")
include("clonalgrowth.jl")
include("potential_growth.jl")
include("belowground_competition.jl")
include("light_competition.jl")

"""
Calculates the growth of the plant species.

**The growth of the plants is modelled by...**
- [Potential growth](@ref)
- [Community growth adjustment by environmental and seasonal factors](@ref)
- [Species-specific growth adjustment](@ref)
"""
function growth!(; t, container, biomass, W, nutrients, WHC, PWP)
    @unpack input = container
    @unpack included = container.simp
    @unpack act_growth, com, species_specific_red, light_competition, Waterred,
            Nutred = container.calc

    ########### Potential growth
    potential_growth!(; container, biomass, PAR = input.PAR_sum[t])

    ########### Community growth adjustment by environmental and seasonal factors
    radiation_reduction!(; container, PAR = input.PAR[t])
    temperature_reduction!(; container, T = input.temperature[t])
    seasonal_reduction!(; container, ST = input.temperature_sum[t])
    community_red = com.RAD * com.SEA * com.TEMP

    ########### Species-specific growth adjustment
    light_competition!(; container, biomass)
    below_ground_competition!(; container, biomass)
    water_reduction!(; container, W, PWP, WHC, PET = input.PET[t])
    nutrient_reduction!(; container, nutrients)
    @. species_specific_red = light_competition * Waterred * Nutred

    ########### Final growth
    @. act_growth = com.potgrowth_total * community_red * species_specific_red

    return nothing
end
