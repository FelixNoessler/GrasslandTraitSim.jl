# Influence of intermediate variables


## Trade-off between investing in roots and experiencing nutrient stress

- plants with a high investment into roots have a low aboveground biomass per total biomass and a high arbuscular mycorrhizal colonisation rate  
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

trait_input = sim.input_traits();
input_obj = sim.validation_input(; plotID = "HEG01", nspecies = 43, time_step_days = 1);
p = sim.SimulationParameter()
sol = sim.solve_prob(; input_obj, p, trait_input);

let
    t = sol.simp.mean_input_date_num

    first_axis = (xticklabelsvisible = false, xticksvisible = true)
    axis = (width = 900, height = 300)

    fig = Figure()

    Axis(fig[1, 1]; axis..., first_axis..., xticks = 2006:2:2022, ylabel = "Total aboveground\nbiomass [kg ha⁻¹]")
    lines!(t, ustrip.(vec(sum(sol.output.biomass[2:end, 1, 1, :]; dims = (:species))));
           linewidth = 3, color = :black)

    colorrange = (minimum(sol.output.root_invest), maximum(sol.output.root_invest))
    color_vals = vec(sol.output.root_invest)
    colormap = :viridis

    Axis(fig[2, 1]; axis..., xticks = 2006:2:2022,
         ylabel = "Growth reduction factor\ndue to nutrient stress [-]\n← stronger reduction, less reduction →")
    for s in 1:sol.simp.nspecies
        lines!(t, vec(sol.output.nutrient_growth[:, 1, 1, s]); colorrange,
               colormap, color = color_vals[s], linewidth = 0.5)
    end


    Axis(fig[3, 1]; axis..., xlabel = "Arbuscular mycorrhizal colonisation rate [-]",
         ylabel = "Aboveground biomass per total biomass [-]")
    scatter!(sol.traits.amc, sol.traits.abp,
             color = color_vals,
             markersize = 30)
    Colorbar(fig[2:3, 2]; colorrange, colormap,
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