```@meta
CurrentModule = GrasslandTraitSim
```

# Parameter


## Model Parameter
```@docs
SimulationParameter
```

## Simulation settings

| Parameter    | Description                                                                    | used in                    |
| ------------ | ------------------------------------------------------------------------------ | -------------------------- |
| `nspecies`   | number of species                                                              | -                          |
| `npatches`   | number of quadratic patches within one site                                    | -                          |
| `trait_seed` | seed for the generation of traits, if `missing` then seed is selected randomly | [`random_traits!`](@ref)   |

