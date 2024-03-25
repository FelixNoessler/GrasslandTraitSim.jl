# Priors

```@example priors
using CairoMakie
using Statistics
using Distributions
import GrasslandTraitSim as sim

## the input object specifies which processes are included
## here we include all processes
input_obj = sim.validation_input(;
    plotID = "HEG01", nspecies = 1);
inference_obj = sim.calibrated_parameter(; input_obj)


begin
    fig = Figure(; size = (600, 6000))

    for (i,p) in enumerate(keys(inference_obj.priordists))
        Axis(fig[i, 1]; title = String(p))

        d = inference_obj.priordists[p]
        ma = quantile(d, 0.995)
        x = LinRange(0.000001, ma, 200)
        y = pdf.(d, x)
        band!(x, zeros(200), y; color = (:red, 0.3))
        lines!(x, y; color = :black, linewidth = 2)
    end

    fig
end
save("priors.svg", fig); nothing # hide
```

![](priors.svg)
