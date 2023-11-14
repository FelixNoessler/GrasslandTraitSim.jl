```@meta
CurrentModule=GrasslandTraitSim
```

# Biomass dynamics

```@raw html
<pre class="mermaid">
flowchart LR
    A[growth] --> B[change in biomass]
    C[senescence] --> B
    D[mowing, grazing, trampling] --> B
    E["clonal growth\n(once per year)"] --> B
</pre>

<script type="module">
    import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs';
</script> 
```

The change of the biomass of the plant species is modelled by...
- [growth processes](@ref "Growth")
- [senescence](@ref "Senescence") of biomass
- biomass removal by [mowing, grazing, and trampling](@ref "Mowing, grazing, and trampling")
- once per year and only if more than one patch is simulated: [clonal growth](@ref "Clonal growth")


