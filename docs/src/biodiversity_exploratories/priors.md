# Priors

```@example priors
using PrettyTables
using CairoMakie
using Statistics
using Distributions
using Unitful
import GrasslandTraitSim as sim

inference_obj = sim.calibrated_parameter(; )
p_keys = collect(keys(inference_obj.priordists))
p_priors = collect(inference_obj.priordists)
p_priors_str = replace.(string.(p_priors), "\n" => "", "{Float64}" => "",
                        "Distributions." => "")

m = hcat(p_keys, p_priors_str, inference_obj.prior_text)

pretty_table(m; header = ["Parameter", "Prior Distribution", "Justification"],
             alignment = [:r, :l, :l], crop = :none, columns_width = [0, 40, 70], autowrap = true)
```

## Show the log density of the priors

```@example priors
begin
    fig = Figure(; size = (600, 8000))
    
    Label(fig[0, 1], "logpdf"; tellwidth = false)
    Label(fig[0, 2], "pdf"; tellwidth = false)
    p = sim.load_optim_result()

    for (i,k) in enumerate(keys(inference_obj.priordists))
        d = inference_obj.priordists[k]
        mi = quantile(d, 0.001)
        ma = quantile(d, 0.9999)
        x = collect(LinRange(mi, ma, 300))
        
        Axis(fig[i, 1]; title = String(k), yticklabelsvisible = false)
        lines!(x, logpdf.(d, x); color = :steelblue4, linewidth = 3)
        vlines!(ustrip(p[k]); color = :orange, linestyle = :dash)
        
        Axis(fig[i, 2]; yticklabelsvisible = false)
        lines!(x, pdf.(d, x); color = :steelblue4, linewidth = 3)
        vlines!(ustrip(p[k]); color = :orange, linestyle = :dash)
    end

    fig
end
save("priors.png", fig); nothing # hide
```

![](priors.png)

## Show the influence of the prior on specific functions

Run the following function several times to analyse the influence of the prior choice. Each time a new parameters values are generated from the prior. This is possible for all the images in the documentation. You can find the functions that generate the images of the documentation [here](https://github.com/FelixNoessler/GrasslandTraitSim.jl/blob/master/docs/make.jl).

```@example priors
sim.plot_N_amc(; θ = sim.add_units(sim.sample_prior(; inference_obj = sim.calibrated_parameter(;))))
```