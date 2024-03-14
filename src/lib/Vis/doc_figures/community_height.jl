function plot_community_height(; sim, valid, path = nothing)
    trait_input = valid.input_traits()
    for k in keys(trait_input)
        trait_input = @set trait_input[k] = [mean(trait_input[k])]
    end
    input_obj = valid.validation_input(;
        plotID = "HEG01", nspecies = 1);
    input_obj.daily_input.grazing .= NaN * u"ha^-1"
    input_obj.daily_input.mowing .= NaN * u"m"
    p = sim.Parameter()

    sol = sim.solve_prob(; input_obj, p, trait_input);

    biomass = [1000.0, 2000.0, 3000.0]
    heights = LinRange(0.01, 2, 300)
    red = Array{Float64}(undef, length(heights), 3)


    for (bi, b) in enumerate(biomass)
        sol.u.u_biomass[1, 1, :] .= b * u"kg / ha"

        for (hi, h) in enumerate(heights)
            sol = @set sol.traits.height = [h * u"m"]
            r = sim.community_height_reduction(;
                container = sol, biomass = sol.u.u_biomass[1,1,:])
            red[hi, bi] = r
        end
    end

    fig = Figure()
    Axis(fig[1,1]; xlabel = "Height [m]", ylabel = "Reduction factor")
    linewidth = 3.0
    lines!(heights, red[:, 1]; label = "1000", linewidth)
    lines!(heights, red[:, 2]; label = "2000", linewidth)
    lines!(heights, red[:, 3]; label = "3000", linewidth)
    axislegend("Dry aboveground\nbiomass [kg ha⁻¹]"; framevisible = false, position = :rb)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end


function community_height_influence(; sim, valid, path = nothing)
    trait_input = valid.input_traits()
    for k in keys(trait_input)
        trait_input = @set trait_input[k] = [mean(trait_input[k])]
    end
    input_obj = valid.validation_input(;
        plotID = "HEG01", nspecies = 1);
    input_obj.daily_input.grazing .= NaN * u"ha^-1"
    input_obj.daily_input.mowing .= NaN * u"m"
    p = sim.Parameter()

    function sim_community_height(; α, β, community_height_red)
        p = @set p.α_community_height = α * u"kg / ha"
        p = @set p.β_community_height = β * u"ha / kg"
        input_obj = @set input_obj.simp.included.community_height_red .= community_height_red
        trait_input = @set trait_input.height = [0.1u"m"]
        sol_small = sim.solve_prob(; input_obj, p, trait_input);
        s = vec(ustrip.(sol_small.output.biomass[:, 1, 1, 1]))

        trait_input = @set trait_input.height = [1.0u"m"]
        sol_large = sim.solve_prob(; input_obj, p, trait_input);
        l = vec(ustrip.(sol_large.output.biomass[:, 1, 1, 1]))

        return sol_small.numeric_date, s, l
    end

    fig = Figure(; size = (700, 1000))
    Axis(fig[1, 1]; limits = (nothing, nothing, 0, nothing),
         title = "Without community height reduction",
         xlabel = "", ylabel = "")
    t, s, l = sim_community_height(; α = 10000, β = 0.0005, community_height_red = false)
    lines!(t, l; label = "1.0 m")
    lines!(t, s; label = "0.1 m")
    axislegend(; framevisible = false)

    α, β = 10000, 0.00005
    Axis(fig[2, 1]; limits = (nothing, nothing, 0, nothing),
        title = "α = $α [kg ha⁻¹ m⁻¹] β = $β [ha m kg⁻¹]",
        xlabel = "", ylabel = "Dry aboveground biomass [kg/ha]")
    t, s, l = sim_community_height(; α, β, community_height_red = true)
    lines!(t, l; label = "1.0 m")
    lines!(t, s; label = "0.1 m")

    α, β = 10000, 0.0005
    Axis(fig[3, 1]; limits = (nothing, nothing, 0, nothing),
        title = "α = $α [kg ha⁻¹ m⁻¹] β = $β [ha m kg⁻¹]",
        xlabel = "Date [year]", ylabel = "")
    t, s, l = sim_community_height(; α, β, community_height_red = true)
    lines!(t, l; label = "1.0 m")
    lines!(t, s; label = "0.1 m")

    α, β = 30000, 0.0005
    Axis(fig[4, 1]; limits = (nothing, nothing, 0, nothing),
        title = "α = $α [kg ha⁻¹ m⁻¹] β = $β [ha m kg⁻¹]",
        xlabel = "Date [year]", ylabel = "")
    t, s, l = sim_community_height(; α, β, community_height_red = true)
    lines!(t, l; label = "1.0 m")
    lines!(t, s; label = "0.1 m")

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
