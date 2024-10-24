"""
Calculate the total potential growth of the plant community.
"""
function potential_growth!(; container, above_biomass, actual_height, PAR)
    @unpack included = container.simp
    @unpack com = container.calc

    calculate_LAI!(; container, above_biomass)

    if !included.potential_growth || iszero(com.LAItot)
        @info "Zero potential growth!" maxlog=1
        com.potgrowth_total = 0.0u"kg / ha"
        return nothing
    end

    if !included.community_self_shading
        @info "No community height growth reduction!" maxlog=1
        com.self_shading = 1.0
    else
        @unpack relative_height = container.calc
        @unpack self_shading_severity = container.p

        ## community weighted mean height
        relative_height .= above_biomass ./ sum(above_biomass) .* actual_height
        cwm_height = sum(relative_height)

        # self_shading_severity is the growth reduction factor ∈ [0, 1]
        # at a community weighted mean height of 0.2 m
        # 0.4 means that the growth is reduced by 60 % with a community weighted mean height of 0.2 m
        com.self_shading = exp(log(self_shading_severity)*0.2u"m" / cwm_height)
    end

    @unpack γ_RUEmax, γ_k = container.p
    com.potgrowth_total = PAR * γ_RUEmax * (1 - exp(-γ_k * com.LAItot)) * com.self_shading

    return nothing
end

"""
Calculate the leaf area index of all species.
"""
function calculate_LAI!(; container, above_biomass)
    @unpack LAIs, com = container.calc
    @unpack sla, lbp, abp = container.traits

    for s in eachindex(LAIs)
        LAIs[s] = uconvert(NoUnits, sla[s] * above_biomass[s] * lbp[s] / abp[s]) # TODO
    end
    com.LAItot = sum(LAIs)

    return nothing
end


################################################################
# Plots for potential growth
################################################################
function plot_potential_growth_lai_height(; θ = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; θ)
    above_biomass = container.u.u_biomass[1, 1, :]
    biomass_vals = LinRange(1, 100, 150)u"kg / ha"

    height_vals = reverse([0.1, 0.5, 1.5, 1e10]u"m")
    ymat = Array{Float64}(undef, length(height_vals), length(biomass_vals))
    lai_tot = Array{Float64}(undef, length(biomass_vals))

    for (hi, h) in enumerate(height_vals)
        container.traits.height .= h
        for (i,b) in enumerate(biomass_vals)
            above_biomass .= b
            potential_growth!(; container, above_biomass,
                                actual_height = container.traits.height,
                                PAR = container.input.PAR[150])

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

function plot_potential_growth_height_lai(; θ = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; θ)
    biomass_val = [50.0, 35.0, 10.0]u"kg / ha"
    above_biomass = container.u.u_biomass[1,1,:]
    lais = zeros(3)
    heights = LinRange(0.01, 1.5, 300)
    red = Array{Float64}(undef, 3, length(heights))
    for (li, l) in enumerate(lais)
        for (hi, h) in enumerate(heights)
            above_biomass .= biomass_val[li]
            @reset container.traits.height = [h * u"m"]

            potential_growth!(; container, above_biomass,
                              actual_height = container.traits.height,
                              PAR = container.input.PAR[150])
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
    axislegend("Total leaf\narea index [-]"; framevisible = true, position = :rb)

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
function plot_lai_traits(; path = nothing)
    nspecies, container = create_container_for_plotting(; θ = nothing)
    above_biomass = container.u.u_above_biomass[1, 1, :]

    potential_growth!(; container, above_biomass, actual_height = container.traits.height,
                      PAR = container.input.PAR[150])
    val = container.calc.LAIs

    idx = sortperm(container.traits.sla)
    ymat = val[idx]
    sla = ustrip.(container.traits.sla[idx])

    abp = (container.traits.abp)[idx]
    colorrange = (minimum(abp), maximum(abp))
    colormap = :viridis

    fig = Figure()
    ax = Axis(fig[1, 1]; xlabel = "Specific leaf area [m² g⁻¹]", ylabel = "Leaf area index [-]", title = "")
    sc = scatter!(sla, ustrip(ymat), color = abp, colormap = colormap)
    Colorbar(fig[1,2], sc; label = "Aboveground biomass per total biomass")

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return fig
end

################################################################
# Plots for community height reduction
################################################################
function plot_potential_growth_height(; θ = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; θ)
    above_biomass = container.u.u_biomass[1,1,:]

    heights = LinRange(0.01, 2, 300)
    red = Array{Float64}(undef, length(heights))

    for (hi, h) in enumerate(heights)
        @reset container.traits.height = [h * u"m"]
        potential_growth!(; container, above_biomass,
                          actual_height = container.traits.height,
                          PAR = container.input.PAR[150])
        red[hi] = container.calc.com.self_shading
    end

    fig = Figure()
    Axis(fig[1,1]; xlabel = "Community weighted mean height [m]",
         ylabel = "Community height growth reduction factor [-]")
    lines!(heights, red; linewidth = 3.0)
    ylims!(0, 1.01)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end

function plot_community_height_influence(; θ = nothing, path = nothing)
    trait_input = input_traits()
    for k in keys(trait_input)
        @reset trait_input[k] = [mean(trait_input[k])]
    end
    input_obj = validation_input(;
        plotID = "HEG01", nspecies = 1);
    input_obj.input.LD_grazing .= NaN * u"ha^-1"
    input_obj.input.CUT_mowing .= NaN * u"m"
    p = SimulationParameter()
    if !isnothing(θ)
        for k in keys(θ)
            p[k] = θ[k]
        end
    end

    function sim_community_height(; community_self_shading)
        @reset input_obj.simp.included.community_self_shading .= community_self_shading
        @reset trait_input.height = [0.1u"m"]
        sol_small = solve_prob(; input_obj, p, trait_input);
        s = vec(ustrip.(sol_small.output.biomass[:, 1, 1, 1]))

        @reset trait_input.height = [1.0u"m"]
        sol_large = solve_prob(; input_obj, p, trait_input);
        l = vec(ustrip.(sol_large.output.biomass[:, 1, 1, 1]))

        return sol_small.simp.output_date_num, s, l
    end
    tstep = 30

    fig = Figure(; size = (600, 600))

    Axis(fig[1, 1]; limits = (nothing, nothing, 0, nothing),
         title = "Without community height reduction",
         xlabel = "", ylabel = "", xticklabelsvisible = false)
    t, s, l = sim_community_height(; community_self_shading = false)
    lines!(t[1:tstep:end], l[1:tstep:end]; label = "1.0 m")
    lines!(t[1:tstep:end], s[1:tstep:end]; label = "0.1 m")

    Axis(fig[2, 1]; limits = (nothing, nothing, 0, nothing),
        title = "With community height reduction",
        xlabel = "Date [year]", ylabel = "")
    t, s, l = sim_community_height(; community_self_shading = true)

    lines!(t[1:tstep:end], l[1:tstep:end]; label = "1.0 m")
    lines!(t[1:tstep:end], s[1:tstep:end]; label = "0.1 m")
    axislegend(; framevisible = false, position = :rt)

    Label(fig[1:2, 0], "Total biomass [kg ha⁻¹]",
          rotation= pi/2, fontsize = 16)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
