```@meta
CurrentModule=GrasslandTraitSim
```

# Senescence

```@raw html
<script setup>
    import { onMounted } from 'vue';
    import { seasonalSenescenceAjdPlot, SLASenescenceRatePlot } from './d3_plots/Senescence.js';
    onMounted(() => { 
        seasonalSenescenceAjdPlot(); 
        SLASenescenceRatePlot();
    });
</script>
```

The loss of biomass due to senescence ``S_{txys}`` [kg ha⁻¹] is defined as follows:

```math
\begin{align}
S_{txys} &= \left(1 - \left(1 - \alpha_{SEN}\right) ^ {1 / 30.44} \right) \cdot SEN_{txy} \cdot \left(\frac{sla_s}{\phi_{sla}}\right)^{\beta_{SEN,sla}}  \cdot B_{txys} \\
SEN_{txy} &= 
    \begin{cases}
    1  & \text{if}\,\,\, ST_{txy} < \psi_{SEN,ST_1} \\
    1+(\psi_{SEN\max} - 1) \frac{ST_{txy} - \psi_{SEN,ST_1}}{\psi_{SEN,ST_2} - \psi_{SEN,ST_1}} & 
        \text{if}\,\,\, \psi_{SEN,ST_1} < ST_{txy} < \psi_{SEN,ST_2} \\
    \psi_{SEN\max}  & \text{if}\,\,\, ST_{txy} > \psi_{SEN,ST_2}
    \end{cases} \\
ST_{txy} &= \sum_{i=t\bmod{365}}^{tmax} \max\left(0 °C,\, T_{ixy}\right)
\end{align}

```

The monthly senescence rate defined by ``\alpha_{SEN}`` is converted to a daily senescence rate in the first equation.

:::tabs

== Parameter

- ``\alpha_{SEN}`` senescence rater per month [-]
- ``\phi_{sla}`` reference value for the trait specific leaf area [m² g⁻¹]
- ``\beta_{SEN,sla}`` scales the influences of the specific leaf area on the senescence rate [-]
- ``\psi_{SEN,ST_1}`` when the senescence starts to increase [°C]
- ``\psi_{SEN,ST_2}`` when the senescence reaches the maximum senescence rate [°C]
- ``\psi_{SEN\max}`` maximum senescence rate [-]

== Variables

inputs:
- ``T_{txy}`` mean air temperature at a height of 2 m [°C]

state variables:
- ``B_{txys}`` biomass of each species [kg ha⁻¹]

intermediate variables:
- ``SEN_{txy}`` seasonal component of senescence [-]
- ``ST_{txy}`` cumulative temperature from the beginning of current year [°C]

morphological traits:
- ``sla_s`` specific leaf area [m² g⁻¹]

:::


### Visualization

- seasonal component ``SEN_{txy}`` of the senescence rate:

```@raw html
<table>
    <colgroup>
       <col>
       <col width="80px">
       <col>
    </colgroup>
    <tbody>
    <tr>
        <td>when the senescence starts to increase ψ_SEN_ST₁</td>
        <td><span id="psi1-value">775</span></td>
        <td><input type="range" id="psi1" min="300" max="1000" step="5" value="775" class="input_seasonal_senescence_graph"></td>
    </tr>
    <tr>
        <td>when the senescence reaches the maximum senescence rate ψ_SEN_ST₂</td>
        <td><span id="psi2-value">3000</span></td>
        <td><input type="range" id="psi2" min="2000" max="4000" step="5" value="3000" class="input_seasonal_senescence_graph"></td>
    </tr>
    <tr>
        <td>maximum senescence rate ψ_SENₘₐₓ</td>
        <td><span id="SENmax-value">2</span></td>
        <td><input type="range" id="SENmax" min="1" max="3" step="0.1" value="2" class="input_seasonal_senescence_graph"></td>
    </tr>
    </tbody>
</table>
<svg id="seasonal_senescence_graph"></svg>
```

- influence of the specific leaf area of the species on the senescence rate:

```@raw html
<table>
    <colgroup>
       <col>
       <col width="80px">
       <col>
    </colgroup>
    <tbody>
    <tr>
        <td>reference value for the trait specific leaf area ϕ_sla</td>
        <td><span id="phi_SLA-value">0.009</span></td>
        <td><input type="range" id="phi_SLA" min="0.001" max="0.02" step="0.001" value="0.009" class="input_SLA_senescence_graph"></td>
    </tr>
    <tr>
        <td>scale the influences of the specific leaf area on the senescence rate β_SEN_sla</td>
        <td><span id="beta_SEN_SLA-value">0.3</span></td>
        <td><input type="range" id="beta_SEN_SLA" min="0" max="1" step="0.1" value="0.3" class="input_SLA_senescence_graph"></td>
    </tr>
    </tbody>
</table>
<svg id="SLA_senescence_graph"></svg>
```

### API

```@docs
senescence!
initialize_senescence_rate!
seasonal_component_senescence
```