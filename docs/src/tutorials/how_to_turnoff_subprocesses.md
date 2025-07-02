# How to turn-off subprocesses of the model

Mainly for debugging purposes, it is possible to turn off subprocesses of the model. This can be useful to understand the effect of a single subprocess on the model output. 

Load packages:
```@example turnoff_subprocesses
import GrasslandTraitSim as sim
using CairoMakie
using Unitful
using Statistics
```

All the subprocesses that can be turned off are listed here:
```@example turnoff_subprocesses
sim.create_included()
```

We have to write all the processes that we want to turn off in the `included` named tuple. By default, all other processes are included. Here we want to exclude the potential growth of the species. The named tuple looks as follows:
```@example turnoff_subprocesses
included = (;
    potential_growth = false,
)

input_obj = sim.create_input("HEG01"; included);
p = sim.optim_parameter();
nothing # hide
```

Run the simulation and let's visualize the biomass dynamic without potential growth:
```@example turnoff_subprocesses
sol = sim.solve_prob(; input_obj, p);

total_biomass = vec(sum(sol.output.biomass; dims = :species))

fig, _ = lines(sol.simp.output_date_num, ustrip.(total_biomass), color = :darkgreen, linewidth = 2;
      axis = (; ylabel = "Total dry biomass [kg ha⁻¹]", 
                xlabel = "Date [year]"))
fig
```