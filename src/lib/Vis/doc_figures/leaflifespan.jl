function leaflifespan(sim, valid; path = nothing, nspecies = 25)
    #####################
    input_obj = valid.validation_input(;
        plotID = "HEG01", nspecies)
    p = sim.parameter(; input_obj)
    calc = sim.preallocate_vectors(; input_obj)
    container = sim.initialization(; input_obj, p, calc)
    #####################

    fig = Figure(; size = (700, 400))
    ax = Axis(fig[1, 1];
        xlabel = "Specific leaf area [m² g⁻¹]",
        ylabel = "Leaf lifespan [d]")
    scatter!(ustrip.(container.traits.sla), ustrip.(container.traits.leaflifespan);
             color = (:black, 0.7))

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
