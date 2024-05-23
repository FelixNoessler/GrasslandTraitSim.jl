function grazing(; α_GRZ = nothing, β_PAL_lnc = nothing, path = nothing)
    nspecies, container = create_container()

    if !isnothing(α_GRZ)
        container.p.α_GRZ = α_GRZ
    end

    if !isnothing(β_PAL_lnc)
        container.p.β_PAL_lnc = β_PAL_lnc
    end

    nbiomass = 80
    LD = 2u"ha ^ -1"
    biomass_vec = LinRange(0, 500, nbiomass)u"kg / ha"
    grazing_mat = Array{Float64}(undef, nspecies, nbiomass)

    for (i, biomass) in enumerate(biomass_vec)
        container.calc.defoliation .= 0.0u"kg / ha"
        grazing!(; t = 1, x = 1, y = 1, container, LD,
                     biomass = repeat([biomass], nspecies))
        grazing_mat[:, i] = ustrip.(container.calc.defoliation)
    end

    idx = sortperm(container.traits.lnc)
    lnc = ustrip.(container.traits.lnc)[idx]
    grazing_mat = grazing_mat[idx, :]
    colorrange = (minimum(lnc), maximum(lnc))

    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1],
        xlabel = "Biomass per species [kg ha⁻¹]",
        ylabel = "Grazed biomass per species (graz)\n[kg ha⁻¹]",
        title = "")

    for i in 1:nspecies
        lines!(ustrip.(biomass_vec), grazing_mat[i, :];
            color = lnc[i],
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

function α_GRZ(; path = nothing)
    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1],
        xlabel = "Total biomass [green dry mass kg ha⁻¹]",
        ylabel = "Grazed biomass (totgraz)\n[green dry mass kg ha⁻¹]",
        title = "")

    for α_GRZ in [750, 1500, 2000]
        x = LinRange(0, 3000, 30)

        LD = 2
        κ = 22
        k_exp = 2
        μₘₐₓ = κ * LD
        h = 1 / μₘₐₓ
        a = 1 / (α_GRZ^k_exp * h)
        y = @. a * x^k_exp / (1^k_exp + a * h * x^k_exp)

        lines!(x, y, label = "$α_GRZ",
            linewidth = 3)
    end

    axislegend("α_GRZ";
        framevisible = true, position = :rb)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end
end

function trampling_biomass(; β_TRM = nothing, path = nothing)
    nspecies, container = create_container(; )

    if !isnothing(β_TRM)
        container.p.β_TRM = β_TRM * u"ha / kg"
    end

    nbiomass = 50
    biomass = fill(0.0, nspecies)u"kg / ha"
    biomass_vals = LinRange(0.0, 500.0, nbiomass)u"kg / ha"
    LD = 2.0u"ha^-1"

    trampling_mat_height = Array{Quantity{Float64}}(undef, nspecies, nbiomass)

    for (i, b) in enumerate(biomass_vals)
        biomass .= b
        container.calc.defoliation .= 0.0u"kg / ha"
        trampling!(; container, LD, biomass)
        trampling_mat_height[:, i] = container.calc.defoliation
    end
    trampling_mat_height = trampling_mat_height ./ biomass

    idx = sortperm(container.traits.height)
    height = ustrip.(container.traits.height)[idx]
    trampling_mat_height = trampling_mat_height[idx, :]

    colorrange = (minimum(height), maximum(height))
    colormap = :viridis

    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1],
        ylabel = "Proportion of biomass that is\nremoved by trampling [-]",
        xlabel = "Biomass of each species [kg ha⁻¹]",
        title = "constant livestock density: 2 [ha⁻¹]")
    for i in 1:nspecies
        lines!(ustrip.(biomass_vals), trampling_mat_height[i, :];
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
end

function trampling_biomass_individual(; β_TRM = nothing, path = nothing)
    nspecies, container = create_container(; )
    container.traits.height .= 0.7u"m"

    if !isnothing(β_TRM)
        container.p.β_TRM = β_TRM * u"kg"
    end

    nbiomass = 30
    biomass = fill(100.0, nspecies)u"kg / ha"
    biomass_vals = LinRange(0.0, 200.0, nbiomass)u"kg / ha"
    LD = 2.0u"ha^-1"

    trampling_mat_height = Array{Quantity{Float64}}(undef, nspecies, nbiomass)

    for (i, b) in enumerate(biomass_vals)
        biomass[1] = b
        container.calc.defoliation .= 0.0u"kg / ha"
        trampling!(; container, LD, biomass)
        trampling_mat_height[:, i] = container.calc.defoliation
    end
    trampling_mat_height = ustrip.(trampling_mat_height)# ./ biomass .* u"d"

    idx = sortperm(container.traits.height)
    height = ustrip.(container.traits.height)[idx]
    trampling_mat_height = trampling_mat_height[idx, :]

    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1],
        ylabel = "Raw biomass that is removed\nby trampling [kg ha⁻¹]",
        xlabel = "Biomass of first species (red) [kg ha⁻¹]",
        title = """constant livestock density,
                   all species have the same traits
                   biomass of species 1 on x axis,
                   all other species with 100 [kg ha⁻¹]""")
    for i in 1:2
        lines!(ustrip.(biomass_vals), trampling_mat_height[i, :];
            linewidth = 3,
            color = i == 1 ? :red : :blue)
    end

    # Colorbar(fig[1, 2]; colormap, colorrange, label = "Plant height [m]")

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end

function trampling_livestockdensity(; β_TRM = nothing, path = nothing)
    nspecies, container = create_container(; )
    if !isnothing(β_TRM)
        container.p.β_TRM = β_TRM * u"kg / ha"
    end

    nLD = 10
    biomass = fill(100.0, nspecies)u"kg / ha"
    LDs = LinRange(0.0, 4.0, nLD)u"ha^-1"

    trampling_mat_height = Array{Quantity{Float64}}(undef, nspecies, nLD)

    for (i, LD) in enumerate(LDs)
        container.calc.defoliation .= 0.0u"kg / ha"
        trampling!(; container, LD, biomass)
        trampling_mat_height[:, i] = container.calc.defoliation
    end
    trampling_mat_height = trampling_mat_height ./ biomass

    idx = sortperm(container.traits.height)
    height = ustrip.(container.traits.height)[idx]
    trampling_mat_height = trampling_mat_height[idx, :]

    colorrange = (minimum(height), maximum(height))
    colormap = :viridis

    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1],
        ylabel = "Proportion of biomass that is\nremoved by trampling [-]",
        xlabel = "Livestock density [ha⁻¹]",
        title = "constant biomass of each species: 100 [kg ha⁻¹]")
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

function mowing(; mowing_height = 0.07u"m",
                path = nothing)
    nspecies, container = create_container(; )

    nbiomass = 3
    biomass_vec = LinRange(0, 1000, nbiomass)u"kg / ha"
    mowing_mat = Array{Float64}(undef, nspecies, nbiomass)

    for (i, biomass) in enumerate(biomass_vec)
        container.calc.defoliation .= 0.0u"kg / ha"
        mowing!(; t = 1, x = 1, y = 1, container, mowing_height,
                    biomass = fill(biomass, nspecies), mowing_all = fill(NaN, 5))

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
                    [kg ha⁻¹]""",
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
