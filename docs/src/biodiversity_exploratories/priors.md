# Priors

```@example priors
using CairoMakie
using Statistics
using Distributions
import GrasslandTraitSim.Valid as valid

mp = valid.model_parameters()

begin
    fig = Figure(; resolution = (600, 6000))

    for p in eachindex(mp.names)
        Axis(fig[p, 1]; title = mp.names[p])

        ma = quantile(mp.prior_dists[p], 0.995)
        x = LinRange(0.000001, ma, 200)
        y = pdf.(mp.prior_dists[p], x)
        band!(x, zeros(200), y; color = (:red, 0.3))
        lines!(x, y; color = :black, linewidth = 2)
    end
end

fig
```
