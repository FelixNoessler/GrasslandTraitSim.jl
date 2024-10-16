# GrasslandTraitSim.jl

[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://felixnoessler.github.io/GrasslandTraitSim.jl/dev/) [![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

A Julia package for simulating grassland dynamics.

Author: [Felix Nößler](https://github.com/FelixNoessler/)\
Licence: [GPL-3.0](https://github.com/FelixNoessler/GrasslandTraitSim.jl/blob/master/LICENSE)

Please refer to the [documentation](https://felixnoessler.github.io/GrasslandTraitSim.jl/dev/) for more information about the grassland simulation model.

Here are slides from presentations that show concepts of the models:
- [European Conference on Ecological Modelling 2023](assets/ECEM_2023_presentation.pdf)
- [Biodiversity Exploratories Assembly 2024](assets/Assembly_2024_presentation.pdf)

![](assets/biomass_dynamic_overview.png)

## Quick install

1. [Download Julia](https://julialang.org/downloads/).

2. Launch Julia and type

```julia
import Pkg
Pkg.add(url="https://github.com/felixnoessler/GrasslandTraitSim.jl")
```

> **_Compatibility:_** The simulations were tested with `Julia` 1.10. I recommend using this version.

For more information on installing unregistered packages, see [the Julia documentation](https://pkgdocs.julialang.org/v1/managing-packages/#Adding-unregistered-packages). You can browse the releases of `GrasslandTraitSim.jl` [here](https://github.com/FelixNoessler/GrasslandTraitSim.jl/releases). 

## Run simulations

```julia
import GrasslandTraitSim as sim

trait_input = sim.input_traits();
nspecies = length(trait_input.amc)
input_obj = sim.validation_input(; plotID = "HEG01", nspecies);
p = sim.SimulationParameter();
sol = sim.solve_prob(; input_obj, p, trait_input);
sol.output.biomass
```

