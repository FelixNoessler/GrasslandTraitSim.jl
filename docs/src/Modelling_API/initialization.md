```@meta
CurrentModule=GrasslandTraitSim
```

# Initialization

The function [`initialization`](@ref) is called once at the beginning of the simulation. 
The [traits](@ref "Initialization of traits") of the species are generated, the 
[parameters](@ref "Initialization of parameters") are initialized 
and the [initial conditions of the state variables](@ref "Set the initial conditions of the state variables") 
are set.

```@docs
initialization
```

## Initialization of traits

```@docs
random_traits!
similarity_matrix!
```

## Initialization of parameters

Many parameters are given at the start the simulation. However, some parameters
are dependent on input parameters and of the generated traits 
and are initialized at the start of the simulation.

The species-specific parameters are:

- `μ`: [senescence rate](@ref senescence_rate!) [d⁻¹]

```@docs
senescence_rate!
```

**Initializing parameters for the functional response**

The species-specific parameters are:



**Initialization of patch-specific parameters**

The patch specific parameters are: 

- water holding capacity `WHC` [mm]
- permanent wilting point `PWP` [mm]
- nutrients [-]

```@docs
input_WHC_PWP!
input_nutrients!
planar_gradient!
```

## Set the initial conditions of the state variables

```@docs
set_initialconditions!
```