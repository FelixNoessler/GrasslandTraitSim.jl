function plot_community_height(; path = nothing)
    trait_input = input_traits()
    for k in keys(trait_input)
        trait_input = @set trait_input[k] = [mean(trait_input[k])]
    end
    input_obj = validation_input(;
        plotID = "HEG01", nspecies = 1);
    input_obj.daily_input.grazing .= NaN * u"ha^-1"
    input_obj.daily_input.mowing .= NaN * u"m"
    p = Parameter()

    sol = solve_prob(; input_obj, p, trait_input);


    heights = LinRange(0.01, 2, 300)
    red = Array{Float64}(undef, length(heights))

    for (hi, h) in enumerate(heights)
        sol = @set sol.traits.height = [h * u"m"]
        r = community_height_reduction(;
            container = sol, biomass = sol.u.u_biomass[1,1,:])
        red[hi] = r
    end

    fig = Figure()
    Axis(fig[1,1]; xlabel = "Community weighted mean height [m]",
         ylabel = "Reduction factor [-]")
    linewidth = 3.0
    lines!(heights, red; linewidth)

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
        trait_input = @set trait_input[k] = [mean(trait_input[k])]
    end
    input_obj = validation_input(;
        plotID = "HEG01", nspecies = 1);
    input_obj.daily_input.grazing .= NaN * u"ha^-1"
    input_obj.daily_input.mowing .= NaN * u"m"
    p = Parameter()

    function sim_community_height(; α, β, community_height_red)
        p = @set p.α_community_height = α
        p = @set p.β_community_height = β
        input_obj = @set input_obj.simp.included.community_height_red .= community_height_red
        trait_input = @set trait_input.height = [0.1u"m"]
        sol_small = solve_prob(; input_obj, p, trait_input);
        s = vec(ustrip.(sol_small.output.biomass[:, 1, 1, 1]))

        trait_input = @set trait_input.height = [1.0u"m"]
        sol_large = solve_prob(; input_obj, p, trait_input);
        l = vec(ustrip.(sol_large.output.biomass[:, 1, 1, 1]))

        return sol_small.numeric_date, s, l
    end

    fig = Figure(; size = (700, 1000))

    α, β = 0.0u"m", 2.0u"m^-1"
    Axis(fig[1, 1]; limits = (nothing, nothing, 0, nothing),
         title = "Without community height reduction",
         xlabel = "", ylabel = "")
    t, s, l = sim_community_height(; α, β, community_height_red = false)
    lines!(t, l; label = "1.0 m")
    lines!(t, s; label = "0.1 m")

    α, β = 0.0u"m", 2.0u"m^-1"
    Axis(fig[2, 1]; limits = (nothing, nothing, 0, nothing),
        title = "α = $α, β = $β",
        xlabel = "", ylabel = "Dry aboveground biomass [kg ha⁻¹]")
    t, s, l = sim_community_height(; α, β, community_height_red = true)
    lines!(t, l; label = "1.0 m")
    lines!(t, s; label = "0.1 m")

    α, β = -0.5u"m", 2.0u"m^-1"
    Axis(fig[3, 1]; limits = (nothing, nothing, 0, nothing),
        title = "α = $α, β = $β",
        xlabel = "Date [year]", ylabel = "")
    t, s, l = sim_community_height(; α, β, community_height_red = true)
    lines!(t, l; label = "1.0 m")
    lines!(t, s; label = "0.1 m")
    axislegend(; framevisible = false, position = :rb)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
