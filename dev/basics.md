
# Getting started {#Getting-started}

`GrasslandTraitSim.jl` is a Julia package for simulating plant dynamics in managed grasslands.

Author: [Felix Nößler](https://github.com/FelixNoessler/).
<br/>


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


## Run simulations {#Run-simulations}

For more details, see the tutorials on [preparing inputs](/tutorials/how_to_prepare_input#How-to-prepare-the-input-data-to-start-a-simulation) and [analysing outputs](/tutorials/how_to_analyse_output#How-to-analyse-the-model-output). 

```julia
import GrasslandTraitSim as sim

trait_input = sim.input_traits();
input_obj = sim.validation_input("HEG01");
p = sim.SimulationParameter();
sol = sim.solve_prob(; input_obj, p, trait_input);
sol.output.biomass
```


```
╭──────────────────────────────────────────────────────────────────────────────╮
│ 6210×1×1×70 DimArray{Unitful.Quantity{Float64, 𝐌 𝐋^-2, Unitful.FreeUnits{(ha^-1, kg), 𝐌 𝐋^-2, nothing}},4} state_biomass │
├──────────────────────────────────────────────────────────────────────── dims ┤
  ↓ time    Sampled{Dates.Date} Dates.Date("2006-01-01"):Dates.Day(1):Dates.Date("2023-01-01") ForwardOrdered Regular Points,
  → x       Sampled{Int64} 1:1 ForwardOrdered Regular Points,
  ↗ y       Sampled{Int64} 1:1 ForwardOrdered Regular Points,
  ⬔ species Sampled{Int64} 1:70 ForwardOrdered Regular Points
└──────────────────────────────────────────────────────────────────────────────┘
[:, :, 1, 1]
 ↓ →                                   1
  2006-01-01    71.4286 kg ha^-1
  2006-01-02    71.3345 kg ha^-1
  2006-01-03    71.2406 kg ha^-1
 ⋮                    
  2022-12-29  0.0954842 kg ha^-1
  2022-12-30  0.0952987 kg ha^-1
  2022-12-31  0.0951226 kg ha^-1
  2023-01-01  0.0949421 kg ha^-1
```

