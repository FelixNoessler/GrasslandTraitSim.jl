function height_influence(sim, valid; path = nothing, nspecies = 25)
    #####################
    input_obj = valid.validation_input(;
        plotID = "HEG01", nspecies)
    p = sim.parameter(; input_obj)
    calc = sim.preallocate_vectors(; input_obj)
    container = sim.initialization(; input_obj, p, calc)
    #####################

    height_strength_exps = LinRange(0.0, 1.5, 40)
    biomass = fill(50, nspecies)u"kg / ha"
    ymat = Array{Float64}(undef, nspecies, length(height_strength_exps))

    for (i, height_strength_exp) in enumerate(height_strength_exps)
        container = @set container.p.height_strength_exp = height_strength_exp
        sim.height_influence!(; container, biomass)
        ymat[:, i] .= container.calc.heightinfluence
    end

    idx = sortperm(container.traits.height)
    height = ustrip.(container.traits.height)[idx]
    ymat = ymat[idx, :]
    colorrange = (minimum(height), maximum(height))
    colormap = :viridis

    fig = Figure(; size = (700, 400))
    ax = Axis(fig[1, 1];
        ylabel = "Plant height growth factor (heightinfluence)",
        xlabel = "Influence strength of the plant height (height_strength_exp)")

    for i in Base.OneTo(nspecies)
        lines!(height_strength_exps, ymat[i, :];
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
