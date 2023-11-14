# How to analyse the model output

I assume that you have read the tutorial on how to prepare the input data and run a simulation (see [here](@ref "How to prepare the input data to start a simulation")). In this tutorial, we will analyse the output of the simulation that is stored in the object `sol`.


```@example output
import GrasslandTraitSim as sim
import GrasslandTraitSim.Valid as valid

using Statistics
using CairoMakie
using Unitful

input_obj = valid.validation_input(;
    plotID = "HEG01", nspecies = 25,
    npatches = 1, nutheterog = 0.0);

mp = valid.model_parameters();
inf_p = (; zip(Symbol.(mp.names), mp.best)...);

sol = sim.solve_prob(; input_obj, inf_p)
```


## Biomass

We can look at the simulated biomass:

```@example output
size(sol.o.biomass)
```

The three dimension of the array are: daily time step, patch within site, species. 
For plotting the values with `Makie.jl`, we have to remove the units with `ustrip`:

```@example output
# if we have more than one patch per site, we have to first calculate the mean biomass per site
species_biomass = dropdims(mean(sol.o.biomass; dims=2); dims = 2)
total_biomass = vec(sum(species_biomass; dims=2))

lines(sol.numeric_date, ustrip.(total_biomass), color = :black, linewidth = 2;
      axis = (; ylabel = "Dry biomass [kg ha⁻¹]", xlabel = "Date [year]"))
```

## Soil water content

Similarly, we plot the soil water content over time:

```@example output
# if we have more than one patch per site, we have to first calculate the mean soil water content per site
soil_water_per_site = ustrip.(dropdims(mean(sol.o.water; dims=2); dims = 2))

lines(sol.numeric_date, soil_water_per_site, color = :blue, linewidth = 2;
      axis = (; ylabel = "Soil water content [mm]", xlabel = "Date [year]"))
```

## Community weighted mean traits

We calculate the community weighted mean specific leaf area (SLA) over time:

```@example output
relative_biomass = species_biomass ./ total_biomass
trait_vals = sol.traits[:sla]
weighted_trait = trait_vals .* relative_biomass'
cwm_trait = vec(sum(weighted_trait; dims = 1))

lines(sol.numeric_date, ustrip.(cwm_trait), color = :red, linewidth = 2;
      axis = (; ylabel = "Community weighted mean\nspecific leaf area [m² kg⁻¹]", xlabel = "Date [year]"))
```