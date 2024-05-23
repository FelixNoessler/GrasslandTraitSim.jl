function plot_root_investment(; path = nothing)
    p = SimulationParameter()
    real_traits = input_traits()
    nspecies = length(real_traits.amc)
    input_obj = validation_input(; plotID = "HEG01", nspecies)

    prealloc = preallocate_vectors(; input_obj)
    artificial_traits = (; amc = LinRange(0, 0.8, nspecies),
                         srsa = fill(mean(real_traits.srsa), nspecies))
    prealloc = @set prealloc.traits = artificial_traits

    prealloc_real = deepcopy(prealloc)
    real_traits.amc .= sort(real_traits.amc)
    real_traits.abp .= real_traits.abp[sortperm(real_traits.amc)]
    prealloc_real = @set prealloc.traits = real_traits

    fig = Figure(size = (800, 900))
    Axis(fig[1, 1];
         ylabel = "Growth reduction due to\ninvestment in mycorrhiza\n← stronger reduction, less reduction →",
         xlabel = "Arbuscular mycorrhizal colonisation rate (amc) [-]",
         limits = (nothing, nothing, -0.05, 1.05))
    colorrange = (0.0, 0.3)
    for κ_maxred_amc in LinRange(0.0, 0.3, 7)
        p.κ_maxred_amc = κ_maxred_amc
        root_investment!(; input_obj, prealloc, p)
        lines!(artificial_traits.amc, prealloc.calc.root_invest_amc;
               color = κ_maxred_amc,
               colorrange)
        root_investment!(; input_obj, prealloc = prealloc_real, p)
        scatter!(real_traits.amc, prealloc_real.calc.root_invest_amc;
            color = κ_maxred_amc,
            colorrange)
    end
    Colorbar(fig[1, 2]; colorrange, label = "κ_maxred_amc [-]")


    artificial_traits = (; amc = fill(mean(real_traits.amc), nspecies),
        srsa = LinRange(0.05, 0.4, nspecies)u"m^2 / g" )
    prealloc = @set prealloc.traits = artificial_traits

    Axis(fig[2, 1];
              ylabel = "Growth reduction due to\ninvestment in root surface area per\nbelowground biomass\n← stronger reduction, less reduction →",
              xlabel = "Root surface area per belowground biomass (srsa) [-]",
              limits = (nothing, nothing, -0.05, 1.05))
    colorrange = (0, 0.3)
    for κ_maxred_srsa in LinRange(0, 0.3, 7)
        p.κ_maxred_srsa = κ_maxred_srsa
        root_investment!(; input_obj, prealloc, p)
        lines!(ustrip.(artificial_traits.srsa), prealloc.calc.root_invest_srsa;
               color = κ_maxred_srsa,
               colorrange)
        root_investment!(; input_obj, prealloc = prealloc_real, p)
        scatter!(ustrip.(real_traits.srsa), prealloc_real.calc.root_invest_srsa;
            color = κ_maxred_srsa,
            colorrange)
    end
    Colorbar(fig[2, 2]; colorrange, label = "κ_maxred_srsa [-]")

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
