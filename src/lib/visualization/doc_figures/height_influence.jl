function height_influence(; path = nothing)
    nspecies, container = create_container(; )

    height_strength_exps = LinRange(0.0, 1.5, 40)
    biomass = fill(50, nspecies)u"kg / ha"
    ymat = Array{Float64}(undef, nspecies, length(height_strength_exps))

    for (i, height_strength_exp) in enumerate(height_strength_exps)
        container = @set container.p.height_strength_exp = height_strength_exp
        light_competition!(; container, biomass)
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

    lines!(height_strength_exps, ones(length(height_strength_exps));
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