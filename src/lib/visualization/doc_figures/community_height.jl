function plot_community_height(; path = nothing)
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

            LAItot = potential_growth!(; container, biomass, PAR = container.daily_input.PAR[150])
            r = community_height_reduction(; container, biomass)
            pot_gr = ustrip(sum(container.calc.potgrowth))

            lais[li] = round(LAItot; digits = 1)
            red[li, hi] = pot_gr * r
        end
    end

    fig = Figure()
    Axis(fig[1,1]; xlabel = "Community weighted mean height [m]",
         ylabel = "Potential growth · community height reduction\n[kg ha⁻¹]")
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


function community_height_influence(; path = nothing)
    trait_input = input_traits()
    for k in keys(trait_input)
        @reset trait_input[k] = [mean(trait_input[k])]
    end
    input_obj = validation_input(;
        plotID = "HEG01", nspecies = 1);
    input_obj.daily_input.grazing .= NaN * u"ha^-1"
    input_obj.daily_input.mowing .= NaN * u"m"
    p = Parameter()

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

    fig = Figure(; size = (600, 600))

    Axis(fig[1, 1]; limits = (nothing, nothing, 0, nothing),
         title = "Without community height reduction",
         xlabel = "", ylabel = "", xticklabelsvisible = false)
    t, s, l = sim_community_height(; community_height_red = false)
    lines!(t, l; label = "1.0 m")
    lines!(t, s; label = "0.1 m")

    Axis(fig[2, 1]; limits = (nothing, nothing, 0, nothing),
        title = "With community height reduction",
        xlabel = "Date [year]", ylabel = "")
    t, s, l = sim_community_height(; community_height_red = true)
    lines!(t, l; label = "1.0 m")
    lines!(t, s; label = "0.1 m")
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
