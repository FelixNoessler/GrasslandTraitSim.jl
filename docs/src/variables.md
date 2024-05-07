# Influence of intermediate variables

## Trade-off between investing in roots and experiencing nutrient stress

- plants with a high investment into roots have a low aboveground biomass per total biomass, a high arbuscular mycorrhizal colonisation rate, and a high root surface area per belowground biomass  
    - ``\rightarrow`` low growth reduction due to nutrient stress  
    - ``\rightarrow`` investment costs energy, this is implemented by a growth reducer that is independent of the nutrient level  
- nutrient stress is stronger if the total biomass is high


```@raw html
<details><summary>show code</summary>
```

```@example variables
using CairoMakie
using Unitful
import GrasslandTraitSim as sim

let
    trait_input = sim.input_traits();
    input_obj = sim.validation_input(; plotID = "HEG01", nspecies = 43, time_step_days = 1);
    p = sim.SimulationParameter()
    sol = sim.solve_prob(; input_obj, p, trait_input);
    t = sol.simp.mean_input_date_num
    t_out = sol.simp.output_date_num
    total_biomass = ustrip.(vec(sol.output.biomass[:, 1, 1, :] * (1 ./ sol.traits.abp)))
    
    axis = (width = 900, height = 300)

    fig = Figure()

    Axis(fig[1, 1:2]; axis..., xticklabelsvisible = false, xticksvisible = true, 
         xticks = 2006:2:2022, ylabel = "Total biomass [kg ha⁻¹]")
    lines!(t_out, total_biomass;
           linewidth = 3, color = :black)

    colorrange = (minimum(sol.output.root_invest), maximum(sol.output.root_invest))
    color_vals = vec(sol.output.root_invest)
    colormap = :viridis

    Axis(fig[2, 1:2]; axis..., xticks = 2006:2:2022,
         ylabel = "Growth reduction factor\ndue to nutrient stress [-]\n← stronger reduction, less reduction →")
    for s in 1:sol.simp.nspecies
        lines!(t, vec(sol.output.nutrient_growth[:, 1, 1, s]); colorrange,
               colormap, color = color_vals[s], linewidth = 0.5)
    end


    Axis(fig[3, 1];  height = 300, width = 450, 
         xlabel = "Aboveground biomass per total biomass [-]",
         ylabel = "Arbuscular mycorrhizal colonisation rate [-]")
    scatter!(sol.traits.abp, sol.traits.amc,
             color = color_vals,
             markersize = 30)
    
    Axis(fig[3, 2]; height = 300, width = 450, 
         xlabel = "Aboveground biomass per total biomass [-]",
         ylabel = "Root suface area [m² g⁻¹]")
    scatter!(sol.traits.abp, ustrip.(sol.traits.rsa),
            color = color_vals,
            markersize = 30)
    
    Colorbar(fig[2:3, 3]; colorrange, colormap,
        label = "Growth reduction due to investment into roots [-]")

    rowgap!(fig.layout, 1, 10)
    rowgap!(fig.layout, 2, 10)

    resize_to_layout!(fig)
    fig
    save("nutrient_stress.svg", fig); nothing # hide
end
```

```@raw html
</details>
```

![](nutrient_stress.svg)


## Trade-off between investing in roots and experiencing water stress


```@raw html
<details><summary>show code</summary>
```

```@example variables
using CairoMakie
using Unitful
import GrasslandTraitSim as sim

let
    trait_input = sim.input_traits();
    input_obj = sim.validation_input(; plotID = "HEG01", nspecies = 43, time_step_days = 1);
    p = sim.SimulationParameter()
    sol = sim.solve_prob(; input_obj, p, trait_input);
    t = sol.simp.mean_input_date_num
    t_out = sol.simp.output_date_num
    total_biomass = ustrip.(vec(sol.output.biomass[:, 1, 1, :] * (1 ./ sol.traits.abp)))
    
    axis = (width = 900, height = 300)

    fig = Figure()

    Axis(fig[1, 1:2]; axis..., xticklabelsvisible = false, xticksvisible = true, 
         xticks = 2006:2:2022, ylabel = "Total biomass [kg ha⁻¹]")
    lines!(1:10)
    resize_to_layout!(fig)
    fig
    # save("water_stress.svg", fig); nothing # hide
end
```

```@raw html
</details>
```

![](water_stress.svg)