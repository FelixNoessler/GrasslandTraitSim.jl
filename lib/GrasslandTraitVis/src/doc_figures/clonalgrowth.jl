function plot_clonalgrowth(sim; path = nothing)
    nspecies = 1
    npatches = 25
    patch_xdim = 5
    patch_ydim = 5

    calc = (;
        patch = (;
            nneighbours = fill(0, npatches),
            surroundings = Matrix{Union{Missing, Int64}}(undef, npatches, 5),
            neighbours = Matrix{Union{Missing, Int64}}(undef, npatches, 4),
            xs = fill(0, npatches),
            ys = fill(0, npatches),),
        calc = (;
            clonalgrowth = fill(NaN, npatches, nspecies)u"kg / ha",
            relbiomass = fill(NaN, npatches), ##needs to be specified
            biomass_per_patch = fill(NaN, npatches)u"kg / ha",),
        u = (;
            u_biomass = fill(0.0001, npatches, nspecies)u"kg / ha",))
    input_obj = (;
        simp = (;
            patch_xdim,
            patch_ydim,
            npatches))

    sim.set_neighbours_surroundings!(; input_obj, calc)

    container = sim.tuplejoin(input_obj, calc)

    container.u.u_biomass[13, :] .= 10.0u"kg / ha"
    startcondition = copy(ustrip.(container.u.u_biomass[:, 1]))

    sim.Growth.calculate_relbiomass!(; container)
    sim.Growth.clonalgrowth!(; container)

    endcondition = copy(ustrip.(container.u.u_biomass[:, 1]))

    xs = [[x for x in 1:patch_xdim, _ in 1:patch_ydim]...]
    ys = [[y for _ in 1:patch_xdim, y in 1:patch_ydim]...]

    colorrange = quantile(log10.(startcondition), [0.0, 1.0])

    fig = Figure(; resolution = (600, 300))
    ax1 = Axis(fig[1, 1]; title = "startcondition")
    plt = scatter!(xs, ys;
        marker = :rect,
        markersize = 1.5,
        markerspace = :data,
        color = log10.(startcondition),
        colorrange,
        colormap = :viridis)

    ax2 = Axis(fig[1, 2]; title = "after clonal growth")
    scatter!(xs, ys;
        marker = :rect,
        markersize = 1.5,
        markerspace = :data,
        color = log10.(endcondition),
        colorrange,
        colormap = :viridis)

    for ax in [ax1, ax2]
        ax.aspect = DataAspect()
        ax.yticks = 1:patch_ydim
        ax.xticks = 1:patch_xdim
        ax.limits = (0, patch_xdim + 1, 0, patch_ydim + 1)
    end

    Colorbar(fig[1, 3], plt, label = "log10 biomass [kg ha⁻¹]")

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
