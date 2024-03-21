include("growth_reducers.jl")
include("defoliation.jl")
include("senescence.jl")
include("clonalgrowth.jl")
include("potential_growth.jl")
include("belowground_competition.jl")
include("light_competition.jl")

"""
Calculates the actual growth of the plant species.
"""
function growth!(; t, container, biomass, W, nutrients, WHC, PWP)
    @unpack daily_input = container
    @unpack included = container.simp
    @unpack species_specific_red, heightinfluence, Waterred, Nutred = container.calc
    @unpack act_growth, potgrowth = container.calc

    #### potential growth
    LAItot = potential_growth!(; container,
        biomass,
        PAR = daily_input.PAR[t])

    ### influence of the height of plants
    light_competition!(; container, biomass)

    #### below ground competition --> trait similarity and abundance
    below_ground_competition!(; container, biomass)

    #### growth reducer
    water_reduction!(; container, W, PWP, WHC, PET = daily_input.PET[t])
    nutrient_reduction!(; container, nutrients)
    Rred = radiation_reduction(; container, PAR = daily_input.PAR[t])
    Tred = temperature_reduction(; container, T = daily_input.temperature[t])
    Seasonalred = seasonal_reduction(; container, ST = daily_input.temperature_sum[t])
    height_community_red = community_height_reduction(; container, biomass)

    @. species_specific_red = heightinfluence * Waterred * Nutred
    reduction = Rred * Tred * Seasonalred * height_community_red

    #### final growth
    @. act_growth = potgrowth * reduction * species_specific_red

    return LAItot
end
