function neighbours_surroundings(sim, valid; path = nothing)
    #####################
    mp = valid.model_parameters()
    inf_p = (; zip(Symbol.(mp.names), mp.best)...)
    input_obj = valid.validation_input(;
        plotID = "HEG01", nspecies = 25,
        startyear = 2009, endyear = 2021,
        npatches = 25, nutheterog = 0.0)
    calc = sim.preallocate_vectors(; input_obj)
    container = sim.initialization(; input_obj, inf_p, calc)

    #####################
    neighbours = container.patch.neighbours[13, :]
    neighbours = neighbours[.!ismissing.(neighbours)]
    n_color = ones(25)
    n_color[neighbours] .= 2

    surroundings = container.patch.surroundings[13, :]
    surroundings = surroundings[.!ismissing.(surroundings)]
    s_color = ones(25)
    s_color[surroundings] .= 2

    #####################
    fig = Figure(; resolution = (600, 300))

    Axis(fig[1, 1];
        ylabel = "y patch index",
        xlabel = "x patch index",
        limits = (0.5, 5.5, 0.5, 5.5),
        xticks = 1:5,
        yticks = 1:5,
        aspect = DataAspect(),
        title = "neighbours")
    scatter!(container.patch.xs, container.patch.ys;
        marker = :rect,
        markersize = 1.5,
        markerspace = :data,
        color = n_color)
    scatter!([3.0], [3.0]; color = :red)

    Axis(fig[1, 2];
        xlabel = "x patch index",
        limits = (0.5, 5.5, 0.5, 5.5),
        xticks = 1:5,
        yticks = 1:5,
        aspect = DataAspect(),
        title = "surroundings")
    scatter!(container.patch.xs, container.patch.ys;
        marker = :rect,
        markersize = 1.5,
        markerspace = :data,
        color = s_color)
    scatter!([3.0], [3.0]; color = :red)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
