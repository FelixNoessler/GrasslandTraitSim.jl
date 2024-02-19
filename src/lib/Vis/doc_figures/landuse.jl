function grazing(sim, valid;
        grazing_half_factor = 1500,
        leafnitrogen_graz_exp = 1,
        nspecies = 25,
        path = nothing)

    #####################
    input_obj = valid.validation_input(;
        plotID = "HEG01", nspecies)
    p = sim.parameter(; input_obj)
    p = @set p.grazing_half_factor = grazing_half_factor
    p = @set p.leafnitrogen_graz_exp = leafnitrogen_graz_exp
    calc = sim.preallocate_vectors(; input_obj)
    container = sim.initialization(; input_obj, p, calc)
    #####################

    nbiomass = 500
    LD = 2u"ha ^ -1"
    biomass_vec = LinRange(0, 500, nbiomass)u"kg / ha"
    grazing_mat = Array{Float64}(undef, nspecies, nbiomass)

    for (i, biomass) in enumerate(biomass_vec)
        container.calc.defoliation .= 0.0u"kg / (ha * d)"
        sim.grazing!(; t = 1, x = 1, y = 1, container, LD,
                     biomass = repeat([biomass], nspecies))
        grazing_mat[:, i] = ustrip.(container.calc.defoliation)
    end

    idx = sortperm(container.calc.ρ)
    lncm = ustrip.(container.traits.lncm)[idx]
    grazing_mat = grazing_mat[idx, :]
    colorrange = (minimum(lncm), maximum(lncm))

    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1],
        xlabel = "Biomass per species [kg ha⁻¹]",
        ylabel = "Grazed biomass per species (graz)\n[kg ha⁻¹ d⁻¹]",
        title = "")

    for i in 1:nspecies
        lines!(ustrip.(biomass_vec), grazing_mat[i, :];
            color = lncm[i],
            colorrange,
            linewidth = 3)
    end

    Colorbar(fig[1, 2]; colorrange, colormap = :viridis,
        label = "Leaf nitrogen content [mg g⁻¹]")

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end

function grazing_half_factor(; path = nothing)
    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1],
        xlabel = "Total biomass [green dry mass kg ha⁻¹]",
        ylabel = "Grazed biomass (totgraz)\n[green dry mass kg ha⁻¹ d⁻¹]",
        title = "")

    for grazing_half_factor in [750, 1500, 2000]
        x = 0:3000

        LD = 2
        κ = 22
        k_exp = 2
        μₘₐₓ = κ * LD
        h = 1 / μₘₐₓ
        a = 1 / (grazing_half_factor^k_exp * h)
        y = @. a * x^k_exp / (1^k_exp + a * h * x^k_exp)

        lines!(x, y, label = "$grazing_half_factor",
            linewidth = 3)
    end

    axislegend("grazing_half_factor";
        framevisible = true, position = :rb)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end
end

function trampling(sim, valid; nspecies = 25, trampling_factor = 0.01, path = nothing)

    #####################
    input_obj = valid.validation_input(;
        plotID = "HEG01", nspecies)
    p = sim.parameter(; input_obj)
    p = @set p.trampling_factor = trampling_factor * u"ha"
    calc = sim.preallocate_vectors(; input_obj)
    container = sim.initialization(; input_obj, p, calc)
    #####################

    nLD = 500
    biomass = fill(100.0, nspecies)u"kg / ha"
    LDs = LinRange(0.0, 4.0, nLD)u"ha^-1"

    trampling_mat_height = Array{Float64}(undef, nspecies, nLD)

    for (i, LD) in enumerate(LDs)
        container.calc.defoliation .= 0.0u"kg / (ha * d)"
        sim.trampling!(; container, LD, biomass)
        trampling_mat_height[:, i] = ustrip.(container.calc.defoliation)
    end
    trampling_mat_height = trampling_mat_height ./ 100.0

    idx = sortperm(container.traits.height)
    height = ustrip.(container.traits.height)[idx]
    trampling_mat_height = trampling_mat_height[idx, :]

    colorrange = (minimum(height), maximum(height))
    colormap = :viridis

    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1],
        ylabel = "Proportion of biomass that is\nremoved by trampling [d⁻¹]",
        xlabel = "Livestock density [ha⁻¹]",
        title = "")
    for i in 1:nspecies
        lines!(ustrip.(LDs), trampling_mat_height[i, :];
            linewidth = 3, label = "height=$(height[i])",
            colormap,
            colorrange,
            color = height[i])
    end

    Colorbar(fig[1, 2]; colormap, colorrange, label = "Plant height [m]")

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end

function mowing(sim, valid; nspecies = 25, mowing_height = 0.07u"m",
        mowing_mid_days = 30,
        path = nothing)

    #####################
    input_obj = valid.validation_input(;
        plotID = "HEG01", nspecies)
    p = sim.parameter(; input_obj)
    p = @set p.mowing_mid_days = mowing_mid_days
    calc = sim.preallocate_vectors(; input_obj)
    container = sim.initialization(; input_obj, p, calc)
    #####################

    nbiomass = 3
    biomass_vec = LinRange(0, 1000, nbiomass)u"kg / ha"
    mowing_mat = Array{Float64}(undef, nspecies, nbiomass)

    for (i, biomass) in enumerate(biomass_vec)
        container.calc.defoliation .= 0.0u"kg / (ha * d)"
        sim.mowing!(; t = 1, x = 1, y = 1, container, mowing_height,
                       biomass, mowing_all = fill(NaN, 5))

        mowing_mat[:, i] = ustrip.(container.calc.defoliation)
    end

    idx = sortperm(container.traits.height)
    height = ustrip.(container.traits.height)[idx]
    mowing_mat = mowing_mat[idx, :]
    colorrange = (minimum(height), maximum(height))
    colormap = :viridis

    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1],
        xlabel = "Biomass per species [kg ha⁻¹]",
        ylabel = """Maximal amount of biomass that is
                    removed by mowing (mow)
                    [kg ha⁻¹ d⁻¹]""",
        title = "")

    for i in 1:nspecies
        lines!(ustrip.(biomass_vec), mowing_mat[i, :];
            linewidth = 3, color = height[i], colorrange, colormap)
    end

    Colorbar(fig[1, 2]; colorrange, colormap, label = "Plant height [m]")

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end

function mow_factor(;
        path = nothing)
    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1],
        xlabel = "Time since last mowing event [day]\n(days_since_last_mowing)",
        ylabel = "Regrowth of plants (mow_factor)",
        title = "")

    for mowing_mid_days in [20, 40, 100]
        x = 0:200
        y = @. 1 / (1 + exp(-0.05 * (x - mowing_mid_days)))

        lines!(x, y, label = "$mowing_mid_days",
            linewidth = 3)
    end

    axislegend("mowing_mid_days"; framevisible = true, position = :rb)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
