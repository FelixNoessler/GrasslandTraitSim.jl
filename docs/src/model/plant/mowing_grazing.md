```@meta
CurrentModule=GrasslandTraitSim
```

# Mowing and grazing

Biomass is removed by...
- 🚜 [mowing](@ref "Mowing")
- 🐄 [grazing](@ref "Grazing")

----
## Mowing

```@docs
mowing!
```

----
## Grazing

```@raw html
<script setup>
    import { onMounted } from 'vue';
    import { grazingPlot } from './d3_plots/Grazing.js';
    onMounted(() => { grazingPlot() });
</script>

<table>
    <colgroup>
        <col>
        <col width="80px">
        <col>
    </colgroup>
    <tbody>
    <tr>
        <td>η_GRZ</td>
        <td><span id="η_GRZ-value">2</span></td>
        <td><input type="range" min="0.1" max="20" step="0.1" value="1" id="η_GRZ"></td>
    </tr>
    <tr>
        <td>Livestock Density (LD)</td>
        <td><span id="LD-value">2</span></td>
        <td><input type="range" min="0.1" max="5" step="0.1" value="2" id="LD" class="slider"></td>
    </tr>
    <tr>
        <td>Maximal Consumption (κ)</td>
        <td><span id="κ-value">22</span></td>
        <td><input type="range" min="12" max="25" step="1" value="22" id="κ"></td>
    </tr>
    </tbody>
</table>

<svg width="600" height="400" id="grazing_graph"></svg> 
```

```@docs
grazing!
```