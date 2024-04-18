```@meta
CurrentModule = GrasslandTraitSim
```

# Model Parameter

```@docs
SimulationParameter
```

# Simulation settings

| Parameter    | Description                                                                    | used in                    |
| ------------ | ------------------------------------------------------------------------------ | -------------------------- |
| `nspecies`   | number of species (plant functional types)                                     | -                          |
| `npatches`   | number of quadratic patches within one site                                    | -                          |
| `trait_seed` | seed for the generation of traits, if `missing` then seed is selected randomly | [`random_traits!`](@ref)   |
| `nutheterog` | heterogeneity of the nutrient availability within one site, only applicable if more than one patch is simulated per site | [`input_nutrients!`](@ref) |

