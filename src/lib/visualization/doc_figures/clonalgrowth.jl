function plot_clonalgrowth(; path = nothing)
    nspecies = 1
    npatches = 25
    patch_xdim = 5
    patch_ydim = 5

    #####################
    input_obj = validation_input(;
        plotID = "HEG01", nspecies,
        patch_xdim, patch_ydim)
    p = SimulationParameter1()
    p = @set p.clonalgrowth_factor = 0.5
    prealloc = preallocate_vectors(; input_obj);
    prealloc_specific = preallocate_specific_vectors(; input_obj);
    container = initialization(; input_obj, p, prealloc, prealloc_specific)
    #####################

    container.u.u_biomass .= 2.0u"kg / ha"
    container.u.u_biomass[3, 3, :] .= 10.0u"kg / ha"
    startcondition = copy(ustrip.(container.u.u_biomass[:, :, 1]))

    calculate_relbiomass!(; container)
    clonalgrowth!(; container)

    endcondition = copy(ustrip.(container.u.u_biomass[:, :, 1]))
    colorrange = [0.0, 10.0]

    fig = Figure(; size = (600, 300))
    ax1 = Axis(fig[1, 1]; title = "startcondition")
    ax2 = Axis(fig[1, 2]; title = "after clonal growth")

    for x in Base.OneTo(patch_xdim)
        for y in Base.OneTo(patch_ydim)
            scatter!(ax1, x, y;
                marker = :rect,
                markersize = 1.5,
                markerspace = :data,
                color = startcondition[x, y],
                colorrange,
                colormap = :viridis)

                scatter!(ax2, x, y;
                    marker = :rect,
                    markersize = 1.5,
                    markerspace = :data,
                    color = endcondition[x, y],
                    colorrange,
                    colormap = :viridis)
        end
    end



    for ax in [ax1, ax2]
        ax.aspect = DataAspect()
        ax.yticks = 1:patch_ydim
        ax.xticks = 1:patch_xdim
        ax.limits = (0, patch_xdim + 1, 0, patch_ydim + 1)
    end

    Colorbar(fig[1, 3]; colorrange, colormap = :viridis, label = "biomass [kg ha⁻¹]")

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
