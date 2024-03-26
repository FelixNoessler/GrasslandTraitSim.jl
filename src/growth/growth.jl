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
    @unpack species_specific_red, light_competition, Waterred, Nutred = container.calc
    @unpack act_growth = container.calc
    @unpack potgrowth_total = container.calc.com

    #### potential growth
    potential_growth!(; container, biomass, PAR = daily_input.PAR[t])

    ### influence of the leaf areay index and the height of the plants
    light_competition!(; container, biomass)

    #### below ground competition --> trait similarity and abundance
    below_ground_competition!(; container, biomass)

    #### growth reducer
    water_reduction!(; container, W, PWP, WHC, PET = daily_input.PET[t])
    nutrient_reduction!(; container, nutrients)
    Rred = radiation_reduction(; container, PAR = daily_input.PAR[t])
    Tred = temperature_reduction(; container, T = daily_input.temperature[t])
    Seasonalred = seasonal_reduction(; container, ST = daily_input.temperature_sum[t])

    @. species_specific_red = light_competition * Waterred * Nutred
    reduction = Rred * Tred * Seasonalred

    #### final growth
    @. act_growth = potgrowth_total * reduction * species_specific_red

    return nothing
end
