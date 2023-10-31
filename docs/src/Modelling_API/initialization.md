```@meta
CurrentModule=GrasslandTraitSim
```

# Initialization

The function [`initialization`](@ref) is called once at the beginning of the simulation. 
The [traits](@ref "Initialization of traits") of the species are generated, the 
[parameters](@ref "Initialization of parameters") are initialized 
and the [initial conditions of the state variables](@ref "Set the initial conditions of the state variables") 
are set.

Furthermore, the neighbours and the surrounding (own patch and neighbours) are set for each patch with 
[`set_neighbours_surroundings!`](@ref). This is needed for [clonal growth](@ref Growth.clonalgrowth!).

```@docs
initialization
set_neighbours_surroundings!
```

## Initialization of traits




```@docs
Traits.random_traits!
Traits.similarity_matrix!
```

## Initialization of parameters

Many parameters are given at the start the simulation. However, some parameters
are dependent on input parameters and of the generated traits 
and are initialized at the start of the simulation.

The species-specific parameters are:

- `μ`: [senescence rate](@ref Growth.senescence_rate!) [d⁻¹]
- `ρ`: [palatability](@ref Growth.grazing_parameter!) [-]

```@docs
Growth.senescence_rate!
Growth.grazing_parameter!
```

**Initializing parameters for the functional response**

The species-specific parameters are:



```@docs
FunctionalResponse.sla_water_response!
FunctionalResponse.rsa_above_water_response!
FunctionalResponse.rsa_above_nut_response!
FunctionalResponse.amc_nut_response
```

**Initialization of patch-specific parameters**

The patch specific parameters are: 

- water holding capacity `WHC` [mm]
- permanent wilting point `PWP` [mm]
- nutrients [-]

```@docs
derive_WHC_PWP_nutrients!
input_WHC_PWP
input_nutrients!
planar_gradient!
```

## Set the initial conditions of the state variables
```@docs
set_initialconditions!
```