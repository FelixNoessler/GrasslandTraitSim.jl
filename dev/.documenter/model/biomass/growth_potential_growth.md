


# Potential growth of the community {#Potential-growth-of-the-community}

The potential growth of the plant community $G_{pot, t}$ [kg ha⁻¹] is described by: 

$$\begin{align}
    G_{pot, t} &= PAR_{t} \cdot \gamma_{RUE\max} \cdot FPAR_{t} \\
    FPAR_{t} &= \left(1 - \exp\left(-\gamma_{RUE,k} \cdot LAI_{tot, t}\right)\right) \cdot  
    \exp\left(\frac{\log(\alpha_{RUE, cwmH}) \cdot 0.2 m}{H_{cwm, t}}\right)\\
    H_{cwm, t} &= \sum_{s=1}^{S}\frac{B_{A, ts}}{B_{totA, t}} \cdot H_{ts} \\
    LAI_{tot, t} &= \sum_{s=1}^{S} LAI_{ts} \\
    LAI_{ts} &= B_{A, ts} \cdot sla_s \cdot lbp_s \cdot 0.1
\end{align}$$

In the last equation the values are converted to the dimensionless leaf area index by multiplying the term with 0.1.

:::tabs

== Parameter
- $\gamma_{RUE\max}$ maximum radiation use efficiency [kg MJ⁻¹]
  
- $\gamma_{RUE,k}$ light extinction coefficient [-]
  
- $\alpha_{RUE, cwmH} \in [0, 1]$ is the reduction factor of $FPAR_{t}$ if the community weighted mean height equals 0.2 m [-]
  

== Variables

inputs:
- $PAR_{t}$ photosynthetically active radiation [MJ ha⁻¹]
  

state variables:
- $B_{A, ts}$ aboveground biomass of each species [kg ha⁻¹] and the sum of all species $B_{totA, t}$ [kg ha⁻¹]
  
- $H_{ts}$ height of each species [m]
  

intermediate variables:
- $LAI_{tot, t}$ total leaf area index [-]
  
- $LAI_{ts}$ leaf area index of each species [-]
  
- $FPAR_{t}$ fraction of the photosynthetically active radiation that is intercepted by the plants
  
- $H_{cwm, t}$ community weighted mean height [m]
  

morphological traits:
- $sla_s$ specific leaf area [m² g⁻¹]
  
- $lbp_s$ leaf biomass per aboveground plant biomass [-]
  

:::

## Visualization {#Visualization}
- Combined effects of the total leaf area index on the fraction of photosynthetically active radiation intercepted by plants and how this fraction is reduced when the community height is low due to stronger shading effects. 
  
<script setup>
    import { onMounted } from 'vue';
    import { potGrowthPlot } from './d3_plots/PotGrowth.js';
    onMounted(() => { potGrowthPlot() });
</script>

<table>
    <colgroup>
       <col>
       <col width="80px">
       <col>
    </colgroup>
    <tbody>
    <tr>
        <td>extinction coefficient γ_RUE_k</td>
        <td><span id="k-value">0.6</span></td>
        <td><input type="range" min="0.3" max="1.0" step="0.1" value="0.6" id="k"></td>
    </tr>
    <tr>
        <td>effect of community height on shading α_RUE_cwmH</td>
        <td><span id="α_comH-value">0.75</span></td>
        <td><input type="range" min="0.0" max="1" step="0.05" value="0.75" id="α_comH" class="slider"></td>
    </tr>
    <tr>
        <td>community weighted mean height H_cwm</td>
        <td><span id="H_cwm-value">0.7</span></td>
        <td><input type="range" min="0.05" max="2.0" step="0.05" value="0.7" id="H_cwm"></td>
    </tr>
    </tbody>
</table>
<div class="legend" style="margin-top: 10px;">
    <svg width="500" height="37">
        <g>
            <rect x="10" y="0" width="15" height="15" style="fill: steelblue;"></rect>
            <text x="30" y="12" class="legend-text">excluding the effect of community height</text>
            <rect x="10" y="20" width="15" height="15" style="fill: red;"></rect>
            <text x="30" y="32" class="legend-text">with the influence of the community height</text>
        </g>
    </svg>
</div>
<div style="max-width: 600px"><svg id="pot_growth_graph"></svg></div>



---

- Influence of specific leaf area and aboveground biomass proportion on the leaf area index, all species have a total biomass of 2000 [kg ha⁻¹] and the aboveground biomass is assumed to be total biomass times aboveground biomass proportion: $B_{A, ts} = B_{ts} \cdot abp_s$. Note, that during the simulation the aboveground biomass proportion is often lower than the trait $abp_s$.
  
<details>
<summary>show code</summary>


```julia
import GrasslandTraitSim as sim
using CairoMakie
using Unitful

let
    traits = sim.input_traits()
    nspecies = length(traits.sla)
    LAIs = zeros(nspecies)
    biomass = fill(2000.0u"kg/ha", nspecies)
    above_biomass = traits.abp   .* biomass

    for s in eachindex(LAIs)
        LAIs[s] = uconvert(NoUnits, traits.sla[s] * above_biomass[s] * traits.lbp[s])
    end

    idx = sortperm(traits.sla)
    LAIs_sorted = LAIs[idx]
    sla = ustrip.(traits.sla[idx])

    abp = (traits.abp)[idx]
    colorrange = (minimum(abp), maximum(abp))
    colormap = :viridis

    fig = Figure()
    ax = Axis(fig[1, 1]; xlabel = "Specific leaf area [m² g⁻¹]", ylabel = "Leaf area index [-]", title = "")
    sc = scatter!(sla, LAIs_sorted, color = abp, colormap = colormap)
    Colorbar(fig[1,2], sc; label = "Aboveground biomass per total biomass [-]")

end
```

</details>



![](sla_lai.png)


## API {#API}
<details class='jldocstring custom-block' open>
<summary><a id='GrasslandTraitSim.potential_growth!' href='#GrasslandTraitSim.potential_growth!'><span class="jlbinding">GrasslandTraitSim.potential_growth!</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
potential_growth!(
;
    container,
    above_biomass,
    actual_height,
    PAR
)

```


Calculate the total potential growth of the plant community.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/FelixNoessler/GrasslandTraitSim.jl/blob/8fcf43661af2b44d618f4d4a9ad9c58c594c000a/src/3_biomass/1_growth/2_community_potential_growth.jl#L1" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='GrasslandTraitSim.calculate_LAI!' href='#GrasslandTraitSim.calculate_LAI!'><span class="jlbinding">GrasslandTraitSim.calculate_LAI!</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
calculate_LAI!(; container, above_biomass)

```


Calculate the leaf area index of all species.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/FelixNoessler/GrasslandTraitSim.jl/blob/8fcf43661af2b44d618f4d4a9ad9c58c594c000a/src/3_biomass/1_growth/2_community_potential_growth.jl#L39" target="_blank" rel="noreferrer">source</a></Badge>

</details>

