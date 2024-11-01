```@meta
CurrentModule=GrasslandTraitSim
```

# Species-specific growth adjustment - Investments into roots

```@raw html
<script setup>
    import { onMounted } from 'vue';
    import { RSACostsPlot, AMCCostsPlot } from './d3_plots/RootCosts.js';
    onMounted(() => { RSACostsPlot(); AMCCostsPlot(); });
</script>
```

The root investment factor ``ROOT_{txys}`` [-], which reduces growth, is described by:

```math
\begin{align}
    ROOT_{txys} &= ROOT_{RSA, txys} \cdot ROOT_{AMC, txys} \\
    ROOT_{RSA, txys} &= 1 - \kappa_{RSA} + \kappa_{RSA} \cdot \exp\left(\frac{\log(0.5)}{\phi_{RSA} \cdot TRSA_{txys}} \right) \\
    ROOT_{AMC, txys} &= 1 - \kappa_{AMC} + \kappa_{AMC} \cdot \exp\left(\frac{\log(0.5)}{\phi_{AMC} \cdot TAMC_{txys}} \right) \\
    TRSA_{txys} &= \frac{B_{B, txys}}{B_{txys}} \cdot  RSA_s \\
    TAMC_{txys} &= \frac{B_{B, txys}}{B_{txys}} \cdot  AMC_s  
\end{align}
```

:::tabs

== Parameter

- ``\phi_{RSA}`` reference trait value [m² g⁻¹]
- ``\phi_{AMC}`` reference trait value [-]
- ``\kappa_{RSA}`` maximum reduction in growth [-]
- ``\kappa_{AMC}`` maximum reduction in growth [-]
see also [`SimulationParameter`](@ref)

== Variables

state variables:
- ``B_{B, txys}`` belowground biomass of each species [kg ha⁻¹]
- ``B_{txys}`` biomass of each species [kg ha⁻¹]

intermediate variables:
- ``ROOT_{RSA, txys}`` growth reduction due to investment in root surface area per total biomass [-]
- ``ROOT_{AMC, txys}`` growth reduction due to investment in arbuscular mycorrhizal colonisation rate per total biomass [-]
- ``TRSA_{txys}`` root surface area per total biomass of each species [m² g⁻¹] 
- ``TAMC_{txys}`` arbuscular mycorrhizal colonisation rate per total biomass of each species [-] 

morphological traits:
- ``RSA_s`` root surface area per belowground biomass of each species [m² g⁻¹]
- ``AMC_s`` arbuscular mycorrhizal colonisation rate [-]

:::

## Visualization

- growth reduction due to investment in root surface area per total biomass

```@raw html
<table>
    <colgroup>
       <col>
       <col width="80px">
       <col>
    </colgroup>
    <tbody>
    <tr>
        <td>maximum growth reduction (κ_RSA)</td>
        <td><span id="κ_rsa-value">0.2</span></td>
        <td><input type="range" id="κ_rsa" min="0.0" max="1" step="0.01" value="0.2" class="input_rsa_cost_graph"></td>
    </tr>
    <tr>
        <td>reference trait value (ϕ_TRSA)</td>
        <td><span id="ϕ_TRSA-value">0.15</span></td>
        <td><input type="range" id="ϕ_TRSA" min="0.05" max="0.25" step="0.05" value="0.15" class="input_rsa_cost_graph"></td>
    </tr>
    </tbody>
</table>
<svg id="rsa_cost_graph"></svg>
```

- growth reduction due to investment in arbuscular mycorrhizal colonisation rate per total biomass

```@raw html
<table>
    <colgroup>
       <col>
       <col width="80px">
       <col>
    </colgroup>
    <tbody>
    <tr>
        <td>maximum growth reduction (κ_AMC)</td>
        <td><span id="κ_amc-value">0.2</span></td>
        <td><input type="range" id="κ_amc" min="0.0" max="1" step="0.01" value="0.2" class="input_amc_cost_graph"></td>
    </tr>
    <tr>
        <td>reference trait value (ϕ_TAMC)</td>
        <td><span id="ϕ_TAMC-value">0.2</span></td>
        <td><input type="range" id="ϕ_TAMC" min="0.1" max="0.5" step="0.05" value="0.2" class="input_amc_cost_graph"></td>
    </tr>
    </tbody>
</table>
<svg id="amc_cost_graph"></svg>
```

## API

```@docs	
root_investment!
```
