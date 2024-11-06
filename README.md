# GrasslandTraitSim.jl

[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://felixnoessler.github.io/GrasslandTraitSim.jl/dev/) [![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) [![Ask Us Anything\ !](https://img.shields.io/badge/Ask%20me-anything-1abc9c.svg)](https://github.com/felixnoessler/grasslandtraitsim.jl/issues/new)

A Julia package for simulating grassland dynamics.

Author: [Felix Nößler](https://github.com/FelixNoessler/)\
Licence: [GPL-3.0](https://github.com/FelixNoessler/GrasslandTraitSim.jl/blob/master/LICENSE)

Please refer to the [documentation](https://felixnoessler.github.io/GrasslandTraitSim.jl/dev/) for more information about the grassland simulation model.

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

trait_input = sim.input_traits();
input_obj = sim.validation_input(; plotID = "HEG01", nspecies = length(trait_input.amc));
p = sim.SimulationParameter();
sol = sim.solve_prob(; input_obj, p, trait_input);
sol.output.biomass
```

