include("2_community_potential_growth.jl")
include("3_light_competition.jl")
include("4_nutrient_competition.jl")
include("5_water_competition.jl")
include("6_root_investment.jl")
include("7_community_growth_reducers.jl")

"""
Calculates the growth of the plant species.

**The growth of the plants is modelled by...**
- [Potential growth of the community](@ref)
- [Community growth adjustment by environmental and seasonal factors](@ref)
- [Species-specific growth adjustment](@ref)
"""
function growth!(; t, container, above_biomass, total_biomass, actual_height, W, nutrients, WHC, PWP)
    @unpack input = container
    @unpack included = container.simp
    @unpack act_growth, com, species_specific_red, light_competition, Waterred,
            Nutred, root_invest = container.calc

    ########### Potential growth
    potential_growth!(; container, above_biomass, actual_height, PAR = input.PAR_sum[t])

    ########### Species-specific growth adjustment
    light_competition!(; container, above_biomass, actual_height)
    nutrient_reduction!(; container, nutrients, total_biomass)
    water_reduction!(; container, W, PWP, WHC)
    root_investment!(; container)
    @. species_specific_red = light_competition * Nutred * Waterred * root_invest

    ########### Community growth adjustment by environmental and seasonal factors
    radiation_reduction!(; container, PAR = input.PAR[t])
    temperature_reduction!(; container, T = input.temperature[t])
    seasonal_reduction!(; container, ST = input.temperature_sum[t])
    community_red = com.RAD * com.SEA * com.TEMP

    ########### Final growth
    @. act_growth = com.potgrowth_total * species_specific_red * community_red

    return nothing
end
