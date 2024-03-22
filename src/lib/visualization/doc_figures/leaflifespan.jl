function leaflifespan(; path = nothing)
    nspecies, container = create_container(; )

    fig = Figure(; size = (700, 400))
    ax = Axis(fig[1, 1];
        xlabel = "Specific leaf area [m² g⁻¹]",
        ylabel = "Leaf lifespan [d]")
    scatter!(ustrip.(container.traits.sla), ustrip.(container.calc.leaflifespan);
             color = (:black, 0.7))

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
