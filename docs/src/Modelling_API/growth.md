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
    F[⇅ height influence] -.-> C
    G[below ground competition] -.-> H
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

```@docs
radiation_reduction
temperature_reduction
seasonal_reduction
```

--
## Species-specific adjustment

```@raw html
<div class="mermaid">
flowchart LR
    F[⇅ height influence] --> C[[species-specific adjustment]]
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
    F[⇅ height influence] --> C[[species-specific adjustment]]
</div>
```

Taller plants get more light and can therefore growth more than smaller plants. 
This is modelled by the influence of the potential height in relation to the community 
weighted mean potential height.

The potential height refers to the height that the plant would reach 
if it would not be limited by other factors.

```@docs	
height_influence!
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
```

----
### [Water stress](@id water_stress)

```@raw html
<div class="mermaid">
flowchart LR
    W[↓ water stress] 
    E[below ground competition]
    A["soil water content [mm]"]
    K["water holding capacity [mm]"]
    L["permanent wilting point[mm]"]
    P[plant available water]
    M[adjusted plant available water]
    H["potential evapotranspiration [mm]"]
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

The species differ in the response to water stress by the different [specific leaf areas](@ref sla) and [root surface areas per above ground biomass](@ref rsa_above_water). The values of both response curves are multiplied to get factor that reduces the plant available water.

It is implemented in [`water_reduction!`](@ref).

```@docs
water_reduction!
plant_available_water!
```

---
#### [Specific leaf area linked to water stress](@id sla) 

- the core of the functional response is build in [`sla_water_response!`](@ref)
- the strength of the reduction is modified by the parameter `max_SLA_water_reduction` in [`sla_water_reduction!`](@ref)

`max_SLA_water_reduction` equals 1:
![Graphical overview of the functional response](../img/sla_water_response.svg)

`max_SLA_water_reduction` equals 0.5:
![Graphical overview of the functional response](../img/sla_water_response_0_5.svg)

```@docs
sla_water_reduction!
```

--- 
#### [Root surface area / aboveground biomass linked to water stress](@id rsa_above_water)

- the core of the functional response is build in [`rsa_above_water_response!`](@ref)
- the strength of the reduction is modified by the parameter `max_rsa_above_water_reduction` in [`rsa_above_water_reduction!`](@ref)

`max_rsa_above_water_reduction` equals 1:
![Graphical overview of the functional response](../img/rsa_above_water_response.svg)

`max_rsa_above_water_reduction` equals 0.5:
![Graphical overview of the functional response](../img/rsa_above_water_response_0_5.svg)

```@docs
rsa_above_water_reduction!
```

### [Nutrient stress](@id nut_stress)

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

The species differ in the response to nutrient availability by different proportion of [mycorrhizal colonisations ](@ref amc) and [root surface per above ground biomass](@ref rsa_above_nut). The maximum of both response curves is used for the nutrient reduction function. It is assumed that the plants needs either many fine roots per above ground biomass or have a strong symbiosis with mycorrhizal fungi. 

It is implemented in [`nutrient_reduction!`](@ref).

```@docs
nutrient_reduction!
```

---
#### [Arbuscular mycorrhizal colonisation linked to nutrient stress](@id amc)

- the core of the functional response is build in [`amc_nut_response`](@ref)
- the strength of the reduction is modified by the parameter `max_AMC_nut_reduction` in [`amc_nut_reduction!`](@ref)

`max_AMC_nut_reduction` equals 1:
![Graphical overview of the AMC functional response](../img/amc_nut_response.svg)

`max_AMC_nut_reduction` equals 0.5:
![Graphical overview of the AMC functional response](../img/amc_nut_response_0_5.svg)

```@docs
amc_nut_reduction!
```


---
#### [Root surface area / aboveground biomass linked to nutrient stress](@id rsa_above_nut)

- the core of the functional response is build in [`rsa_above_nut_response!`](@ref)
- the strength of the reduction is modified by the parameter `max_rsa_above_nut_reduction` in [`rsa_above_nut_reduction!`](@ref)

`max_rsa_above_nut_reduction` equals 1:
![Graphical overview of the functional response](../img/rsa_above_nut_response.svg)

`max_rsa_above_nut_reduction` equals 0.5:
![Graphical overview of the functional response](../img/rsa_above_nut_response_0_5.svg)


```@docs
rsa_above_nut_reduction!
```

```@raw html
<script type="module">
    import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs';
</script> 
```