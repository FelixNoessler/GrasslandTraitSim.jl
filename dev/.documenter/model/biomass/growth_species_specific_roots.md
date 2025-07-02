


# Species-specific growth adjustment - Investments into roots {#Species-specific-growth-adjustment-Investments-into-roots}
<script setup>
    import { onMounted } from 'vue';
    import { RSACostsPlot, AMCCostsPlot } from './d3_plots/RootCosts.js';
    onMounted(() => { RSACostsPlot(); AMCCostsPlot(); });
</script>


The root investment factor $ROOT_{ts}$ [-], which reduces growth, is described by:

$$\begin{align}
    ROOT_{ts} &= ROOT_{rsa,ts} \cdot ROOT_{amc,ts} \\
    ROOT_{rsa,ts} &= 1 - \kappa_{ROOT,rsa} + \kappa_{ROOT,rsa} \cdot \exp\left(\frac{\log(0.5)}{\phi_{TRSA} \cdot TRSA_{ts}} \right) \\
    ROOT_{amc,ts} &= 1 - \kappa_{ROOT,amc} + \kappa_{ROOT,amc} \cdot \exp\left(\frac{\log(0.5)}{\phi_{TAMC} \cdot TAMC_{ts}} \right) \\
    TRSA_{ts} &= \frac{B_{B, ts}}{B_{ts}} \cdot  rsa_s \\
    TAMC_{ts} &= \frac{B_{B, ts}}{B_{ts}} \cdot  amc_s  
\end{align}$$

:::tabs

== Parameter
- $\phi_{TRSA}$ reference trait value [m² g⁻¹]
  
- $\phi_{TAMC}$ reference trait value [-]
  
- $\kappa_{ROOT,rsa}$ maximum reduction in growth [-]
  
- $\kappa_{ROOT,amc}$ maximum reduction in growth [-]
  

== Variables

state variables:
- $B_{B, ts}$ belowground biomass of each species [kg ha⁻¹]
  
- $B_{ts}$ biomass of each species [kg ha⁻¹]
  

intermediate variables:
- $ROOT_{rsa,ts}$ growth reduction due to investment in root surface area per total biomass [-]
  
- $ROOT_{amc,ts}$ growth reduction due to investment in arbuscular mycorrhizal colonisation rate per total biomass [-]
  
- $TRSA_{ts}$ root surface area per total biomass of each species [m² g⁻¹] 
  
- $TAMC_{ts}$ arbuscular mycorrhizal colonisation rate per total biomass of each species [-] 
  

morphological traits:
- $rsa_s$ root surface area per belowground biomass of each species [m² g⁻¹]
  
- $amc_s$ arbuscular mycorrhizal colonisation rate [-]
  

:::

## Visualization {#Visualization}
- growth reduction due to investment in root surface area per total biomass
  
<table>
    <colgroup>
       <col>
       <col width="80px">
       <col>
    </colgroup>
    <tbody>
    <tr>
        <td>maximum growth reduction (κ_ROOT_rsa)</td>
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

- growth reduction due to investment in arbuscular mycorrhizal colonisation rate per total biomass
  
<table>
    <colgroup>
       <col>
       <col width="80px">
       <col>
    </colgroup>
    <tbody>
    <tr>
        <td>maximum growth reduction (κ_ROOT_rsa)</td>
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


## API {#API}
<details class='jldocstring custom-block' open>
<summary><a id='GrasslandTraitSim.root_investment!' href='#GrasslandTraitSim.root_investment!'><span class="jlbinding">GrasslandTraitSim.root_investment!</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
root_investment!(; container)

```


Growth reducer due to cost of investment in roots and mycorriza.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/FelixNoessler/GrasslandTraitSim.jl/blob/8fcf43661af2b44d618f4d4a9ad9c58c594c000a/src/3_biomass/1_growth/6_root_investment.jl#L1" target="_blank" rel="noreferrer">source</a></Badge>

</details>

