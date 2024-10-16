```@meta
CurrentModule=GrasslandTraitSim
```

# Potential growth of the community

The potential growth of the plant community ``G_{pot, txy}`` [kg ha⁻¹] is described by: 

```math
\begin{align}
    G_{pot, txy} &= PAR_{txy} \cdot RUE_{max} \cdot fPAR_{txy} \\
    fPAR_{txy} &= \left(1 - \exp\left(-k \cdot LAI_{tot, txy}\right)\right) \cdot  
    \exp\left(\frac{\log(\alpha_{comH}) \cdot 0.2 m}{H_{cwm, txy}}\right)\\
    H_{cwm, txy} &= \sum_{s=1}^{S}\frac{B_{A, txys}}{B_{totA, txy}} \cdot H_{txys} \\
    LAI_{tot, txy} &= \sum_{s=1}^{S} LAI_{txys} \\
    LAI_{txys} &= B_{A, txys} \cdot SLA_s \cdot \frac{LBP_s}{ABP_s} \cdot 0.1
\end{align}
```

In the last equation the values are converted to the dimensionless leaf area index by multiplying the term with 0.1.

:::tabs

== Parameter

- ``RUE_{max}`` maximum radiation use efficiency [kg MJ⁻¹]
- ``k`` extinction coefficient [-]
- ``\alpha_{comH} \in [0, 1]`` is the reduction factor of ``fPAR_{txy}`` if the community weighted mean height equals 0.2 m [-]
- ``\beta_{comH}`` is the slope of the logistic function that relates the community weighted mean height to the community height growth reducer [m⁻¹]
see also [`SimulationParameter`](@ref)

== Variables

inputs:
- ``PAR_{txy}`` photosynthetically active radiation [MJ ha⁻¹]

state variables:
- ``B_{A, txys}`` aboveground biomass of each species [kg ha⁻¹] and the sum of all species ``B_{totA, txy}`` [kg ha⁻¹]
- ``H_{txys}`` height of each species [m]

intermediate variables:
- ``LAI_{tot, txy}`` total leaf area index [-]
- ``LAI_{txys}`` leaf area index of each species [-]
- ``fPAR_{txy}`` fraction of the photosynthetically active radiation that is intercepted by the plants
- ``H_{cwm, txy}`` community weighted mean height [m]

morphological traits:
- ``SLA_s`` specific leaf area [m² g⁻¹]
- ``LBP_s`` leaf biomass per plant biomass [-]
- ``ABP_s`` aboveground biomass per plant biomass [-]

:::


## Visualization

- Combined effects of the total leaf area index on the fraction of photosynthetically active radiation intercepted by plants and how this fraction is reduced when the community height is low due to stronger shading effects. 

```@raw html
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
        <td>extinction coefficient (k)</td>
        <td><span id="k-value">0.6</span></td>
        <td><input type="range" min="0.3" max="1.0" step="0.1" value="0.6" id="k"></td>
    </tr>
    <tr>
        <td>effect of community height on shading (α_comH)</td>
        <td><span id="α_comH-value">0.75</span></td>
        <td><input type="range" min="0.0" max="1" step="0.05" value="0.75" id="α_comH" class="slider"></td>
    </tr>
    <tr>
        <td>community weighted mean height (H_cwm)</td>
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
<svg width="500" height="400" id="pot_growth_graph"></svg>
```

---

- Influence of specific leaf area and aboveground biomass proportion on the leaf area index 

```@example 
import GrasslandTraitSim as sim
sim.plot_lai_traits()
```

## API

```@docs
potential_growth!
calculate_LAI!
```