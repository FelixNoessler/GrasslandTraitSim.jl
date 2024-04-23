################################################################
# Plots for potential growth
################################################################
function potential_growth_lai_height(; path = nothing)
    nspecies, container = create_container(; )
    biomass = container.u.u_biomass[1, 1, :]
    biomass_vals = LinRange(0, 100, 150)u"kg / ha"

    height_vals = reverse([0.2, 0.5, 1.0, 100000.0]u"m")
    ymat = Array{Float64}(undef, length(height_vals), length(biomass_vals))
    lai_tot = Array{Float64}(undef, length(biomass_vals))

    for (hi, h) in enumerate(height_vals)
        container.traits.height .= h
        for (i,b) in enumerate(biomass_vals)
            biomass .= b
            potential_growth!(; container, biomass, PAR = container.daily_input.PAR[150])

            ymat[hi, i] = ustrip(container.calc.com.potgrowth_total)
            lai_tot[i] = sum(container.calc.LAIs)
        end
    end

    fig = Figure(; size = (600, 400))
    Axis(fig[1, 1],
        xlabel = "Total leaf area index [-]",
        ylabel = "Total potential growth [kg ha⁻¹]")
    lines!(lai_tot, ymat[1, :]; linewidth = 3.0,
           label = "without com. height red.")
    lines!(lai_tot, ymat[2, :]; linewidth = 3.0,
        label = "$(ustrip(height_vals[2]))")
    lines!(lai_tot, ymat[3, :]; linewidth = 3.0,
        label = "$(ustrip(height_vals[3]))")
    lines!(lai_tot, ymat[4, :]; linewidth = 3.0,
        label = "$(ustrip(height_vals[4]))")
    axislegend("Community weighted\nmean height [m]";
               position = :lt, framevisible = true)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end

function potential_growth_height_lai(; path = nothing)
    nspecies, container = create_container()
    biomass_val = [50.0, 35.0, 10.0]u"kg / ha"
    biomass = container.u.u_biomass[1,1,:]
    lais = zeros(3)
    heights = LinRange(0.01, 2, 300)
    red = Array{Float64}(undef, 3, length(heights))
    for (li, l) in enumerate(lais)
        for (hi, h) in enumerate(heights)
            biomass .= biomass_val[li]
            @reset container.traits.height = [h * u"m"]
            potential_growth!(; container, biomass, PAR = container.daily_input.PAR[150])
            pot_gr = ustrip(container.calc.com.potgrowth_total)

            lais[li] = round(container.calc.com.LAItot; digits = 1)
            red[li, hi] = pot_gr
        end
    end

    fig = Figure()
    Axis(fig[1,1]; xlabel = "Community weighted mean height [m]",
         ylabel = "Total potential growth [kg ha⁻¹]")
    linewidth = 3.0
    lines!(heights, red[1, :]; linewidth, label = "$(lais[1])")
    lines!(heights, red[2, :]; linewidth, label = "$(lais[2])")
    lines!(heights, red[3, :]; linewidth, label = "$(lais[3])")
    axislegend("Total leaf\narea index [-]"; framevisible = false, position = :rb)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end

################################################################
# Plots for leaf area index
################################################################
function lai_traits(; path = nothing)
    nspecies, container = create_container()
    biomass = container.u.u_biomass[1, 1, :]

    potential_growth!(; container, biomass, PAR = container.daily_input.PAR[150])
    val = container.calc.LAIs

    idx = sortperm(container.traits.sla)
    ymat = val[idx]
    sla = ustrip.(container.traits.sla[idx])


    leaf_proportion = (container.traits.lbp ./ container.traits.abp)[idx]
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

################################################################
# Plots for community height reduction
################################################################
function potential_growth_height(; path = nothing)
    nspecies, container = create_container()

    biomass = container.u.u_biomass[1,1,:]

    heights = LinRange(0.01, 2, 300)
    red = Array{Float64}(undef, length(heights))

    for (hi, h) in enumerate(heights)
        @reset container.traits.height = [h * u"m"]
        potential_growth!(; container, biomass, PAR = container.daily_input.PAR[150])
        red[hi] = container.calc.com.comH_reduction
    end

    fig = Figure()
    Axis(fig[1,1]; xlabel = "Community weighted mean height [m]",
         ylabel = "Community height growth reduction factor [-]")
    lines!(heights, red; linewidth = 3.0)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end

function community_height_influence(; path = nothing)
    trait_input = input_traits()
    for k in keys(trait_input)
        @reset trait_input[k] = [mean(trait_input[k])]
    end
    input_obj = validation_input(;
        plotID = "HEG01", nspecies = 1);
    input_obj.daily_input.LD_grazing .= NaN * u"ha^-1"
    input_obj.daily_input.CUT_mowing .= NaN * u"m"
    p = SimulationParameter()

    function sim_community_height(; community_height_red)
        @reset input_obj.simp.included.community_height_red .= community_height_red
        @reset trait_input.height = [0.1u"m"]
        sol_small = solve_prob(; input_obj, p, trait_input);
        s = vec(ustrip.(sol_small.output.biomass[:, 1, 1, 1]))

        @reset trait_input.height = [1.0u"m"]
        sol_large = solve_prob(; input_obj, p, trait_input);
        l = vec(ustrip.(sol_large.output.biomass[:, 1, 1, 1]))

        return sol_small.numeric_date, s, l
    end
    tstep = 30

    fig = Figure(; size = (600, 600))

    Axis(fig[1, 1]; limits = (nothing, nothing, 0, nothing),
         title = "Without community height reduction",
         xlabel = "", ylabel = "", xticklabelsvisible = false)
    t, s, l = sim_community_height(; community_height_red = false)
    lines!(t[1:tstep:end], l[1:tstep:end]; label = "1.0 m")
    lines!(t[1:tstep:end], s[1:tstep:end]; label = "0.1 m")

    Axis(fig[2, 1]; limits = (nothing, nothing, 0, nothing),
        title = "With community height reduction",
        xlabel = "Date [year]", ylabel = "")
    t, s, l = sim_community_height(; community_height_red = true)

    lines!(t[1:tstep:end], l[1:tstep:end]; label = "1.0 m")
    lines!(t[1:tstep:end], s[1:tstep:end]; label = "0.1 m")
    axislegend(; framevisible = false, position = :rb)

    Label(fig[1:2, 0], "Dry aboveground biomass [kg ha⁻¹]",
          rotation= pi/2, fontsize = 16)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
