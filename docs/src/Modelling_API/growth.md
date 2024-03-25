```@meta
CurrentModule=GrasslandTraitSim
```

# Growth

```@raw html
<div class="mermaid">
flowchart LR
    A[[potential growth]] ==> D(actual growth)
    B[[adjustment by environmental factors]] ==> D
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

---
## Potential growth

```@docs
potential_growth!
calculate_LAI
```

---- 
## Adjustment by environmental factors

The listed functions limit the growth potential of all 
plant species without any species-specific reduction:
- ☀ the photosynthetically active radiation [`radiation_reduction`](@ref)
- 🌡 the air temperature [`temperature_reduction`](@ref)
- 📈 a seasonal effect, that is modelled by the accumulated degree days [`seasonal_reduction`](@ref)
- an effect that a smaller plant community can build up less biomass [`community_height_reduction`](@ref)

```@docs
radiation_reduction
temperature_reduction
seasonal_reduction
community_height_reduction
```

--
## Species-specific adjustment

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


### [Influence of plant height](@id plant_height)

```@raw html
<div class="mermaid">
flowchart LR
    K(trait: height) -->|taller plants get\nmore light| F
    F[⇅ light competition] --> C[[species-specific adjustment]]
</div>
```

Taller plants get more light and can therefore growth more than smaller plants. 
This is modelled by the influence of the potential height in relation to the community 
weighted mean potential height.

The potential height refers to the height that the plant would reach 
if it would not be limited by other factors.

```@docs	
light_competition!
```

--
### [Below-ground competition](@id below_competition)

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
### Water stress

```@raw html
<div class="mermaid">
flowchart LR
    W[↓ water stress] 
    E["below ground competition factor D [-]"]
    A["soil water content W [mm]"]
    K["water holding capacity WHC [mm]"]
    L["permanent wilting point PWP [mm]"]
    P["scaled soil water content Wsc [-]"]
    M["plant available water Wp [-]"]
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

The species differ in the response to water stress by the different [specific leaf areas](@ref "Specific leaf area linked to water stress") and [root surface areas per above ground biomass](@ref "Root surface area / aboveground biomass linked to water stress"). The values of both response curves are multiplied to get factor that reduces the plant available water.

It is implemented in [`water_reduction!`](@ref).

```@docs
water_reduction!
```

---
#### Specific leaf area linked to water stress

```@docs
```

--- 
#### Root surface area / aboveground biomass linked to water stress

```@docs
```

### Nutrient stress

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