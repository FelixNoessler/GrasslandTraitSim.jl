
function potential_growth(sim, valid;
        nspecies = 25,
        path = nothing)

    #####################
    mp = valid.model_parameters()
    inf_p = (; zip(Symbol.(mp.names), mp.best)...)
    input_obj = valid.validation_input(;
        plotID = "HEG01", nspecies,
        startyear = 2009, endyear = 2021,
        npatches = 1, nutheterog = 0.0)
    calc = sim.preallocate_vectors(; input_obj)
    container = sim.initialization(; input_obj, inf_p, calc)
    #####################

    par_values = 10
    biomass = repeat([1], nspecies)u"kg / ha"
    PARs = LinRange(0, 12, par_values)u"MJ * d^-1 * m^-2"
    sla = container.traits.sla
    ymat = Array{Float64}(undef, nspecies, par_values)

    for (i, PAR) in enumerate(PARs)
        sim.Growth.potential_growth!(; container, sla, biomass, PAR,
            potgrowth_included = true)
        ymat[:, i] .= ustrip.(container.calc.pot_growth)
    end

    idx = sortperm(container.traits.sla)
    ymat = ymat[idx, :]
    sla = ustrip.(sla[idx])
    colorrange = (minimum(sla), maximum(sla))
    colormap = :viridis

    fig = Figure(; resolution = (800, 400))
    Axis(fig[1, 1],
        xlabel = "Photosynthetically active radiation [MJ m⁻² d⁻¹]",
        ylabel = "Potential growth per biomass\n[kg kg⁻¹ ha⁻¹ d⁻¹]",
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
