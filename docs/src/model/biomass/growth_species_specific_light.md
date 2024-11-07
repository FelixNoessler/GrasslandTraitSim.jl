```@meta
CurrentModule=GrasslandTraitSim
```

# Species-specific growth adjustment - Light

```@raw html
<script setup>
    import { onMounted } from 'vue';
    import { lightCompetitionPlot, HeightLayerPlot } from './d3_plots/LightCompetition.js';
    onMounted(() => { 
        lightCompetitionPlot();
        HeightLayerPlot();  
    });
</script>
```

We define two different methods for distributing the total potential growth of the community among all species. In both methods, the result is defined in the light comptetition factor ``LIG_{txys}`` [-].

**Method 1:** Simple light competition, implemented in [`light_competition_simple!`](@ref)

```math
\begin{align*}
    LIG_{txys} &= \frac{LAI_{txys}}{LAI_{tot, txy}} \cdot \left(\frac{H_{txys}}{H_{cwm, txy}} \right) ^ {\beta_{LIG,H}} \\
    H_{cwm, txy} &= \sum_{s=1}^{S}\frac{B_{txys}}{B_{tot, txy}} \cdot H_{txys}
\end{align*}
```

**Method 2:** Use vertical height layers, implemented in [`light_competition_height_layer!`](@ref)

In the second method, we derive the proportion of light intercepted by each species out of the total light intercepted by dividing the sward into vertical height layers of constant width, by default $0.05 m$: 
```math
\begin{align}
    LIG_{txys} &= \sum_{z = l}^{L} LIG_{txy,l} \\
    LIG_{txys,l} &= INT_{txy,l} \cdot \frac{LAI_{txys,l}}{LAI_{tot,txy,l}} \cdot \frac{1}{1 - \exp(\gamma_{RUE,k} \cdot LAI_{tot,txy})} \\
    INT_{txy,l} &= \exp\left(\gamma_{RUE,k} \cdot \sum_{z = l+1}^{L} LAI_{tot,txy,z}\right) \cdot \left(1 - \exp\left(\gamma_{RUE,k} \cdot LAI_{tot,txy,l}\right)\right) 
\end{align}
```

:::tabs

== Parameter

- ``\beta_{LIG,H}`` controls how strongly taller plants get more light for growth, only used in the first method without height layers [-]
- ``\gamma_{RUE,k}`` light extinction coefficient, only used in the method with height layers [-]

== Variables

state variables:
- ``B_{txys}`` biomass of each species [kg ha⁻¹]
- ``H_{txys}`` plant height of each species [m]

intermediate variables:
- ``LAI_{txys}`` leaf area index of each species [-]
- ``LAI_{tot, txy}`` total leaf area index of the community [-]
- ``H_{cwm, txy}`` community weighted mean height [m]
- ``LIG_{txys,l}`` light competition factor in the vertical layer ``l`` [-]
- ``LAI_{txys, l}`` leaf area index of each species in the vertical layer ``l`` [-]
- ``LAI_{tot, txy, l}`` total leaf area index of the community in the vertical layer ``l`` [-]
- ``INT_{txy,l}`` light interception in the vertical layer ``l`` [-]

:::


### Visualization

- Effect of plant height on light competition for the simple method (darker colours) and the method with height layers (brighter colours). To simplify matters in the visualization for the simple method, we use the leaf area index fraction to calculate the community-weighted mean height.
```@raw html
<table>
    <colgroup>
        <col>
        <col width="80px">
        <col>
    </colgroup>
    <tbody>
     <tr>
        <td>simple method: control how strongly taller plants get more light β_LIG_H</td>
        <td><span id="beta_H-value"></span></td>
        <td><input type="range" min="0" max="2" step="0.01" value="1" id="beta_H" class="light_competition_input"></td>
    </tr>
    <tr>
        <td>layer method: light extinction coefficient γ_RUE_k [-]</td>
        <td><span id="γRUEk-value"></span></td>
        <td><input type="range" id="γRUEk" min="0.4" max="0.8" step="0.01" value="0.6" class="light_competition_input"></td>
    </tr>
    <tr>
        <td>Leaf area index species 1</td>
        <td><span id="LAI_1-value"></span></td>
        <td><input type="range" min="0.01" max="4" step="0.01" value="1" id="LAI_1" class="light_competition_input"></td>
    </tr>
    <tr>
        <td>Leaf area index species 2</td>
        <td><span id="LAI_2-value"></span></td>
        <td><input type="range" min="0.01" max="4" step="0.01" value="1" id="LAI_2" class="light_competition_input"></td>
    </tr>
    <tr>
        <td>Height species 2</td>
        <td><span id="H_2-value"></span></td>
        <td><input type="range" min="0.01" max="1.5" step="0.01" value="1" id="H_2" class="light_competition_input"></td>
    </tr>
    </tbody>
</table>
simple method:
<div class="legend" style="margin-top: 10px;">
    <svg width="500" height="37">
        <g>
            <rect x="10" y="0" width="15" height="15" style="fill: steelblue;"></rect>
            <text x="30" y="12" class="legend-text">species 1, height varied on x-Axis</text>
            <rect x="10" y="20" width="15" height="15" style="fill: red;"></rect>
            <text x="30" y="32" class="legend-text">species 2</text>
        </g>
    </svg>
</div>
layer method:
<div class="legend" style="margin-top: 10px;">
    <svg width="500" height="37">
        <g>
            <rect x="10" y="0" width="15" height="15" style="fill: lightblue;"></rect>
            <text x="30" y="12" class="legend-text">species 1, height varied on x-Axis</text>
            <rect x="10" y="20" width="15" height="15" style="fill: coral;"></rect>
            <text x="30" y="32" class="legend-text">species 2</text>
        </g>
    </svg>
</div>
<svg id="light_competition_graph"></svg>
```

- Visualization of the light competition in the height layers
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
<svg id="height_layer_graph"></svg>
```

### API
```@docs	
light_competition!
light_competition_simple!
light_competition_height_layer!
```