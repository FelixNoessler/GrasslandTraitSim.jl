function potential_growth(; path = nothing)
    nspecies, container = create_container(; )

    par_values = 10
    biomass = repeat([1], nspecies)u"kg / ha"
    PARs = LinRange(0, 12, par_values)u"MJ * m^-2"
    ymat = Array{Float64}(undef, nspecies, par_values)

    for (i, PAR) in enumerate(PARs)
        potential_growth!(; container, biomass, PAR)
        ymat[:, i] .= ustrip.(container.calc.potgrowth)
    end

    idx = sortperm(container.traits.sla)
    ymat = ymat[idx, :]
    sla = ustrip.(container.traits.sla[idx])
    colorrange = (minimum(sla), maximum(sla))
    colormap = :viridis

    fig = Figure(; size = (800, 400))
    Axis(fig[1, 1],
        xlabel = "Photosynthetically active radiation [MJ m⁻²]",
        ylabel = "Potential growth per biomass\n[kg kg⁻¹ ha⁻¹]",
        title = "Influence of the specific leaf area (SLA)")

    for i in nspecies:-1:1
        lines!(ustrip.(PARs), ymat[i, :];
            colorrange,
            colormap,
            color = sla[i])
    end
    Colorbar(fig[1, 2]; colormap, colorrange, label = "Specific leaf area [m² g⁻¹]")

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
