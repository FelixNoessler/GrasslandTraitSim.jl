function height_influence(sim, valid; path = nothing, nspecies = 25)
    #####################
    mp = valid.model_parameters()
    inf_p = (; zip(Symbol.(mp.names), mp.best)...)
    input_obj = valid.validation_input(;
        plotID = "HEG01", nspecies,
        npatches = 1, nutheterog = 0.0)
    calc = sim.preallocate_vectors(; input_obj)
    container = sim.initialization(; input_obj, inf_p, calc)
    #####################

    height_strengths = LinRange(0.0, 1.5, 40)
    biomass = fill(50, nspecies)u"kg / ha"
    ymat = Array{Float64}(undef, nspecies, length(height_strengths))

    for (i, height_strength) in enumerate(height_strengths)
        container = @set container.p.height_strength = height_strength
        sim.height_influence!(; container, biomass)
        ymat[:, i] .= container.calc.heightinfluence
    end

    idx = sortperm(container.traits.height)
    height = ustrip.(container.traits.height)[idx]
    ymat = ymat[idx, :]
    colorrange = (minimum(height), maximum(height))
    colormap = :viridis

    fig = Figure(; resolution = (700, 400))
    ax = Axis(fig[1, 1];
        ylabel = "Plant height growth factor (heightinfluence)",
        xlabel = "Influence strength of the plant height (height_strength)")

    for i in Base.OneTo(nspecies)
        lines!(height_strengths, ymat[i, :];
            linewidth = 3,
            color = height[i],
            colorrange = colorrange,
            colormap = colormap)
    end

    lines!(height_strengths, ones(length(height_strengths));
        linewidth = 5,
        linestyle = :dash,
        color = :red)

    Colorbar(fig[1, 2]; colormap, colorrange, label = "Plant height [m]")

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
