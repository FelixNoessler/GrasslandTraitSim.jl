include("2_community_potential_growth.jl")
include("3_light_competition.jl")
include("4_nutrient_competition.jl")
include("5_water_competition.jl")
include("6_root_investment.jl")
include("7_community_growth_reducers.jl")

"""
Calculates the growth of the plant species.
"""
function growth!(; t, container, above_biomass, total_biomass, actual_height, W, nutrients, WHC, PWP)
    @unpack input = container
    @unpack included = container.simp
    @unpack growth_act, species_specific_red, LIG, WAT, NUT, ROOT = container.calc
    @unpack growth_pot_total, RAD, SEA, TEMP = container.calc.com

    ########### Potential growth
    potential_growth!(; container, above_biomass, actual_height, PAR = input.PAR_sum[t])

    ########### Species-specific growth adjustment
    light_competition!(; container, above_biomass, actual_height)
    nutrient_reduction!(; container, nutrients, total_biomass)
    water_reduction!(; container, W, PWP, WHC)
    root_investment!(; container)
    @. species_specific_red = LIG * NUT * WAT# * ROOT

    ########### Community growth adjustment by environmental and seasonal factors
    radiation_reduction!(; container, PAR = input.PAR[t])
    temperature_reduction!(; container, T = input.temperature[t])
    seasonal_reduction!(; container, ST = input.temperature_sum[t])
    community_red = RAD * SEA * TEMP

    ########### Final growth
    @. growth_act = growth_pot_total * species_specific_red * community_red

    return nothing
end
