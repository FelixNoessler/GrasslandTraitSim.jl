function potential_growth(; path = nothing)
    nspecies, container = create_container(; )

    par_values = 10
    biomass = container.u.u_biomass[1, 1, :]
    PARs = LinRange(0, 12, par_values)u"MJ * m^-2"
    ymat = Array{Float64}(undef, nspecies, par_values)

    for (i, PAR) in enumerate(PARs)
        potential_growth!(; container, biomass, PAR)
        ymat[:, i] .= ustrip.(container.calc.potgrowth)
    end

    idx = sortperm(container.calc.LAIs)
    ymat = ymat[idx, :]
    sla = ustrip.(container.calc.LAIs[idx])
    colorrange = (minimum(sla), maximum(sla))
    colormap = :viridis

    fig = Figure(; size = (600, 400))
    Axis(fig[1, 1],
        xlabel = "Photosynthetically active radiation [MJ m⁻²]",
        ylabel = "Potential growth [kg ha⁻¹]")

    for i in nspecies:-1:1
        lines!(ustrip.(PARs), ymat[i, :];
            colorrange,
            colormap,
            color = sla[i])
    end
    Colorbar(fig[1, 2]; colormap, colorrange, label = "Leaf area index [-]")

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end


function potential_growth_function(; path = nothing)
    nspecies, container = create_container(; )
    biomass = container.u.u_biomass[1, 1, :]
    biomass_vals = LinRange(0, 100, 150)u"kg / ha"

    ymat = Array{Float64}(undef, length(biomass_vals))
    lai_tot = Array{Float64}(undef, length(biomass_vals))

    for (i,b) in enumerate(biomass_vals)
        biomass .= b
        potential_growth!(; container, biomass, PAR = container.daily_input.PAR[150])

        ymat[i] = ustrip(sum(container.calc.potgrowth))
        lai_tot[i] = sum(container.calc.LAIs)
    end

    fig = Figure(; size = (600, 400))
    Axis(fig[1, 1],
        xlabel = "Total leaf area index [-]",
        ylabel = "Total potential growth [kg ha⁻¹]")
    lines!(lai_tot, ymat; linewidth = 3.0)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end


function lai_traits(; path = nothing)
    nspecies, container = create_container()

    biomass = container.u.u_biomass[1, 1, :]
    LAItot = potential_growth!(; container,
        biomass,
        PAR = container.daily_input.PAR[150])

    calculate_LAI(; container, biomass)
    val = container.calc.LAIs

    idx = sortperm(container.traits.sla)
    ymat = val[idx]
    sla = ustrip.(container.traits.sla[idx])


    leaf_proportion = (container.traits.lmpm ./ container.traits.ampm)[idx]
    colorrange = (minimum(leaf_proportion), maximum(leaf_proportion))
    colormap = :viridis

    fig = Figure()
    ax = Axis(fig[1, 1]; xlabel = "Specific leaf area [m² g⁻¹]", ylabel = "Leaf area index [-]", title = "")
    sc = scatter!(sla, ustrip(ymat), color = leaf_proportion, colormap = colormap)
    Colorbar(fig[1,2], sc; label = "Fraction of leaf biomass in abovegorund biomass")

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
