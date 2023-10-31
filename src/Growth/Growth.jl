module Growth

import LinearAlgebra

using Distributions
using UnPack
using Unitful

include("growth_reducers.jl")
include("defoliation.jl")
include("senescence.jl")
include("clonalgrowth.jl")
include("potential_growth.jl")
include("belowground_competition.jl")
include("height_influence.jl")

"""
    growth!(; t, p, calc, biomass, WR)

Calculates the actual growth of the plant species.
"""
function growth!(; t, container, biomass, WR, nutrients, WHC, PWP)
    @unpack daily_input, traits = container
    @unpack included = container.simp
    @unpack species_specific_red, heightinfluence, Waterred, Nutred = container.calc
    @unpack act_growth, pot_growth, neg_act_growth = container.calc

    #### potential growth
    LAItot = potential_growth!(; container,
        potgrowth_included = included.potgrowth_included,
        sla = traits.sla,
        biomass,
        PAR = daily_input.PAR[t])

    ### influence of the height of plants
    height_influence!(; container, biomass)

    #### below ground competition --> trait similarity and abundance
    below_ground_competition!(; container, biomass)

    #### growth reducer
    water_reduction!(; container, WR, PWP, WHC,
        water_red = included.water_red,
        PET = daily_input.PET[t])
    nutrient_reduction!(; container, nutrients,
        nutrient_red = included.nutrient_red)
    Rred = radiation_reduction(; PAR = daily_input.PAR[t],
        radiation_red = included.radiation_red)
    Tred = temperature_reduction(; T = daily_input.temperature[t],
        temperature_red = included.temperature_red)
    Seasonalred = seasonal_reduction(; ST = daily_input.temperature_sum[t],
        season_red = included.season_red)

    @. species_specific_red = heightinfluence * Waterred * Nutred
    reduction = Rred * Tred * Seasonalred

    #### final growth
    @. act_growth = pot_growth * reduction * species_specific_red

    @. neg_act_growth = act_growth < 0u"kg / (ha * d)"
    if any(neg_act_growth)
        @error "act_growth below zero: $(calc.act_growth)" maxlog=10
    end

    return LAItot
end

end # of module
