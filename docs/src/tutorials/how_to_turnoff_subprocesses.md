# How to turn-off subprocesses of the model

Mainly for debugging purposes, it is possible to turn off subprocesses of the model. This can be useful to understand the effect of a single subprocess on the model output. 

Load packages:
```@example turnoff_subprocesses
import GrasslandTraitSim as sim
using CairoMakie
using Unitful
using Statistics
using PrettyTables
```

All the subprocesses that can be turned off are listed in the `included_keys` variable. Let's check which parameters are used in each subprocess. Note that some parameters are used in multiple subprocesses and are therefore not listed in the table below:
```@example turnoff_subprocesses
included_keys = (
    :senescence,
    :senescence_season,
    :potential_growth,
    :clonalgrowth,
    :mowing,
    :grazing,
    :lowbiomass_avoidance,
    :belowground_competition,
    :community_self_shading,
    :height_competition,
    :pet_growth_reduction,
    :sla_transpiration,
    :water_growth_reduction,
    :nutrient_growth_reduction,
    :temperature_growth_reduction,
    :seasonal_growth_adjustment,
    :radiation_growth_reduction
)

p_all = sim.SimulationParameter()
p_dict = Dict()
for k in included_keys
    included_prep = (; zip([k], [false])...)

    input_obj = (; simp = (; included = sim.create_included(included_prep),
                             likelihood_included = (; biomass = false, trait = false),
                             npatches = 5))
    p = sim.SimulationParameter(input_obj;)    
    p_notin = keys(p_all)[.!(collect(keys(p_all)) .∈ Ref(keys(p)))]   
    p_dict[k] = p_notin    
end

pretty_table(p_dict; header = ["Subprocess", "Parameter that are only used in the specific subprocess"],
             sortkeys = true,
             alignment=:l)
nothing # hide
```

We have to write all the processes that we want to turn off in the `included` named tuple. Here we want to exclude the potential growth of the species. The named tuple looks as follows:
```@example turnoff_subprocesses
included = (;
    potential_growth = false,
)

trait_input = sim.input_traits()
input_obj = sim.validation_input(; included, plotID = "HEG01", nspecies = length(trait_input.amc));

# we also exclude all parameters that are not used
# this is not necessary, but it gives an overview which parameters are used
p = sim.SimulationParameter(input_obj; exclude_not_used = true)
```

Run the simulation and let's visualize the biomass dynamic without potential growth:
```@example turnoff_subprocesses
sol = sim.solve_prob(; input_obj, p, trait_input);

species_biomass = dropdims(mean(sol.output.biomass; dims = (:x, :y)); dims = (:x, :y))
total_biomass = vec(sum(species_biomass; dims = :species))

fig, _ = lines(sol.simp.output_date_num, ustrip.(total_biomass), color = :darkgreen, linewidth = 2;
      axis = (; ylabel = "Aboveground dry biomass [kg ha⁻¹]", 
                xlabel = "Date [year]"))
fig
save("biomass_no_pot_growth.svg", fig); nothing # hide
```

![](biomass_no_pot_growth.svg)