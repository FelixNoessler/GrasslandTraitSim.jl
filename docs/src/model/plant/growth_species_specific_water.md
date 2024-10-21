```@meta
CurrentModule=GrasslandTraitSim
```

# Species-specific growth adjustment - Soil water

```@raw html
<script setup>
    import { onMounted } from 'vue';
    import { plantAvailableWaterPlot, waterStressPlot } from './d3_plots/WaterStress.js';
    onMounted(() => { plantAvailableWaterPlot(); waterStressPlot(); });
</script>
```

```mermaid
flowchart LR
    W[↓ water stress WAT] 
    A["soil water content W [mm]"]
    K["water holding capacity WHC [mm]"]
    L["permanent wilting point PWP [mm]"]
    P["plant available water Wp [-]"]
    R[trait: root surface area / belowground biomass]

    A --> P
    K --> P
    L --> P
    P --> W
    R ---> W;
```

The water stress growth reducer ``WAT_{txys}`` [-] is defined as:

```math
\begin{align}
    WAT_{txys} &= 
        \begin{cases}
            0 & \text{if } W_{p, txy} = 0 \\
            1 / \left(1 + \exp\left(-\beta_{W,RSA}\cdot \left(W_{p, txy} - x_{0, W,RSA} \right)\right)\right) & \text{if } 0 < W_{p, txy} < 1 \\
            1 & \text{if } W_{p, txy} >= 1 \\
        \end{cases} \\
    x_{0, W,RSA} &= \frac{1}{\beta_{W,RSA}} \cdot \left(-\delta_{W,RSA}\cdot \left(TRSA_{txys} - \left(\frac{1}{\delta_{W,RSA}} \cdot \log\left(\frac{1 - \alpha_{W,RSA, 05}}{\alpha_{W,RSA,05}}\right) + \phi_{RSA}\right)\right)\right) + 0.5  \\
    TRSA_{txys} &= \frac{B_{B, txys}}{B_{txys}} \cdot  RSA_s  \\
    W_{p, txy} &= \frac{W_{txy} - PWP_{xy}}{WHC_{xy}-PWP_{xy}}  
\end{align}
```

:::tabs

== Parameter

- ``\phi_{RSA}`` reference trait value [m² g⁻¹]
- ``\beta_{W,RSA}`` slope of response function [-]
- ``\alpha_{W,RSA,05}`` response at ``W_{p, txy} = 0.5`` for species with the reference trait value[-]
- ``\delta_{W,RSA}`` scales the difference in the growth reducer between species [g m⁻²]
see also [`SimulationParameter`](@ref)

== Variables

state variables:
- ``B_{B, txys}`` belowground biomass of each species [kg ha⁻¹]
- ``B_{txys}`` biomass of each species [kg ha⁻¹]
- ``W_{txy}`` soil water content in the rooting zone [mm]

intermediate variables:
- ``WHC_{xy}`` water holding capacity [mm]
- ``PWP_{xy}`` permanent wilting point [mm]
- ``TRSA_{txys}`` root surface area per total biomass of each species [m² g⁻¹] 
- ``W_{p, txy} \in [0, 1]`` plant available water [-]

morphological traits:
- ``RSA_s`` root surface area per belowground biomass of each species [m² g⁻¹]

:::


## Visualization

- scaling of the soil water content in the rooting zone by permanent wilting point and water holding capacity

```@raw html
<table>
    <colgroup>
        <col>
        <col width="80px">
        <col>
    </colgroup>
    <tbody>
    <tr>
        <td>permanent wilting point (PWP)</td>
        <td><span id="PWP-value">1</span></td>
        <td><input type="range" min="25" max="105" step="1" value="50" id="PWP" class="plant_av_water_input"></td>
    </tr>
    <tr>
        <td>water holding capacity (WHC)</td>
        <td><span id="WHC-value">1</span></td>
        <td><input type="range" min="85" max="205" step="1" value="120" id="WHC" class="plant_av_water_input"></td>
    </tr>
    </tbody>
</table>
<svg id="plant_av_water_graph"></svg>
``` 

- growth reducer

```@raw html
<table>
    <colgroup>
        <col>
        <col width="80px">
        <col>
    </colgroup>
    <tbody>
    <tr>
        <td>response at Wₚ = 0.5 for species with the reference trait value (α_WRSA05) <br>(strong to weak growth reduction)</td>
        <td><span id="ɑ_R_05-value">0.9</span></td>
        <td><input type="range" id="ɑ_R_05" min="0.1" max="0.999" step="0.001" value="0.9" class="input_water_stress_graph"></td>
    </tr>
    <tr>
        <td>difference between species (δ_WRSA) <br>(no to strong difference)</td>
        <td><span id="δ_R-value">10</span></td>
        <td><input type="range" id="δ_R" min="0.1" max="25.0" step="0.1" value="10" class="input_water_stress_graph"></td>
    </tr>
    <tr>
        <td>slope of response (β_WRSA)</td>
        <td><span id="β_R-value">7</span></td>
        <td><input type="range" id="β_R" min="3" max="10" step="0.1" value="7" class="input_water_stress_graph"></td>
    </tr>
    <tr>
        <td>reference trait value (ϕ_RSA)</td>
        <td><span id="phi_RSA-value">0.15</span></td>
        <td><input type="range" id="phi_RSA" min="0.05" max="0.25" step="0.05" value="0.15" class="input_water_stress_graph"></td>
    </tr>
    </tbody>
</table>

<svg id="water_stress_graph"></svg>
```



## API
```@docs
water_reduction!
```