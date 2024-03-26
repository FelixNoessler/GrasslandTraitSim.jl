```@meta
CurrentModule=GrasslandTraitSim
```

# Water dynamics

```@raw html
<pre class="mermaid">
flowchart LR
    A[precipitation] --> B[change in soil water of one day]
    C[evapotranspiration] --> B
    J[evaporation] --> C
    L[transpiration] --> C
    D[runoff/drainage] --> B
    B --update--> K[state: soil water]
    K --+ one day--> B
</pre>

<script type="module">
    import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs';
</script> 
```

```@docs
change_water_reserve
transpiration
evaporation
```
