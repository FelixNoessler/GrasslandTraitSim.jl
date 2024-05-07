function plot_root_investment(; path = nothing)
    nspecies = 43
    p = SimulationParameter()
    input_obj = validation_input(; plotID = "HEG01", nspecies)
    real_traits = input_traits()


    prealloc = preallocate_vectors(; input_obj)
    artificial_traits = (; abp = ones(nspecies), amc = LinRange(0, 1, nspecies),
                         rsa = fill(mean(real_traits.rsa), nspecies))
    prealloc = @set prealloc.traits = artificial_traits

    prealloc_real = deepcopy(prealloc)
    real_traits.amc .= sort(real_traits.amc)
    real_traits.abp .= real_traits.abp[sortperm(real_traits.amc)]
    prealloc_real = @set prealloc.traits = real_traits

    fig = Figure(size = (800, 900))
    Axis(fig[1, 1]; limits = (0, 1, 0, nothing),
              ylabel = "Growth reduction due to\ninvestment in mycorrhiza\n← stronger reduction, less reduction →",
              xlabel = "Arbuscular mycorrhizal colonisation rate (amc) [-]",)
    colorrange = (0.0, 3.0)
    for κ_red_amc in LinRange(0, 3, 7)
        p.κ_red_amc = κ_red_amc
        root_investment!(; input_obj, prealloc, p)
        lines!(artificial_traits.amc, prealloc.calc.root_invest;
               color = κ_red_amc,
               colorrange)
        root_investment!(; input_obj, prealloc = prealloc_real, p)
        scatter!(real_traits.amc, prealloc_real.calc.root_invest ./ real_traits.abp;
            color = κ_red_amc,
            colorrange)
    end
    Colorbar(fig[1, 2]; colorrange, label = "κ_red_amc [-]")

    Axis(fig[2, 1]; limits = (0, 1, 0, 1),
        ylabel = "Combined effect: Growth reduction due to\ninvestment into roots and mycorrhiza\n← stronger reduction, less reduction →",
        xlabel = "Arbuscular mycorrhizal colonisation rate (amc) [-]",)
    colorrange = (minimum(real_traits.abp), maximum(real_traits.abp))
    p.κ_red_amc = 1.0
    root_investment!(; input_obj, prealloc = prealloc_real, p)
    scatter!(real_traits.amc, prealloc_real.calc.root_invest;
        color = real_traits.abp,
        colorrange, colormap = :roma)
    lines!(real_traits.amc, prealloc_real.calc.root_invest;
            color = (:black, 0.3))
    text!(0.5, 0.5; text = "κ_red_amc = 1.0", halign = :center, valign = :center)
    Colorbar(fig[2, 2]; colormap = :roma, colorrange, label = "Abovegorund biomass\nper total biomass [-]")

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
