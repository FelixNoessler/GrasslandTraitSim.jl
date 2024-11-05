```@meta
CurrentModule=GrasslandTraitSim
```

# Species-specific growth adjustment - Light

```@raw html
<script setup>
    import { onMounted } from 'vue';
    import { lightCompetitionSimplePlot, lightCompetitionHeightLayerPlot } from './d3_plots/LightCompetition.js';
    onMounted(() => { 
        lightCompetitionSimplePlot();
        lightCompetitionHeightLayerPlot(); });
</script>
```

We define two different methods for distributing the total potential growth of the community among all species. In both methods, the result is defined in the light comptetition factor ``LIG_{txys}`` [-].

**Method 1:** Simple light competition, implemented in [`light_competition_simple!`](@ref)

```math
\begin{align*}
    LIG_{txys} &= \frac{LAI_{txys}}{LAI_{tot, txy}} \cdot \left(\frac{H_{txys}}{H_{cwm, txy}} \right) ^ {\beta_H} \\
    H_{cwm, txy} &= \sum_{s=1}^{S}\frac{B_{txys}}{B_{tot, txy}} \cdot H_{txys}
\end{align*}
```

**Method 2:** Use vertical height layers, implemented in [`light_competition_height_layer!`](@ref)

We divide the grassland sward into layers of 0.05 [m] height. We calculate the leaf area index of each species in each layer and calculate the total leaf area in each layer ``LAI_{layer,txy}`` [-]. We can then calculate the leaf area index of all the layers above a layer ``LAI_{abovelayer,txy}`` [-]. With this value we can calculate the amount of light reaching a layer with ``exp(-\gamma_{RUE,k} * LAI_{abovelayer,txy})``. For each layer, the fraction of light reaching a layer is multiplied by the fraction intercepted in a layer ``(1 - \exp(-\gamma_{RUE,k} * LAI_{layer,txy})``. We distribute this fraction of light intercepted in a layer to all species according to their leaf area index fraction in the layer. The light intercepted by each plant species is summed over all layers. This value is divided by ``1 - \exp(-γ_{RUE,k} * LAI_{tot,txy})`` to obtain ``LIG_{txys}`` and to satisfy ``\sum_{s=1}^{S} LIG_{txys} = 1``.

:::tabs

== Parameter

- ``\beta_H`` controls how strongly taller plants get more light for growth, only used in the simple method [-]
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

- Effect of plant height on light competition for the simple light competition

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

- Effect of plant height on light competition for the height layer method

```@raw html
<table>
    <colgroup>
       <col>
       <col width="80px">
       <col>
    </colgroup>
    <tbody>
    <tr>
        <td>Leaf area index species 1 [-]</td>
        <td><span id="LAI1-value"></span></td>
        <td><input type="range" id="LAI1" min="0.0" max="4" step="0.01" value="2" class="input_height_layer_graph"></td>
    </tr>
    <tr>
        <td>Leaf area index species 2 [-]</td>
        <td><span id="LAI2-value"></span></td>
        <td><input type="range" id="LAI2" min="0.0" max="4" step="0.01" value="2" class="input_height_layer_graph"></td>
    </tr>
    <tr>
        <td>Height species 1 [m]</td>
        <td><span id="H1-value"></span></td>
        <td><input type="range" id="H1" min="0.0" max="1.5" step="0.01" value="0.5" class="input_height_layer_graph"></td>
    </tr>
    <tr>
        <td>Height species 2 [m]</td>
        <td><span id="H2-value"></span></td>
        <td><input type="range" id="H2" min="0.0" max="1.5" step="0.01" value="0.5" class="input_height_layer_graph"></td>
    </tr>
    <tr>
        <td>Light extinction coefficient γ_RUE_k [-]</td>
        <td><span id="γ_RUE_k-value"></span></td>
        <td><input type="range" id="γ_RUE_k" min="0.4" max="0.8" step="0.01" value="0.6" class="input_height_layer_graph"></td>
    </tr>
    </tbody>
</table>
<svg id="totalIntercepted_graph"></svg>
<svg id="height_layer_graph"></svg>
```

### API
```@docs	
light_competition!
light_competition_simple!
light_competition_height_layer!
```