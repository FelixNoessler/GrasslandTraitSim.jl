# Getting started

`GrasslandTraitSim.jl` is a Julia package for simulating plant dynamics in managed grasslands.

Author: [Felix Nößler](https://github.com/FelixNoessler/).
```@raw html 
<br/>
```
Licence: [GPL-3.0](https://github.com/FelixNoessler/GrasslandTraitSim.jl/blob/master/LICENSE)

Please contact me if you have any questions about using the model or if you would like to collaborate. You can write my [an email](mailto:felix.noessler@fu-berlin.de) or open [an issue on Github](https://github.com/felixnoessler/grasslandtraitsim.jl/issues/new).

## Installation

1. [Download Julia](https://julialang.org/downloads/).
2. Launch Julia and type

```julia
import Pkg
Pkg.add("GrasslandTraitSim")
```

For the tutorials you will also need several other Julia packages:
```julia
Pkg.add(["CairoMakie", "GLMakie", "Unitful", "Statistics", "DimensionalData"])
```


## Run simulations

For more details, see the tutorials on [preparing inputs](@ref "How to prepare the input data to start a simulation") and [analysing outputs](@ref "How to analyse the model output"). 

```@example
import GrasslandTraitSim as sim

input_obj = sim.create_input("HEG01");
p = sim.SimulationParameter();
sol = sim.solve_prob(; input_obj, p);
sol.output.biomass
```

