```@meta
CurrentModule=GrasslandTraitSim
```

# Community growth adjustment by environmental and seasonal factors

The functions limit the growth of all plant species without any species-specific reduction:
```mermaid
flowchart LR
    B[[community adjustment by environmental and seasonal factors]]
    L[↓ radiation] -.-> B
    M[↓ temperature] -.-> B
    N[⇅ seasonal factor] -.-> B
click L "growth_env_factors#Radiation-influence" "Go"
click M "growth_env_factors#Temperature-influence" "Go"
click N "growth_env_factors#Seasonal-effect" "Go"
```

## Radiation influence
### Visualization
### API
```@docs
radiation_reduction!
```

## Temperature influence
### Visualization
### API
```@docs
temperature_reduction!
```

## Seasonal effect
a seasonal effect, that is modelled by the accumulated degree days

### Visualization
### API

```@docs
seasonal_reduction!
```