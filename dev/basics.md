
# Getting started {#Getting-started}

`GrasslandTraitSim.jl` is a Julia package for simulating plant dynamics in managed grasslands.

Author: [Felix Nößler](https://github.com/FelixNoessler/).
<br/>


Licence: [GPL-3.0](https://github.com/FelixNoessler/GrasslandTraitSim.jl/blob/master/LICENSE)

Please contact me if you have any questions about using the model or if you would like to collaborate. You can write my [an email](mailto:felix.noessler@fu-berlin.de) or open [an issue on Github](https://github.com/felixnoessler/grasslandtraitsim.jl/issues/new).

## Installation {#Installation}
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

input_obj = sim.create_input("HEG01");
p = sim.SimulationParameter();
sol = sim.solve_prob(; input_obj, p);
sol.output.biomass
```


```ansi
[90m┌ [39m[38;5;209m6210[39m×[38;5;32m70[39m DimArray{Unitful.Quantity{Float64, 𝐌 𝐋^-2, Unitful.FreeUnits{(ha^-1, kg), 𝐌 𝐋^-2, nothing}}, 2}[38;5;37m state_biomass[39m[90m ┐[39m
[90m├──────────────────────────────────────────────────────────────────────── dims ┤[39m
  [38;5;209m↓ [39m[38;5;209mtime[39m Sampled{Dates.Date} [38;5;209mDates.Date("2006-01-01"):Dates.Day(1):Dates.Date("2023-01-01")[39m [38;5;244mForwardOrdered[39m [38;5;244mRegular[39m [38;5;244mPoints[39m,
  [38;5;32m→ [39m[38;5;32mspecies[39m Sampled{Int64} [38;5;32m1:70[39m [38;5;244mForwardOrdered[39m [38;5;244mRegular[39m [38;5;244mPoints[39m
[90m└──────────────────────────────────────────────────────────────────────────────┘[39m
 [38;5;209m↓[39m [38;5;32m→[39m                    [38;5;32m1[39m                   …   [38;5;32m70[39m
  [38;5;209m2006-01-01[39m  142.0 kg ha^-1           142.0 kg ha^-1
  [38;5;209m2006-01-02[39m  141.813 kg ha^-1         141.49 kg ha^-1
  [38;5;209m2006-01-03[39m  141.626 kg ha^-1         140.981 kg ha^-1
  [38;5;209m2006-01-04[39m  141.44 kg ha^-1          140.475 kg ha^-1
 ⋮                                          ⋱    ⋮
  [38;5;209m2022-12-29[39m    0.011162 kg ha^-1        4.97722 kg ha^-1
  [38;5;209m2022-12-30[39m    0.01114 kg ha^-1         4.95627 kg ha^-1
  [38;5;209m2022-12-31[39m    0.011118 kg ha^-1        4.93311 kg ha^-1
  [38;5;209m2023-01-01[39m    0.0110961 kg ha^-1  …    4.91106 kg ha^-1
```

