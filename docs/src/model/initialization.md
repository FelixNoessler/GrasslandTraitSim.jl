```@meta
CurrentModule=GrasslandTraitSim
```

# Initialization

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


```@docs
input_WHC_PWP!
```

## Set the initial conditions of the state variables

```@docs
set_initialconditions!
```