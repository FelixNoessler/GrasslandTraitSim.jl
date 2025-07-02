


# Species-specific growth adjustment - Light {#Species-specific-growth-adjustment-Light}
<script setup>
    import { onMounted } from 'vue';
    import { lightCompetitionPlot, HeightLayerPlot } from './d3_plots/LightCompetition.js';
    onMounted(() => { 
        lightCompetitionPlot();
        HeightLayerPlot();  
    });
</script>


We derive the proportion of light intercepted by each species out of the total light intercepted by dividing the sward into vertical height layers of constant width, by default $0.05 m$: 

$$\begin{align}
    LIG_{ts} &= \sum_{z = l}^{L} LIG_{t,l} \\
    LIG_{ts,l} &= INT_{t,l} \cdot \frac{LAI_{ts,l}}{LAI_{tot,t,l}} \cdot \frac{1}{1 - \exp(\gamma_{RUE,k} \cdot LAI_{tot,t})} \\
    INT_{t,l} &= \exp\left(\gamma_{RUE,k} \cdot \sum_{z = l+1}^{L} LAI_{tot,t,z}\right) \cdot \left(1 - \exp\left(\gamma_{RUE,k} \cdot LAI_{tot,t,l}\right)\right) 
\end{align}$$

:::tabs

== Parameter
- $\beta_{LIG,H}$ controls how strongly taller plants get more light for growth, only used in the first method without height layers [-]
  
- $\gamma_{RUE,k}$ light extinction coefficient, only used in the method with height layers [-]
  

== Variables

state variables:
- $B_{ts}$ biomass of each species [kg ha⁻¹]
  
- $H_{ts}$ plant height of each species [m]
  

intermediate variables:
- $LAI_{ts}$ leaf area index of each species [-]
  
- $LAI_{tot, t}$ total leaf area index of the community [-]
  
- $H_{cwm, t}$ community weighted mean height [m]
  
- $LIG_{ts,l}$ light competition factor in the vertical layer $l$ [-]
  
- $LAI_{ts, l}$ leaf area index of each species in the vertical layer $l$ [-]
  
- $LAI_{tot, t, l}$ total leaf area index of the community in the vertical layer $l$ [-]
  
- $INT_{t,l}$ light interception in the vertical layer $l$ [-]
  

:::

### Visualization {#Visualization}
- Effect of plant height on light competition:
  
<table>
    <colgroup>
        <col>
        <col width="80px">
        <col>
    </colgroup>
    <tbody>
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

- Visualization of the light competition in the height layers
  
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


### API {#API}
<details class='jldocstring custom-block' open>
<summary><a id='GrasslandTraitSim.light_competition!' href='#GrasslandTraitSim.light_competition!'><span class="jlbinding">GrasslandTraitSim.light_competition!</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
light_competition!(
;
    container,
    above_biomass,
    actual_height
)

```


Calculate the distribution of potential growth to each species based on share of the leaf area index and the height of each species.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/FelixNoessler/GrasslandTraitSim.jl/blob/95dfc85525ff6ba5d69ef0c4ffbd50ee9d9825b3/src/3_biomass/1_growth/3_light_competition.jl#L1" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='GrasslandTraitSim.light_competition_height_layer!' href='#GrasslandTraitSim.light_competition_height_layer!'><span class="jlbinding">GrasslandTraitSim.light_competition_height_layer!</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
light_competition_height_layer!(; container, actual_height)

```


Divide the grassland into vertical layers and calculate the light competition for each layer.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/FelixNoessler/GrasslandTraitSim.jl/blob/95dfc85525ff6ba5d69ef0c4ffbd50ee9d9825b3/src/3_biomass/1_growth/3_light_competition.jl#L27" target="_blank" rel="noreferrer">source</a></Badge>

</details>

