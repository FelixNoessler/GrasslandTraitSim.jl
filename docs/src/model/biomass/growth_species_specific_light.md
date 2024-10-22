```@meta
CurrentModule=GrasslandTraitSim
```

# Species-specific growth adjustment - Light

```@raw html
<script setup>
    import { onMounted } from 'vue';
    import { lightCompetitionPlot } from './d3_plots/LightCompetition.js';
    onMounted(() => { lightCompetitionPlot() });
</script>
```

The light competition factor ``LIG_{txys}`` [-], which distributes the total potential growth of the community among all species, is defined as:
```math
\begin{align*}
    LIG_{txys} &= \frac{LAI_{txys}}{LAI_{tot, txy}} \cdot \left(\frac{H_{txys}}{H_{cwm, txy}} \right) ^ {\beta_H} \\
    H_{cwm, txy} &= \sum_{s=1}^{S}\frac{B_{txys}}{B_{tot, txy}} \cdot H_{txys}
\end{align*}
```

:::tabs

== Parameter

- ``\beta_H`` controls how strongly taller plants get more light for growth [-]
see also [`SimulationParameter`](@ref)

== Variables

state variables:
- ``B_{txys}`` biomass of each species [kg ha⁻¹]
- ``H_{txys}`` plant height of each species [m]

intermediate variables:
- ``LAI_{txys}`` leaf area index of each species [-]
- ``LAI_{tot, txy}`` total leaf area index of the community [-]
- ``H_{cwm, txy}`` community weighted mean height [m]

:::


### Visualization

- Effect of plant height on light competition

```@raw html
<table>
    <colgroup>
        <col>
        <col width="80px">
        <col>
    </colgroup>
    <tbody>
    <tr>
        <td>control how strongly taller plants get more light (β_H)</td>
        <td><span id="beta_H-value">1</span></td>
        <td><input type="range" min="0" max="2" step="0.01" value="1" id="beta_H" class="light_competition_input"></td>
    </tr>
    </tbody>
</table>
<div class="legend" style="margin-top: 10px;">
    <svg width="500" height="37">
        <g>
            <rect x="10" y="0" width="15" height="15" style="fill: steelblue;"></rect>
            <text x="30" y="12" class="legend-text">species 1, height varied on x-Axis</text>
            <rect x="10" y="20" width="15" height="15" style="fill: red;"></rect>
            <text x="30" y="32" class="legend-text">species 2, height: 0.4 m</text>
        </g>
    </svg>
</div>
<svg id="light_competition_graph"></svg>
```


### API
```@docs	
light_competition!
```