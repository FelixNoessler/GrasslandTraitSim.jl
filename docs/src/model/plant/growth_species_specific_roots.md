```@meta
CurrentModule=GrasslandTraitSim
```

# Species-specific growth adjustment - Investments into roots

```@raw html
<script setup>
    import { onMounted } from 'vue';
    import { rootCostsPlot } from './d3_plots/RootCosts.js';
    onMounted(() => { rootCostsPlot()});
</script>
```


## Visualization

```@raw html
<table>
    <colgroup>
       <col>
       <col width="80px">
       <col>
    </colgroup>
    <tbody>
    <tr>
        <td>κ_maxred_amc</td>
        <td><span id="κ_maxred_amc-value">0.2</span></td>
        <td><input type="range" id="κ_maxred_amc" min="0.0" max="1" step="0.01" value="0.2" class="input_root_cost_graph"></td>
    </tr>
    <tr>
        <td>ϕ_amc</td>
        <td><span id="ϕ_amc-value">0.2</span></td>
        <td><input type="range" id="ϕ_amc" min="0.1" max="0.5" step="0.05" value="0.2" class="input_root_cost_graph"></td>
    </tr>
    </tbody>
</table>

<svg width="600" height="400" id="root_cost_graph"></svg>
```


## API

```@docs	
root_investment!
```
