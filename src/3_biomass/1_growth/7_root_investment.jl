@doc raw"""

Investment into root and mycorriza


```math
\begin{align}
invest &= \exp(\kappa\_{red, amc} \cdot acm) \cdot abp \\
\end{align}
```

![](../img/root_investment.png)
"""
function root_investment!(; input_obj, prealloc, p)
    @unpack included = input_obj.simp
    @unpack root_invest_amc, root_invest_srsa, root_invest = prealloc.calc
    @unpack amc, srsa = prealloc.traits
    @unpack output = prealloc
    @unpack κ_maxred_amc, κ_maxred_srsa, β_red_amc, β_red_rsa = p

    if !included.root_invest
        @. root_invest_srsa = 1.0
        @. root_invest_amc = 1.0
    else
        @. root_invest_amc = 1 - κ_maxred_amc / (1 + exp(-β_red_amc * (amc - p.ϕ_amc)))
        @. root_invest_srsa = 1 - κ_maxred_srsa / (1 + exp(-β_red_rsa * (srsa - p.ϕ_rsa)))
    end

    @. root_invest = root_invest_amc * root_invest_srsa

    return nothing
end

function plot_root_investment(; θ = nothing, path = nothing)
    p = SimulationParameter()

    if !isnothing(θ)
        for k in keys(θ)
            p[k] = θ[k]
        end
    end

    ########## real trait data - for scatter
    real_traits = input_traits()
    nspecies = length(real_traits.amc)
    input_obj = validation_input(; plotID = "HEG01", nspecies)
    prealloc = preallocate_vectors(; input_obj)
    @reset prealloc.traits = real_traits

    ########## artifical traits - for line
    nspecies_line = 100
    artificial_traits = (; amc = LinRange(0, 0.8, nspecies_line),
                         srsa = LinRange(0, 0.4, nspecies_line)u"m^2 / g")
    artificial_input_obj = validation_input(; plotID = "HEG01", nspecies = nspecies_line)
    artificial_prealloc = preallocate_vectors(; input_obj = artificial_input_obj)
    artificial_prealloc.traits.srsa .= artificial_traits.srsa
    artificial_prealloc.traits.amc .= artificial_traits.amc

    colormap = (:viridis, 0.1)

    fig = Figure(size = (800, 900))
    Axis(fig[1, 1];
         ylabel = "Growth reduction due to\ninvestment in mycorrhiza\n← stronger reduction, less reduction →",
         xlabel = "Arbuscular mycorrhizal colonisation rate (amc) [-]",
         limits = (nothing, nothing, -0.05, 1.05))
    colorrange = (0.0, maximum([p.κ_maxred_amc, p.κ_maxred_srsa, 0.3]))

    root_investment!(; input_obj, prealloc, p)
    root_investment!(; input_obj = artificial_input_obj, prealloc = artificial_prealloc, p)
    actual_rootinvest_amc_l = copy(artificial_prealloc.calc.root_invest_amc)
    actual_rootinvest_amc = copy(prealloc.calc.root_invest_amc)
    orig_κ_maxred_amc = p.κ_maxred_amc
    actual_rootinvest_srsa = copy(prealloc.calc.root_invest_srsa)
    actual_rootinvest_srsa_l = copy(artificial_prealloc.calc.root_invest_srsa)
    orig_κ_maxred_srsa = p.κ_maxred_srsa


    for x in LinRange(0.0, colorrange[2], 12)
        p.κ_maxred_amc = x
        root_investment!(; input_obj = artificial_input_obj, prealloc = artificial_prealloc, p)
        lines!(artificial_traits.amc, artificial_prealloc.calc.root_invest_amc;
               color = x, colorrange, colormap)
        root_investment!(; input_obj, prealloc, p)
        scatter!(real_traits.amc, prealloc.calc.root_invest_amc;
            color = x, colorrange, colormap)
    end
    Colorbar(fig[1, 2]; colorrange, label = "κ_maxred_amc [-]")

    lines!(artificial_traits.amc, actual_rootinvest_amc_l; color = orig_κ_maxred_amc,
           colorrange)
    scatter!(real_traits.amc, actual_rootinvest_amc; color = orig_κ_maxred_amc,
             colorrange)

    Axis(fig[2, 1];
              ylabel = "Growth reduction due to\ninvestment in root surface area per\nbelowground biomass\n← stronger reduction, less reduction →",
              xlabel = "Root surface area per belowground biomass (srsa) [-]",
              limits = (nothing, nothing, -0.05, 1.05))
    for x in LinRange(0, colorrange[2], 12)
        p.κ_maxred_srsa = x
        root_investment!(; input_obj = artificial_input_obj, prealloc = artificial_prealloc, p)
        lines!(ustrip.(artificial_traits.srsa), artificial_prealloc.calc.root_invest_srsa;
               color = x, colorrange, colormap)
        root_investment!(; input_obj, prealloc, p)
        scatter!(ustrip.(real_traits.srsa), prealloc.calc.root_invest_srsa;
            color = x, colorrange, colormap)
    end
    Colorbar(fig[2, 2]; colorrange, label = "κ_maxred_srsa [-]")

    lines!(ustrip.(artificial_traits.srsa), actual_rootinvest_srsa_l;
           color = Float64(orig_κ_maxred_srsa), colorrange)
    scatter!(ustrip.(real_traits.srsa), actual_rootinvest_srsa;
             color = orig_κ_maxred_srsa, colorrange)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
