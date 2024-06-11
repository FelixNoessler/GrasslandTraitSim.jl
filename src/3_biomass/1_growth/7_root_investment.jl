@doc raw"""

Investment into root and mycorriza


```math
\begin{align}
invest &= \exp(\kappa\_{red, amc} \cdot acm) \cdot abp \\
\end{align}
```

![](../img/root_investment.png)
"""
function root_investment!(; container)
    @unpack included = container.simp
    @unpack root_invest_amc, root_invest_srsa, root_invest, above_proportion = container.calc
    @unpack amc, srsa = container.traits
    @unpack output = container
    @unpack κ_maxred_amc, κ_maxred_srsa, β_red_amc, β_red_rsa, ϕ_amc, ϕ_rsa = container.p

    # TODO add to documentation
    if !included.root_invest
        @. root_invest_srsa = 1.0
        @. root_invest_amc = 1.0
    else
        @. root_invest_amc = 1 - κ_maxred_amc / (1 + exp(-β_red_amc * ((1-above_proportion)*amc - ϕ_amc)))
        @. root_invest_srsa = 1 - κ_maxred_srsa / (1 + exp(-β_red_rsa * ((1-above_proportion)*srsa - ϕ_rsa)))
    end

    @. root_invest = root_invest_amc * root_invest_srsa

    return nothing
end

function plot_root_investment(; θ = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; θ)
    @unpack p = container
    container.calc.above_proportion .= mean(container.traits.abp)

    ########## artifical traits - for line
    nspecies_line = 100
    _, container_line = create_container_for_plotting(; θ, nspecies = nspecies_line)
    container_line.traits.amc .= LinRange(0, 0.8, nspecies_line)
    container_line.traits.srsa .= LinRange(0, 0.4, nspecies_line)u"m^2 / g"
    container_line.calc.above_proportion .= mean(container.traits.abp)

    colormap = (:viridis, 0.3)

    fig = Figure(size = (600, 700))
    Axis(fig[1, 1];
         ylabel = "Growth reduction due to\ninvestment in mycorrhiza\n← stronger reduction, less reduction →",
         xlabel = "Arbuscular mycorrhizal colonisation rate (amc) [-]",
         limits = (nothing, nothing, -0.05, 1.05))
    colorrange = (0.0, maximum([p.κ_maxred_amc, p.κ_maxred_srsa, 0.3]))

    root_investment!(; container)
    root_investment!(; container=container_line)

    root_invest_amc_l = copy(container_line.calc.root_invest_amc)
    root_invest_srsa_l = copy(container_line.calc.root_invest_srsa)

    for x in LinRange(0.0, colorrange[2], 12)
        container_line.p.κ_maxred_amc = x
        root_investment!(; container = container_line)
        lines!(container_line.traits.amc, container_line.calc.root_invest_amc;
               color = x, colorrange, colormap)
    end
    Colorbar(fig[1, 2]; colorrange, label = "κ_maxred_amc [-]")

    lines!(container_line.traits.amc, root_invest_amc_l; color = p.κ_maxred_amc,
           colorrange)
    scatter!(container.traits.amc, container.calc.root_invest_amc; color = p.κ_maxred_amc,
             colorrange)

    Axis(fig[2, 1];
              ylabel = "Growth reduction due to\ninvestment in root surface area per\nbelowground biomass\n← stronger reduction, less reduction →",
              xlabel = "Root surface area per belowground biomass (srsa) [-]",
              limits = (nothing, nothing, -0.05, 1.05))
    for x in LinRange(0, colorrange[2], 12)
        container_line.p.κ_maxred_srsa = x
        root_investment!(; container = container_line)
        lines!(ustrip.(container_line.traits.srsa), container_line.calc.root_invest_srsa;
               color = x, colorrange, colormap)
    end
    Colorbar(fig[2, 2]; colorrange, label = "κ_maxred_srsa [-]")

    lines!(ustrip.(container_line.traits.srsa), root_invest_srsa_l;
           color =  p.κ_maxred_srsa, colorrange)
    scatter!(ustrip.(container.traits.srsa), container.calc.root_invest_srsa;
             color = p.κ_maxred_srsa, colorrange)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
