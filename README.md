# GrasslandTraitSim.jl

[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://github.com/FelixNoessler/GrasslandTraitSim.jl/blob/master/LICENSE) [![Ask Us Anything\ !](https://img.shields.io/badge/Ask%20me-anything-1abc9c.svg)](https://github.com/felixnoessler/grasslandtraitsim.jl/issues/new)

A Julia package for simulating grassland dynamics.

Author: [Felix Nößler](https://github.com/FelixNoessler/)

Please refer to the documentation for more information about the grassland simulation model:

| Version | Documentation link |  
|:---|:---|
| in development | [![](https://img.shields.io/badge/docs-dev-blue.svg)](https://felixnoessler.github.io/GrasslandTraitSim.jl/dev/)  |  
| newest stable version  |  [![](https://img.shields.io/badge/docs-stable-blue.svg)](https://felixnoessler.github.io/GrasslandTraitSim.jl/)    | 
| version 1.0.0 | [![](https://img.shields.io/badge/docs-1.0.0-blue.svg)](https://felixnoessler.github.io/GrasslandTraitSim.jl/v1.0.0/) | 

When using the package, please cite the following publication:  

Nößler, F., Moulin, T., Buzhdygan, O., Tietjen, B., and May, F.: A trait-based model to describe plant community dynamics in managed grasslands (GrasslandTraitSim.jl v1.0.0), Geosci. Model Dev., 18, 7077–7128, https://doi.org/10.5194/gmd-18-7077-2025, 2025. 

## Quick install

1. [Download Julia](https://julialang.org/downloads/).

2. Launch Julia and type

```julia
import Pkg
Pkg.add("GrasslandTraitSim")
```

## Run simulations

```julia
import GrasslandTraitSim as sim

# sim.load_data("your_directory_with_input_data")
input_obj = sim.create_input("HEG01");
p = sim.optim_parameter();
sol = sim.solve_prob(; input_obj, p);
sol.output.biomass
```

