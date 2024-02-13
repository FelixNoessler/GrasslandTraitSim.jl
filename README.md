# GrasslandTraitSim.jl

[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://felixnoessler.github.io/GrasslandTraitSim.jl/dev/) [![SciML Code Style](https://img.shields.io/badge/code%20style-SciML-blue)](https://github.com/SciML/SciMLStyle) [![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

A Julia package for simulating grassland dynamics.

Author: [Felix Nößler](https://github.com/FelixNoessler/)\
Licence: [GPL-3.0](https://github.com/FelixNoessler/GrasslandTraitSim.jl/blob/master/LICENSE)

Please refer to the [documentation](https://felixnoessler.github.io/GrasslandTraitSim.jl/dev/) for more information about the grassland simulation model.

Here are slides from presentations that show concepts of the models:
- [ECEM 2023](assets/ECEM_2023_presentation.pdf)


## Quick install

1. [Download Julia](https://julialang.org/downloads/).

2. Launch Julia and type

```julia
import Pkg
Pkg.add(url="https://github.com/felixnoessler/GrasslandTraitSim.jl")
```

> **_Compatibility:_** The simulations were tested with `Julia` 1.10. I recommend using this version.

For more information on installing unregistered packages, see [here](https://pkgdocs.julialang.org/v1/managing-packages/#Adding-unregistered-packages). Here, you can browse the different versions of `GrasslandTraitSim.jl`: [tags](https://github.com/FelixNoessler/GrasslandTraitSim.jl/tags). 

## Run simulations

```julia
import GrasslandTraitSim as sim
import GrasslandTraitSim.Valid as valid

input_obj = valid.validation_input(; plotID = "HEG01", nspecies = 25);
p = sim.parameter(; input_obj)
sol = sim.solve_prob(; input_obj, p);
```

## Start the GUI for checking the calibration results

```julia
using GLMakie
import GrasslandTraitSim as sim
import GrasslandTraitSim.Valid as valid
import GrasslandTraitSim.Vis as vis
GLMakie.activate!()

vis.dashboard(; sim, valid)
```

![](img/screenshot.png)
