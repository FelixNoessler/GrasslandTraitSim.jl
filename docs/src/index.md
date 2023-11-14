# GrasslandTraitSim.jl

A Julia package for simulating grassland dynamics.

Author: [Felix Nößler](https://github.com/FelixNoessler/)\
Licence: [GPL-3.0](https://github.com/FelixNoessler/GrasslandTraitSim.jl/blob/master/LICENSE)

## Quick install

1. [Download Julia](https://julialang.org/downloads/).

2. Launch Julia and type

```@julia
import Pkg
Pkg.add(url="https://github.com/felixnoessler/GrasslandTraitSim.jl")
```

!!! compat
    The simulations were tested with `Julia` 1.9.3. I recommend using this version.
    
## Run simulations

```@julia
import GrasslandTraitSim as sim
import GrasslandTraitSim.Valid as valid
mp = valid.model_parameters();
inf_p = (; zip(Symbol.(mp.names), mp.best)...);
input_obj = valid.validation_input(; plotID = "HEG01", nspecies = 25,
                                     npatches = 1);
sol = sim.solve_prob(; input_obj, inf_p);
```

## Start the GUI

```@julia
import GrasslandTraitSim as sim
import GrasslandTraitSim.Valid as valid
import GrasslandTraitSim.Vis as vis
vis.dashboard(; sim, valid);
```
