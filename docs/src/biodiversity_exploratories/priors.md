# Priors

```@example priors
using CairoMakie
using Statistics
using Distributions
import GrasslandTraitSim as sim

inference_obj = sim.calibrated_parameter(; )
p_keys = collect(keys(inference_obj.priordists))
p_priors = collect(inference_obj.priordists)
m = hcat(p_keys, p_priors, inference_obj.prior_text)

pretty_table(m; header = ["Parameter", "Prior Distribution", "Justification"],
             alignment = [:r, :l, :l], crop = :none, columns_width = [0, 50, 70], autowrap = true)
```

## Show the log density of the priors

```@example priors
begin
    fig = Figure(; size = (600, 8000))

    for (i,p) in enumerate(keys(inference_obj.priordists))
        d = inference_obj.priordists[p]
        ma = quantile(d, 0.9999)
        x = collect(LinRange(0.0, ma, 300))
        y = logpdf.(d, x)
        f = isinf.(y)
        y[f] .= NaN
        x[f] .= NaN
        
        Axis(fig[i, 1]; title = String(p), yticklabelsvisible = false)
        lines!(x, y; color = :steelblue4, linewidth = 3)
        
        Axis(fig[i, 2]; yticklabelsvisible = false)
        lines!(x, pdf.(d, x); color = :steelblue4, linewidth = 3)
    end

    fig
end
save("priors.svg", fig); nothing # hide
```

![](priors.svg)
