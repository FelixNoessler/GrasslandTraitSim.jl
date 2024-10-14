```@meta
CurrentModule=GrasslandTraitSim
```

# Biomass dynamics

```@raw html
<pre class="mermaid">
flowchart LR
    A[growth] --> B[change in biomass of one day]
    C[senescence] --> B
    D[mowing, grazing] --> B
    B --update--> K[state: biomass]
    K --+ one day--> B
</pre>

<script type="module">
    import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs';
</script> 
```

> **Note:** Forcing functions and influence of soil water are omitted in this diagram.

**The change of the biomass of the plant species is modelled by...**
- [growth processes](@ref "Growth")
- [senescence](@ref "Senescence") of biomass
- biomass removal by [mowing and grazing](@ref "Mowing and grazing")


