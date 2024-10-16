```@meta
CurrentModule=GrasslandTraitSim
```

# Community growth adjustment by environmental and seasonal factors
The listed functions limit the growth potential of all 
plant species without any species-specific reduction:
- ☀ the photosynthetically active radiation [`radiation_reduction!`](@ref)
- 🌡 the air temperature [`temperature_reduction!`](@ref)
- 📈 a seasonal effect, that is modelled by the accumulated degree days [`seasonal_reduction!`](@ref)

## Radiation influence
```@docs
radiation_reduction!
```

## Temperature influence
```@docs
temperature_reduction!
```

## Seasonal effect
```@docs
seasonal_reduction!
```