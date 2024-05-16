function plot_root_investment(; path = nothing)
    nspecies = 43
    p = SimulationParameter()
    input_obj = validation_input(; plotID = "HEG01", nspecies)
    real_traits = input_traits()

    prealloc = preallocate_vectors(; input_obj)
    artificial_traits = (; amc = LinRange(0, 1, nspecies),
                         rsa = fill(mean(real_traits.rsa), nspecies))
    prealloc = @set prealloc.traits = artificial_traits

    prealloc_real = deepcopy(prealloc)
    real_traits.amc .= sort(real_traits.amc)
    real_traits.abp .= real_traits.abp[sortperm(real_traits.amc)]
    prealloc_real = @set prealloc.traits = real_traits

    fig = Figure(size = (800, 900))
    Axis(fig[1, 1];
         ylabel = "Growth reduction due to\ninvestment in mycorrhiza\n← stronger reduction, less reduction →",
         xlabel = "Arbuscular mycorrhizal colonisation rate (amc) [-]",)
    colorrange = (0.0, 2.0)
    p.κ_red_rsa = 0u" g / m^2"
    for κ_red_amc in LinRange(0, 2, 7)
        p.κ_red_amc = κ_red_amc
        root_investment!(; input_obj, prealloc, p)
        lines!(artificial_traits.amc, prealloc.calc.root_invest;
               color = κ_red_amc,
               colorrange)
        root_investment!(; input_obj, prealloc = prealloc_real, p)
        scatter!(real_traits.amc, prealloc_real.calc.root_invest;
            color = κ_red_amc,
            colorrange)
    end
    Colorbar(fig[1, 2]; colorrange, label = "κ_red_amc [-]")


    artificial_traits = (; amc = fill(mean(real_traits.amc), nspecies),
        rsa = LinRange(0.1, 0.3, nspecies)u"m^2 / g" )
    prealloc = @set prealloc.traits = artificial_traits
    p.κ_red_amc = 0

    Axis(fig[2, 1];
              ylabel = "Growth reduction due to\ninvestment in rootsurface area per\naboveground biomass\n← stronger reduction, less reduction →",
              xlabel = "Arbuscular mycorrhizal colonisation rate (amc) [-]",)
    colorrange = (0.0, 5.0)
    for κ_red_rsa in LinRange(0, 5, 7)
        p.κ_red_rsa = κ_red_rsa * u" g / m^2"
        root_investment!(; input_obj, prealloc, p)
        lines!(ustrip.(artificial_traits.rsa), prealloc.calc.root_invest;
               color = κ_red_rsa,
               colorrange)
        root_investment!(; input_obj, prealloc = prealloc_real, p)
        scatter!(ustrip.(real_traits.rsa), prealloc_real.calc.root_invest;
            color = κ_red_rsa,
            colorrange)
    end
    Colorbar(fig[2, 2]; colorrange, label = "κ_red_rsa [-]")

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
