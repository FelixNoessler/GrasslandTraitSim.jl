```@meta
CurrentModule=GrasslandTraitSim
```

# Species-specific growth adjustment - Nutrients


```@raw html
<script setup>
    import { onMounted } from 'vue';
    import { nutrientAdjustmentPlot, nutrientStressRSAPlot, nutrientStressAMCPlot } from './d3_plots/NutrientStress.js';
    onMounted(() => { 
        nutrientAdjustmentPlot();
        nutrientStressRSAPlot();
        nutrientStressAMCPlot();
    });
</script>
```

```mermaid
flowchart LR
    S[↓ nutrient stress] 
    N[nutrient index]
    R[trait: root surface area /\n belowground biomass]
    A[trait: arbuscular mycorrhizal colonisation]
    K[nutrient adjustment]
    L[plant available nutrients]

    N --> L
    K --> L
    L --> S
    R --> S
    A --> S;

    B[biomass] 
    T[trait similarity of\n root surface area / aboveground biomass\nand arbuscular mycorrhizal colonisation]


    T -->|species with similar\ntraits compete more\nstrongly for the same resources| K
    B --> K;
```

## [Nutrient competition factor](@id below_competition)

### Visualization
```@raw html
<table>
    <colgroup>
       <col>
       <col width="80px">
       <col>
    </colgroup>
    <tbody>
    <tr>
        <td>TSBmax</td>
        <td><span id="TSB_max-value">10000</span></td>
        <td><input type="range" id="TSB_max" min="5000" max="40000" step="500" value="10000" class="nutrient_adjustment_graph_graph"></td>
    </tr>
    <tr>
        <td>nutadj_max</td>
        <td><span id="nutadj_max-value">4.0</span></td>
        <td><input type="range" id="nutadj_max" min="1.0" max="5.0" step="0.1" value="4.0" class="nutrient_adjustment_graph_graph"></td>
    </tr>
    </tbody>
</table>

<svg width="600" height="400" id="nutrient_adjustment_graph"></svg>
```

### API
```@docs
below_ground_competition!
```

## Growth reduction due to nutrient stress
The species differ in the response to nutrient availability by different proportion of mycorrhizal colonisations and root surface per above ground biomass. The maximum of both response curves is used for the nutrient reduction function. It is assumed that the plants needs either many fine roots per above ground biomass or have a strong symbiosis with mycorrhizal fungi. 

### Visualization
```@raw html
<table>
    <colgroup>
       <col>
       <col width="80px">
       <col>
    </colgroup>
    <tbody>
    <tr>
        <td>mean response at \(N_p = 0.5\) \(\;\alpha_{nrsa,05}\;\)<br>see red dot (strong to weak growth reduction)</td>
        <td><span id="ɑ_RSA_05-value">0.9</span></td>
        <td><input type="range" id="ɑ_RSA_05" min="0.1" max="0.999" step="0.001" value="0.9" class="input_nutrient_rsa_graph"></td>
    </tr>
    <tr>
        <td>difference between species \(\;\delta_{nrsa}\;\) <br>(no to strong difference)</td>
        <td><span id="δ_RSA-value">10</span></td>
        <td><input type="range" id="δ_RSA" min="0.1" max="25.0" step="0.1" value="10" class="input_nutrient_rsa_graph"></td>
    </tr>
    <tr>
        <td>slope of response  \(\beta_{nrsa}\)</td>
        <td><span id="β_RSA-value">7</span></td>
        <td><input type="range" id="β_RSA" min="3" max="10" step="0.1" value="7" class="input_nutrient_rsa_graph"></td>
    </tr>
    </tbody>
</table>

<svg id="nutrient_rsa_graph"></svg>
```

```@raw html
<table>
    <colgroup>
       <col>
       <col width="80px">
       <col>
    </colgroup>
    <tbody>
        <tr>
            <td>mean response at \(N_p = 0.5\) \(\;\alpha_{namc,05}\;\)<br>see red dot (strong to weak growth reduction)</td>
            <td><span id="ɑ_AMC_05-value">0.9</span></td>
            <td><input type="range" id="ɑ_AMC_05" min="0.1" max="0.999" step="0.001" value="0.9" class="input_nutrient_amc_graph"></td>
        </tr>
        <tr>
            <td>difference between species \(\;\delta_{namc}\;\) <br>(no to strong difference)</td>
            <td><span id="δ_AMC-value">10</span></td>
            <td><input type="range" id="δ_AMC" min="0.1" max="15.0" step="0.1" value="8" class="input_nutrient_amc_graph"></td>
        </tr>
        <tr>
            <td>slope of response  \(\beta_{namc}\)</td>
            <td><span id="β_AMC-value">7</span></td>
            <td><input type="range" id="β_AMC" min="3" max="10" step="0.1" value="7" class="input_nutrient_amc_graph"></td>
        </tr>
    </tbody>
</table>

<svg id="nutrient_amc_graph"></svg>
```

### API
```@docs
nutrient_reduction!
```
