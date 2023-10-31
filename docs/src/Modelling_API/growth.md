# Growth

the net growth of the plants is modelled by...
- the [potential growth!](@ref pot_growth) that is multiplied by some [growth reducer functions](@ref reducer_functions) and a [belowground competition function](@ref below_competition), these processes are included in the main function [`Growth.growth!`](@ref)
- [Leaf senescence](@ref)
- [Agricultural defoliation](@ref)

```@docs
Growth.growth!
```

---
## [Potential growth](@id pot_growth)

```@docs
Growth.potential_growth!
Growth.calculate_LAI
```

----
## [Reducer functions](@id reducer_functions)
The growth of each plant species in each patch is dependent on... 
- ☀ the photosynthetically active radiation [`Growth.radiation_reduction`](@ref)
- 🌡 the air temperature [`Growth.temperature_reduction`](@ref)
- 💧 the [soil water content](@ref water_stress)
- the [plant-available nutrients](@ref nut_stress)
- 📈 a seasonal effect, that is modelled by the accumulated degree days [`Growth.seasonal_reduction`](@ref)


```@docs
Growth.radiation_reduction
Growth.temperature_reduction
Growth.water_reduction!
Growth.nutrient_reduction!
Growth.seasonal_reduction
```
--
## [Influence of plant height](@id plant_height)

Taller plants get more light and can therefore growth more than smaller plants. 
This is modelled by the influence of the potential height in relation to the community 
weighted mean potential height.

The potential height refers to the height that the plant would reach 
if it would not be limited by other factors.

```@docs	
Growth.height_influence!
```

--
## [Below-ground competition](@id below_competition)

```@docs
Growth.below_ground_competition!
```
--- 
## Leaf senescence

```@docs
Growth.senescence!
Growth.seasonal_component_senescence
```

---
## Agricultural defoliation

Biomass is removed by...
- 🐄 [`Growth.grazing!`](@ref) and [`Growth.trampling!`](@ref)
- 🚜 [`Growth.mowing!`](@ref)


```@docs
Growth.grazing!
Growth.mowing!
Growth.trampling!
Growth.calculate_relbiomass!
```
--- 


## Clonal growth
    
```@docs
Growth.clonalgrowth!
```