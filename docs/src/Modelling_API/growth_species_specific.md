```@meta
CurrentModule=GrasslandTraitSim
```

# Species-specific growth adjustment

```@raw html
<div class="mermaid">
flowchart LR
    F[⇅ light competition] --> C[[species-specific adjustment]]
    H[↓ water stress] -->  C
    I[↓ nutrient stress] --> C
    L[↓ cost for investment into roots] --> C;
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

----
## Water stress

```@raw html
<div class="mermaid">
flowchart LR
    W[↓ water stress] 
    A["soil water content W [mm]"]
    K["water holding capacity WHC [mm]"]
    L["permanent wilting point PWP [mm]"]
    P["scaled soil water content Wsc [-]"]
    R[trait: root surface area /\n belowground biomass]

    A --> P
    K --> P
    L --> P
    P --> W
    R ---> W;
</div>
```

The species differ in their response to water stress by the different trait values of the specific leaf area and the root surface areas per above ground biomass. The values of both response functions are multiplied to get factor that reduces the growth. 

It is implemented in [`water_reduction!`](@ref).

```@raw html
<iframe src="../water_stress_animation.html" width="750" height="600" scrolling="no"></iframe> 
```

```@docs
water_reduction!
```

## Nutrient stress

```@raw html
<div class="mermaid">
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
</div>
```

### [Nutrient competition factor](@id below_competition)


```@raw html
<iframe src="../nutrient_adjustment_animation.html" width="750" height="500" scrolling="no"></iframe> 
```

```@docs
below_ground_competition!
```

### Growth reduction due to nutrient stress
The species differ in the response to nutrient availability by different proportion of mycorrhizal colonisations and root surface per above ground biomass. The maximum of both response curves is used for the nutrient reduction function. It is assumed that the plants needs either many fine roots per above ground biomass or have a strong symbiosis with mycorrhizal fungi. 

It is implemented in [`nutrient_reduction!`](@ref).


```@raw html
<iframe src="../nutrient_stress_rsa_animation.html" width="750" height="600" scrolling="no"></iframe> 
```

```@raw html
<iframe src="../nutrients_stress_amc_animation.html" width="750" height="600" scrolling="no"></iframe> 
```

```@docs
nutrient_reduction!
```

```@raw html
<script type="module">
    import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs';
</script> 
```

## Cost for investment into roots and mycorrhiza

```@docs	
root_investment!
```
