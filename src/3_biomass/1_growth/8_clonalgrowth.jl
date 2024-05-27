@doc raw"""
Yearly clonal growth.

The biomass is transferred from the home patch to the neighbour (target) patches.
This is done for all patches once per year.

![](../img/clonalgrowth.png)
![](../img/clonalgrowth_animation.mp4)
"""
function clonalgrowth!(; container)
    @unpack patch_xdim, patch_ydim, nspecies = container.simp
    @unpack clonalgrowth = container.calc
    @unpack u_biomass = container.u
    @unpack β_clo = container.p

    clonalgrowth .= 0.0u"kg / ha"
    x_add = [1, 0, -1, 0]
    y_add = [0, 1, 0, -1]

    for x in Base.OneTo(patch_xdim)
        for y in Base.OneTo(patch_ydim)
            for i in 1:4
                x_neighbour = x + x_add[i]
                y_neighbour = y + y_add[i]

                if x_neighbour < 1 || x_neighbour > patch_xdim ||
                   y_neighbour < 1 || y_neighbour > patch_ydim
                    continue
                end

                for s in Base.OneTo(nspecies)
                    ## growth to neighbour patch
                    clonalgrowth[x_neighbour, y_neighbour, s] +=
                        u_biomass[x, y, s] * β_clo

                    ## biomass is removed from own patch
                    clonalgrowth[x, y, s] -= u_biomass[x, y, s] * β_clo
                end
            end

        end
    end

    u_biomass .+= clonalgrowth

    return nothing
end

function animate_clonalgrowth(; θ = nothing, path = "clonalgrowth_animation.mp4", β_clo = nothing)
    patch_xdim = 10
    patch_ydim = 10
    nspecies, container = create_container_for_plotting(; θ, nspecies = 1,
                                                        patch_xdim, patch_ydim)
    if !isnothing(β_clo)
        container.p.β_clo = β_clo
    end
    #####################
    container.u.u_biomass .= 5.0u"kg / ha"
    container.u.u_biomass[3:6, 3:8, :] .= 10.0u"kg / ha"

    coords = hcat([[x,y] for x in 1:patch_xdim, y in 1:patch_ydim]...)
    xs = coords[1, :]
    ys = coords[2, :]

    color_obs = Observable(float.(xs))
    title_obs = Observable("0")

    color_obs[] = vec(copy(ustrip.(container.u.u_biomass[:, :, 1])))
    colorrange = [5, 10]


    fig = Figure(; size = (600, 500))
    ax1 = Axis(fig[1, 1];
    title = title_obs,
    aspect = DataAspect(),
    yticks = 1:patch_ydim,
    xticks = 1:patch_xdim,
    limits = (0, patch_xdim + 1, 0, patch_ydim + 1))
    scatter!(ax1, xs, ys;
    marker = :rect,
    markersize = 1.5,
    markerspace = :data,
    color = color_obs,
    colorrange,
    colormap = :viridis)
    Colorbar(fig[1, 2]; colorrange, colormap = :viridis, label = "biomass [kg ha⁻¹]")


    is = 0:30
    record(fig, path, is; framerate = 15) do i
    color_obs[] = vec(copy(ustrip.(container.u.u_biomass[:, :, 1])))
    title_obs[] = string(i)
    clonalgrowth!(; container)
    end

    return nothing
end

function plot_clonalgrowth(; θ = nothing, path = nothing, β_clo = nothing)
    nspecies = 1
    npatches = 25
    patch_xdim = 5
    patch_ydim = 5

    #####################
    input_obj = validation_input(;
    plotID = "HEG01", nspecies,
    patch_xdim, patch_ydim)
    p = SimulationParameter()
    if !isnothing(β_clo)
    p.β_clo = β_clo
    end
    prealloc = preallocate_vectors(; input_obj);
    prealloc_specific = preallocate_specific_vectors(; input_obj);
    container = initialization(; input_obj, p, prealloc, prealloc_specific)
    #####################

    container.u.u_biomass .= 5.0u"kg / ha"
    container.u.u_biomass[3, 3, :] .= 6.0u"kg / ha"
    startcondition = copy(ustrip.(container.u.u_biomass[:, :, 1]))

    clonalgrowth!(; container)

    endcondition = copy(ustrip.(container.u.u_biomass[:, :, 1]))
    colorrange = [5, 6]

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
