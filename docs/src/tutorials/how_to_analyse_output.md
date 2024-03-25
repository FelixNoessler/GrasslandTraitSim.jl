# How to analyse the model output

I assume that you have read the tutorial on how to prepare the input data and run a simulation (see [here](@ref "How to prepare the input data to start a simulation")). In this tutorial, we will analyse the output of the simulation that is stored in the object `sol`.


```@example output
import GrasslandTraitSim as sim

using Statistics
using CairoMakie
using Unitful

input_obj = sim.validation_input(;
    plotID = "HEG01", nspecies = 25,
    trait_seed = 99);
p = sim.Parameter();
sol = sim.solve_prob(; input_obj, p);

nothing # hide
```


## Biomass

We can look at the simulated biomass:

```@example output
sol.output.biomass
```

The four dimension of the array are: daily time step, patch x dim, patch y dim, and species. 
For plotting the values with `Makie.jl`, we have to remove the units with `ustrip`:

```@example output
# if we have more than one patch per site, we have to first calculate the mean biomass per site
species_biomass = dropdims(mean(sol.output.biomass; dims = (:x, :y)); dims = (:x, :y))
total_biomass = vec(sum(species_biomass; dims = :species))

fig, _ = lines(sol.numeric_date, ustrip.(total_biomass), color = :darkgreen, linewidth = 2;
      axis = (; ylabel = "Aboveground dry biomass [kg ha⁻¹]", 
                xlabel = "Date [year]"))
fig
save("biomass.svg", fig); nothing # hide
```

![](biomass.svg)

## Share of each species

We can look at the share of each species over time:

```@example output
# colors are assigned according to the specific leaf area (SLA)
color = ustrip.(sol.traits.sla)
colormap = :viridis
colorrange = (minimum(color), maximum(color))
is = sortperm(color)
cmap = cgrad(colormap)
colors = [cmap[(co .- colorrange[1]) ./ (colorrange[2] - colorrange[1])]
          for co in color[is]]

# calculate biomass proportion of each species
biomass_site = dropdims(mean(sol.output.biomass; dims=(:x, :y)); dims = (:x, :y))
biomass_ordered = biomass_site[:, sortperm(color)]
biomass_fraction = biomass_ordered ./ sum(biomass_ordered; dims = :species)
biomass_cumfraction = cumsum(biomass_fraction; dims = 2)

begin
    fig = Figure()
    Axis(fig[1,1]; ylabel = "Relative proportion of biomass of the species", 
         xlabel = "Date [year]",
         limits = (sol.numeric_date[1], sol.numeric_date[end], 0, 1))

    for i in 1:sol.simp.nspecies
        ylower = nothing
        if i == 1
            ylower = zeros(size(biomass_cumfraction, 1))
        else
            ylower = biomass_cumfraction[:, i-1]
        end
        yupper = biomass_cumfraction[:, i]

        band!(sol.numeric_date, vec(ylower), vec(yupper);
              color = colors[i])
    end

    Colorbar(fig[1,2]; limits = colorrange, colormap = cmap, 
             label = "Specific leaf area [m² g⁻¹]")

    fig
end
save("share_biomass.svg", fig); nothing # hide
```

![](share_biomass.svg)

## Soil water content

Similarly, we plot the soil water content over time:

```@example output
# if we have more than one patch per site, 
# we have to first calculate the mean soil water content per site
soil_water_per_site = dropdims(mean(sol.output.water; dims = (:x, :y)); dims = (:x, :y))

fig, _ = lines(sol.numeric_date, ustrip.(soil_water_per_site), color = :blue, linewidth = 2;
      axis = (; ylabel = "Soil water content [mm]", xlabel = "Date [year]"))
fig
save("soil_water_content.svg", fig); nothing # hide
```

![](soil_water_content.svg)

## Community weighted mean traits

We can calculate for all traits the community weighted mean over time:

```@example output
relative_biomass = species_biomass ./ total_biomass
traits = [:height, :sla, :lncm, :rsa_above, :amc, :ampm, :lmpm]
trait_names = [
    "Potential\n height [m]", "Specific leaf\narea [m² g⁻¹]", "Leaf nitrogen \nper leaf mass\n [mg g⁻¹]",
    "Root surface\narea per above\nground biomass\n[m² g⁻¹]", "Arbuscular\n mycorrhizal\n colonisation",
    "Aboveground\nbiomass per total\nbiomass [-]", "Leaf biomass\nper total \nbiomass [-]"]

begin
    fig = Figure(; size = (500, 1000))

    for i in eachindex(traits)
        trait_vals = sol.traits[traits[i]]
        weighted_trait = trait_vals .* relative_biomass'
        cwm_trait = vec(sum(weighted_trait; dims = 1))

        Axis(fig[i, 1];
                xlabel = i == length(traits) ? "Date [year]" : "",
                xticklabelsvisible = i == length(traits) ? true : false,
                ylabel = trait_names[i])
        lines!(sol.numeric_date, ustrip.(cwm_trait);
                color = :black, linewidth = 2)
        
    end
    
    [rowgap!(fig.layout, i, 5) for i in 1:length(traits)-1]
    
    fig
end
save("traits_time.svg", fig); nothing # hide
```

![](traits_time.svg)

## Grazed and mown biomass

We can look at the grazed and mown biomass over time:

```@example output
# total 
sum(sol.output.mown)
sum(sol.output.grazed)

# plot the grazed and mown biomass over time
grazed_site = dropdims(mean(sol.output.grazed; dims=(:x, :y, :species)); dims=(:x, :y, :species))
cum_grazed = cumsum(grazed_site)

mown_site = dropdims(mean(sol.output.mown; dims=(:x, :y, :species)); dims=(:x, :y, :species))
cum_mown = cumsum(mown_site)
begin
      fig = Figure()
      Axis(fig[1,1]; ylabel = "Cummulative grazed\nbiomass [kg ha⁻¹]")
      lines!(sol.numeric_date, ustrip.(vec(cum_grazed)), color = :black, linewidth = 2;)
      Axis(fig[2,1]; ylabel = "Cummulative mown\nbiomass [kg ha⁻¹]", xlabel = "Date [year]")
      lines!(sol.numeric_date, ustrip.(vec(cum_mown)), color = :black, linewidth = 2;)
      fig
end
save("grazed_mown.svg", fig); nothing # hide
```

![](grazed_mown.svg)

## Shannon and Simpson diversity

We can calculate the Shannon and Simpson diversity over time:

```@example output
biomass_site = dropdims(mean(sol.output.biomass; dims = (:x, :y)); dims = (:x, :y))
tend = size(biomass_site, 1)
shannon = Array{Float64}(undef, tend)
simpson = Array{Float64}(undef, tend)
for t in 1:tend
    b1 = biomass_site[t, :]
    b1 = b1[.!iszero.(b1)]
    p1 = b1 ./ sum(b1)
    shannon[t] = -sum(p1 .* log.(p1))
    simpson[t] = sum(p1 .^ 2)
end

begin
    fig = Figure()
    Axis(fig[1,1]; ylabel = "Shannon index")
    lines!(sol.numeric_date, shannon, color = :black, linewidth = 2;)
    Axis(fig[2,1]; ylabel = "Simpson index", xlabel = "Date [year]")
    lines!(sol.numeric_date, simpson, color = :black, linewidth = 2;)
    fig
end
save("shannon_simpson.svg", fig); nothing # hide
```

![](shannon_simpson.svg)
