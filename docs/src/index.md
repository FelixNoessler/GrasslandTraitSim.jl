# GrasslandTraitSim.jl

A Julia package for simulating grassland dynamics.

Author: [Felix Nößler](https://github.com/FelixNoessler/)\
Licence: [GPL-3.0](https://github.com/FelixNoessler/GrasslandTraitSim.jl/blob/master/LICENSE)

## Quick install

1. [Download Julia](https://julialang.org/downloads/).

2. Launch Julia and type

```@repl
using Pkg
Pkg.add(url="github.com/felixnoessler/lib/GrasslandTraitValid")
Pkg.add(url="github.com/felixnoessler/lib/GrasslandTraitVis")
Pkg.add(url="github.com/felixnoessler/GrasslandTraitSim.jl")
```

!!! note
    The simulations were tested with `Julia` 1.9.3. I recommend using this version.
    
## Run simulations

```@example sim
import GrasslandTraitSim as sim
import GrasslandTraitValid as valid
mp = valid.model_parameters();
inf_p = (; zip(Symbol.(mp.names), mp.best)...);
input_obj = valid.validation_input(; plotID = "HEG01", nspecies = 25,
                                     startyear = 2009, endyear = 2021,
                                     npatches = 1);
sol = sim.solve_prob(; input_obj, inf_p);
nothing # hide
```

### the output biomass

- with the dimension: time×patch×species

```@example sim
sol.o.biomass
```

### the output soil water content
 
- with the dimension: time×patch
 
```@example sim
sol.o.water
```


## Start the GUI

```@julia
import GrasslandTraitSim as sim
import GrasslandTraitValid as valid
import GrasslandTraitVis as vis
vis.dashboard(; sim, valid);
```
