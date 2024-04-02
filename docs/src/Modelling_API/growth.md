```@meta
CurrentModule=GrasslandTraitSim
```

# Growth

```@raw html
<div class="mermaid">
flowchart LR
    A[[potential growth]] ==> D(actual growth)
    B[[community adjustment by environmental and seasonal factors]] ==> D
    C[[species-specific adjustment]] ==> D
    subgraph " "
    L[↓ radiation] -.-> B
    M[↓ temperature] -.-> B
    N[⇅ seasonal factor] -.-> B
    end
    subgraph " "
    F[⇅ light competition] -.-> C
    G[belowground competition] -.-> H
    G -.-> I
    H[↓ water stress] -.-> C
    I[↓ nutrient stress] -.-> C
    end;
</div>
```

```@docs
growth!
```

```@raw html
<script type="module">
    import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs';
</script> 
```