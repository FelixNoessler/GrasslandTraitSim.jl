function planar_gradient(; path = nothing)
    mat = Array{Float64}(undef, 10, 10)
    planar_gradient!(; mat, direction = 100)

    ############################
    fig = Figure(; size = (400, 300))
    Axis(fig[1, 1];
        ylabel = "y patch index",
        xlabel = "x patch index",
        aspect = DataAspect())
    plt = heatmap!(mat)
    Colorbar(fig[1, 2], plt)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
