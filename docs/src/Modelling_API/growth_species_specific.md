```@meta
CurrentModule=GrasslandTraitSim
```

# Species-specific growth adjustment

```@raw html
<div class="mermaid">
flowchart LR
    F[⇅ light competition] --> C[[species-specific adjustment]]
    G[below ground competition] --> H
    G --> I
    H[↓ water stress] -->  C
    I[↓ nutrient stress] --> C;
</div>
```


## Light competition

```@raw html
<div class="mermaid">
flowchart LR
    L[Leaf area index] -->|species with more leaf area\nget higher share| F
    K[trait: height] -->|taller plants get\nmore light| F
    F[⇅ light competition] --> C[[species-specific adjustment]]
</div>
```

```@docs	
light_competition!
```

--
## [Below-ground competition](@id below_competition)

```@raw html
<div class="mermaid">
flowchart LR
    B[biomass] 
    T[trait similarity of\n root surface area / aboveground biomass\nand arbuscular mycorrhizal colonisation]
    X["biomass · trait similarity"]
    E[below ground competition]

    T -->|species with similar\ntraits compete more\nstrongly for the same resources| X
    B --> X
    X --> E;
</div>
```

```@docs
below_ground_competition!
init_transfer_functions!
```

----
## Water stress

```@raw html
<div class="mermaid">
flowchart LR
    W[↓ water stress] 
    E["below ground competition factor D [-]"]
    A["soil water content W [mm]"]
    K["water holding capacity WHC [mm]"]
    L["permanent wilting point PWP [mm]"]
    P["scaled soil water content Wsc [-]"]
    M["plant available water W_p [-]"]
    H["potential evapotranspiration PET [mm]"]
    R[trait: root surface area /\n aboveground biomass]
    S[trait: specific leaf area]

    A --> P
    K --> P
    L --> P
    P --> M
    E --> M
    H --> M
    M --> W
    R ---> W
    S ---> W;
</div>
```

The species differ in their response to water stress by the different trait values of the specific leaf area and the root surface areas per above ground biomass. The values of both response functions are multiplied to get factor that reduces the growth. 

It is implemented in [`water_reduction!`](@ref).

```@docs
water_reduction!
```

## Nutrient stress

```@raw html
<div class="mermaid">
flowchart LR
    S[↓ nutrient stress] 
    N[nutrient index]
    R[trait: root surface area /\n aboveground biomass]
    A[trait: arbuscular mycorrhizal colonisation]
    B[belowground competition]
    L[plant available nutrients]

    N --> L
    B --> L
    L --> S
    R --> S
    A --> S;
</div>
```

The species differ in the response to nutrient availability by different proportion of mycorrhizal colonisations and root surface per above ground biomass. The maximum of both response curves is used for the nutrient reduction function. It is assumed that the plants needs either many fine roots per above ground biomass or have a strong symbiosis with mycorrhizal fungi. 

It is implemented in [`nutrient_reduction!`](@ref).

```@docs
nutrient_reduction!
```

```@raw html
<script type="module">
    import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs';
</script> 
```
