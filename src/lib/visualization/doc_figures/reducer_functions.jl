function radiation_reducer(;
        PARs = LinRange(0.0, 15.0 * 100^2, 1000)u"MJ / ha",
        path = nothing)

    nspecies, container = create_container(; nspecies = 1)

    PARs = sort(ustrip.(PARs)) .* unit(PARs[1])

    y = Float64[]

    for PAR in PARs
        radiation_reduction!(; PAR, container)
        push!(y, container.calc.com.RAD)
    end

    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1];
        ylabel = "Growth reduction (RAD)",
        xlabel = "Photosynthetically active radiation (PAR) [MJ ha⁻¹]",
        title = "Radiation reducer function")

    PARs = ustrip.(PARs)

    if length(y) > 1000
        scatter!(PARs, y,
            markersize = 5,
            color = (:magenta, 0.05))
    else
        lines!(PARs, y,
            linewidth = 3,
            color = :magenta)
    end
    ylims!(-0.05, 1.05)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end

function temperatur_reducer(;
    Ts = collect(LinRange(0.0, 40.0, 500)) .* u"°C",
    path = nothing)

    nspecies, container = create_container(; nspecies = 1)

    y = Float64[]
    for T in Ts
        temperature_reduction!(; T, container)
        push!(y, container.calc.com.TEMP)
    end

    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1];
        ylabel = "Growth reduction (TEMP)",
        xlabel = "Air temperature [°C]",
        title = "Temperature reducer function")

    if length(y) > 500
        scatter!(ustrip.(Ts), y,
            markersize = 5,
            color = (:coral3, 0.5))
    else
        lines!(ustrip.(Ts), y,
            linewidth = 3,
            color = :coral3)
    end

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end

function seasonal_effect(;
    STs = LinRange(0, 3500, 1000)u"K",
    path = nothing)

    nspecies, container = create_container(; nspecies = 1)

    y = Float64[]
    for ST in STs
        seasonal_reduction!(; ST, container)
        push!(y, container.calc.com.SEA)
    end

    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1];
        ylabel = "Seasonal factor (SEA)",
        xlabel = "Yearly accumulated temperature (ST) [K]",
        title = "Seasonal effect")

    if length(y) > 1000
        scatter!(STs, y;
            markersize = 3,
            color = (:navajowhite4, 0.1))
    else
        lines!(ustrip.(STs), y;
            linewidth = 3,
            color = :navajowhite4)
    end

    ylims!(-0.05, 1.6)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end

function below_influence(; path = nothing)
    nspecies, container = create_container(; )

    #################### varying β_TSB, equal biomass, random traits
    below_effects = LinRange(0, 2.0, 200)
    biomass = fill(50.0, nspecies)u"kg / ha"
    ymat = Array{Float64}(undef, nspecies, length(below_effects))

    for (i, below_effect) in enumerate(below_effects)
        container = @set container.p.β_TSB = below_effect
        below_ground_competition!(; container, biomass)
        ymat[:, i] .= container.calc.biomass_density_factor
    end

    traitsimmat = ustrip.(copy(container.calc.TS))
    traitsim = vec(mean(traitsimmat, dims = 1))
    idx = sortperm(traitsim)
    traitsim = traitsim[idx]
    ymat = ymat[idx, :]
    colorrange = (minimum(traitsim), maximum(traitsim))
    colormap = :viridis
    #####################

    ##################### artficial example
    mat = [1 0.8 0.2; 0.8 1 0.5; 0.2 0.5 1]
    biomass = [100.0, 10.0, 10.0]u"kg / ha"

    artificial_below = 0.0:0.01:2
    artificial_mat = Array{Float64}(undef, 3, length(artificial_below))

    for i in eachindex(artificial_below)
        c = (;
            calc = (; TS_biomass = zeros(3)u"kg / ha",
                    TS = mat,
                    biomass_density_factor = zeros(3)),
            simp = (; included = (; belowground_competition = true)),
            p = (; β_TSB = artificial_below[i],
                α_TSB = 80u"kg / ha"))
        below_ground_competition!(; container = c, biomass)

        artificial_mat[:, i] = c.calc.biomass_density_factor
    end

    artificial_labels = [
        "high biomass",
        "low biomass,\nshares traits\nwith species 1",
        "low biomass,\nshares few traits\nwith species 1"]

    #####################

    fig = Figure(; size = (900, 800))
    Axis(fig[1, 1];
        # xlabel = "Strength of resource partitioning\n(β_TSB)",
        xticklabelsvisible = false,
        title = "Real community with equal biomass")
    ylims!(-0.1, nothing)
    for i in Base.OneTo(nspecies)
        lines!(below_effects, ymat[i, :];
            colorrange, colormap, color = traitsim[i])
    end
    lines!([0, maximum(below_effects)], [1, 1];
        color = :black)
    Colorbar(fig[1, 2]; colorrange, colormap, label = "Mean trait similarity")

    ax2 = Axis(fig[2, 1];
        xlabel = "Strength of resource partitioning\n(β_TSB)",
        title = "Artificial community")
    for i in 1:3
        lines!(artificial_below, artificial_mat[i, :];
            label = artificial_labels[i],
            linewidth = 3)
    end
    lines!([0.0, maximum(artificial_below)], ones(2);
        color = :black)
    axislegend(ax2; position = :lt)

    # Axis(fig[3, 1];
    #     xlabel = "Mean trait similarity",
    #     title = "β_TSB = $(below_density_effect)")
    # ylims!(-0.1, nothing)
    # lines!(quantile(mean_traitsim, [0.0, 1.0]), [1, 1];
    #     color = :black)
    # lines!(mean_traitsim[u1], belowsplit_biomass1[u1];
    #     color = :black, linestyle=:dash)
    # lines!(mean_traitsim[u2], belowsplit_biomass2[u2];
    #     color = :black, linestyle = :dot)

    # b1 = ustrip.(biomass1)
    # plt = scatter!(mean_traitsim, belowsplit_biomass1;
    #     colormap = :vik100,
    #     color = b1,
    #     colorrange = (minimum(b1), maximum(b1)) )
    # b2 = ustrip.(biomass2)
    # scatter!(mean_traitsim, belowsplit_biomass2;
    #     colormap = :vik100,
    #     color = b2,
    #     colorrange = (minimum(b2), maximum(b2)) )
    # Colorbar(fig[3, 2], plt;
    #          label = "Biomass [kg ha⁻¹]")

    Label(fig[1:2, 0], "Plant available resource (water or nutrients) adjustment factor",
        rotation = pi / 2)

    colgap!(fig.layout, 2, 10)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end



function plot_seasonal_component_senescence(;
        STs = LinRange(0, 4000, 500),
        path = nothing)

    nspecies, container = create_container(; nspecies = 1)

    STs = sort(STs)

    y = Float64[]
    for ST in STs
        g = seasonal_component_senescence(; container, ST)
        push!(y, g)
    end

    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1];
        ylabel = "Seasonal factor for senescence (SEN)",
        xlabel = "Annual cumulative temperature (ST) [°C]",
        title = "")

    if length(y) > 1000
        scatter!(STs, y;
            markersize = 3,
            color = (:navajowhite4, 0.1))
    else
        lines!(STs, y;
            linewidth = 3,
            color = :navajowhite4)
    end
    ylims!(-0.05, 3.5)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
