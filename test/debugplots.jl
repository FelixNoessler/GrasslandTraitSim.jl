using CairoMakie

using GrasslandTraitSim: input_traits, validation_input, SimulationParameter, preallocate_vectors,
    preallocate_specific_vectors, initialization, potential_growth!, solve_prob, nutrient_reduction!,
    radiation_reduction!, temperature_reduction!, water_reduction!, root_investment!, root_investment!

function create_container_for_plotting(; nspecies = nothing, param = (;), θ = nothing, kwargs...)
    trait_input = if isnothing(nspecies)
        input_traits()
    else
        nothing
    end

    if isnothing(nspecies)
        nspecies = length(trait_input.amc)
    end

    input_obj = validation_input(;
        plotID = "HEG01", nspecies, kwargs...)
    p = SimulationParameter(;)

    if !isnothing(θ)
        for k in keys(θ)
                p[k] = θ[k]
            end
        end

    if !isnothing(param) && !isempty(param)
        for k in keys(param)
            p[k] = param[k]
        end
    end

    prealloc = preallocate_vectors(; input_obj);
    prealloc_specific = preallocate_specific_vectors(; input_obj);
    container = initialization(; input_obj, p, prealloc, prealloc_specific,
                                   trait_input)

    return nspecies, container
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

            ymat[hi, i] = ustrip(container.calc.com.growth_pot_total)
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
            pot_gr = ustrip(container.calc.com.growth_pot_total)

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
        red[hi] = container.calc.com.RUE_community_height
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


################################################################
# Plots for light competition
################################################################
function plot_height_influence(; θ = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; θ)

    height_strength_exps = LinRange(0.0, 1.5, 40)
    above_biomass = fill(50, nspecies)u"kg / ha"
    ymat = Array{Float64}(undef, nspecies, length(height_strength_exps))
    orig_β_LIG_H = container.p.β_LIG_H

    ### otherwise the function won't be calculated
    ### the LAI is not used in the hieght influence function
    container.calc.com.LAItot = 0.2 * nspecies

    for (i, β_LIG_H) in enumerate(height_strength_exps)
        @reset container.p.β_LIG_H = β_LIG_H
        LIG!(; container, above_biomass,
                           actual_height = container.traits.height)
        ymat[:, i] .= container.calc.heightinfluence
    end

    idx = sortperm(container.traits.height)
    height = ustrip.(container.traits.height)[idx]


    ymat = ymat[idx, :]
    colorrange = (minimum(height), maximum(height))

    mean_val = (mean(height) - minimum(height)) / (maximum(height) - minimum(height) )
    colormap = Makie.diverging_palette(0, 230; mid=mean_val)

    fig = Figure(; size = (700, 400))
    ax = Axis(fig[1, 1];
        ylabel = "Plant height growth factor (heightinfluence)",
        xlabel = "Influence strength of the plant height (β_LIG_H)",
        yticks = 0.0:5.0)

    for i in Base.OneTo(nspecies)
        lines!(height_strength_exps, ymat[i, :];
            linewidth = 3,
            color = height[i],
            colorrange = colorrange,
            colormap = colormap)
    end

    lines!(height_strength_exps, ones(length(height_strength_exps));
        linewidth = 2,
        linestyle = :dash,
        color = :red)
    # vlines!(orig_β_LIG_H)
    Colorbar(fig[1, 2]; colormap, colorrange, label = "Plant height [m]")

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end


################################################################
# Plots for nutrient competition
################################################################
function plot_N_amc(; θ = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; θ)
    @reset container.simp.included.belowground_competition = false
    container.calc.nutrients_adj_factor .= 1.0
    xs = LinRange(0.0, 1.0, 200)
    ymat = fill(0.0, length(xs), nspecies)
    abp = container.traits.abp
    @. container.calc.above_proportion = abp
    for (i, x) in enumerate(xs)
        nutrient_reduction!(; container, nutrients = x,
                            total_biomass = fill(50.0u"kg/ha", nspecies))
        ymat[i, :] .= container.calc.N_amc
    end

    @unpack δ_NUT_amc, α_NUT_amc05, ϕ_TAMC = container.p
    @unpack amc = container.traits
    @unpack above_proportion = container.calc
    x0_R_05 = ϕ_TAMC + 1 / δ_NUT_amc * log((1 - α_NUT_amc05) / α_NUT_amc05)
    R_05 = @. 1 / (1 + exp(-δ_NUT_amc * ((1 - above_proportion) * amc - x0_R_05)))

    amc = container.traits.amc
    amc_total = (1 .- abp) .* amc
    colorrange = (minimum(amc_total), maximum(amc_total))

    fig = Figure(size = (1000, 500))

    ax1 = Axis(fig[1, 1];
        xlabel = "Nutrient index (Np)",
        ylabel = "Growth reduction factor (N_amc)\n← stronger reduction, less reduction →",
        title = "Influence of the mycorrhizal colonisation",
        limits = (-0.05, 1.05, -0.1, 1.1))
    for (i, r05) in enumerate(R_05)
        lines!(xs, ymat[:, i];
            color = amc_total[i],
            colorrange)
        scatter!([0.5], [r05];
            marker = :x,
            color = amc_total[i],
            colorrange)
    end
    scatter!([0.5], [container.p.α_NUT_amc05];
        markersize = 15,
        color = :red)

    ax2 = Axis(fig[1, 2];
        xlabel = "Arbuscular mycorrhizal colonisation\nper total biomass [-]",
        ylabel = "Growth reducer at Np = 0.5 (R_05)")
    scatter!(amc_total, R_05;
        marker = :x,
        color = amc_total,
        colorrange)
    scatter!([ustrip(container.p.ϕ_TAMC)], [container.p.α_NUT_amc05];
        markersize = 15,
        color = :red)

    Colorbar(fig[1, 3]; colorrange,
             label = "Arbuscular mycorrhizal colonisation\nper total biomass [-]")

    linkyaxes!(ax1, ax2)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end


function plot_N_srsa(; θ = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; θ)
    @reset container.simp.included.belowground_competition = false
    container.calc.nutrients_adj_factor .= 1.0
    xs = LinRange(0, 1.0, 200)
    ymat = fill(0.0, length(xs), nspecies)
    abp = container.traits.abp
    @. container.calc.above_proportion = abp
    for (i, x) in enumerate(xs)
        nutrient_reduction!(; container, nutrients = x,
                            total_biomass = fill(50.0u"kg/ha", nspecies))
        ymat[i, :] .= container.calc.N_rsa
    end

    @unpack δ_NUT_rsa, α_NUT_rsa05, ϕ_TRSA = container.p
    @unpack rsa = container.traits
    @unpack above_proportion = container.calc
    x0_R_05 = ϕ_TRSA + 1 / δ_NUT_rsa * log((1 - α_NUT_rsa05) / α_NUT_rsa05)
    R_05 = @. 1 / (1 + exp(-δ_NUT_rsa * ((1 - above_proportion) * rsa - x0_R_05)))

    rsa = ustrip.(container.traits.rsa)
    rsa_total = (1 .- abp) .* rsa
    colorrange = (minimum(rsa_total), maximum(rsa_total))

    fig = Figure(size = (1000, 500))

    ax1 = Axis(fig[2, 1],
        xlabel = "Nutrient index (Np)",
        ylabel = "Growth reduction factor (N_rsa)\n← stronger reduction, less reduction →",
        limits = (-0.05, 1.05, -0.1, 1.1))
    for (i, r05) in enumerate(R_05)
        lines!(xs, ymat[:, i];
            color = rsa_total[i],
            colorrange)
        scatter!([0.5], [r05];
            marker = :x,
            color = rsa_total[i],
            colorrange)
    end
    scatter!([0.5], [container.p.α_NUT_rsa05];
        markersize = 15,
        color = :red)


    ax2 = Axis(fig[2, 2];
        xlabel = "Root surface area per total biomass [m² g⁻¹]",
        ylabel = "Growth reducer at Np = 0.5 (R_05)")
    scatter!(rsa_total, R_05;
        marker = :x,
        color = rsa_total,
        colorrange)
    scatter!([ustrip(container.p.ϕ_TRSA)], [container.p.α_NUT_rsa05];
        markersize = 15,
        color = :red)

    Label(fig[1, 1:2], "Influence of the root surface area per total biomass on the nutrient stress growth reducer";
        halign = :left,
        font = :bold)

    Colorbar(fig[2, 3]; colorrange, label = "Root surface area per total biomass [m² g⁻¹]")

    linkyaxes!(ax1, ax2)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end

function plot_nutrient_adjustment(; θ = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; θ)
    @unpack α_NUT_TSB, α_NUT_maxadj = container.p

    TS_B = LinRange(0, 1.5 * ustrip(α_NUT_TSB), 200)u"kg / ha"
    nutrients_adj_factor = @. α_NUT_maxadj * exp(log(1/α_NUT_maxadj) / α_NUT_TSB * TS_B)


    fig = Figure()
    Axis(fig[1, 1]; xlabel = "∑ TS ⋅ B [kg ⋅ ha⁻¹]",
         ylabel = "nutrient adjustment factor [-]")
    lines!(ustrip.(TS_B), nutrients_adj_factor; linestyle = :solid, color = :coral2, linewidth = 2)

    hlines!(1; linestyle = :dash, color = :black)

    scatter!([ustrip(α_NUT_TSB), 0.0], [1.0, α_NUT_maxadj])
    text!(ustrip(α_NUT_TSB), 1.0; text = "α_NUT_TSB")

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end


################################################################
# Plots for water competition
################################################################
function plot_W_srsa(; θ = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; θ)
    xs = LinRange(0.0, 1.0, 200)
    ymat = fill(0.0, length(xs), nspecies)
    WHC = 1u"mm"
    PWP = 0u"mm"
    W = 1 * u"mm"
    abp = container.traits.abp
    @. container.calc.above_proportion = abp
    for (i, x) in enumerate(xs)
        water_reduction!(; container, W = x * u"mm", PWP, WHC)
        ymat[i, :] .= container.calc.WAT
    end

    R_05 = container.transfer_function.R_05
    rsa = ustrip.(container.traits.rsa)
    rsa_total = (1 .- abp) .* rsa
    colorrange = (minimum(rsa_total), maximum(rsa_total))

    fig = Figure(size = (1000, 500))

    ax1 = Axis(fig[1, 1],
        xlabel = "Plant available water (W_sc)",
        ylabel = "Growth reduction factor (W_rsa)\n← stronger reduction, less reduction →",
        limits = (-0.05, 1.05, -0.1, 1.1))
    for (i, r05) in enumerate(R_05)
        lines!(xs, ymat[:, i];
            color = rsa_total[i],
            colorrange)
        scatter!([0.5], [r05];
            marker = :x,
            color = rsa_total[i],
            colorrange)
    end
    scatter!([0.5], [container.p.α_WAT_rsa05];
        markersize = 15,
        color = :red)

    ax2 = Axis(fig[1, 2];
        xlabel = "Root surface area per total biomass [m² g⁻¹]",
        ylabel = "Growth reducer at Wsc = 0.5 (R_05)")
    scatter!(rsa_total, R_05;
        marker = :x,
        color = rsa_total,
        colorrange)
    scatter!([ustrip(container.p.ϕ_TRSA)], [container.p.α_WAT_rsa05];
        markersize = 15,
        color = :red)

    Label(fig[0, 1:2], "Influence of the root surface area per total biomass on the water stress growth reducer";
        halign = :left,
        font = :bold)
    Colorbar(fig[1, 3]; colorrange, label = "Root surface area per total biomass [m² g⁻¹]")

    linkyaxes!(ax1, ax2)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end

################################################################
# Plots for root investmet
################################################################
function plot_root_investment(; θ = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; θ)
    @unpack p = container
    container.calc.above_proportion .= mean(container.traits.abp)

    ########## artifical traits - for line
    nspecies_line = 100
    _, container_line = create_container_for_plotting(; θ, nspecies = nspecies_line)
    container_line.traits.amc .= LinRange(0, 0.8, nspecies_line)
    container_line.traits.rsa .= LinRange(0, 0.4, nspecies_line)u"m^2 / g"
    container_line.calc.above_proportion .= mean(container.traits.abp)

    colormap = (:viridis, 0.3)

    fig = Figure(size = (600, 700))
    Axis(fig[1, 1];
         ylabel = "Growth reduction due to\ninvestment in mycorrhiza\n← stronger reduction, less reduction →",
         xlabel = "Arbuscular mycorrhizal colonisation rate (amc) [-]",
         limits = (nothing, nothing, -0.05, 1.05))
    colorrange = (0.0, maximum([p.κ_ROOT_amc, p.κ_ROOT_rsa, 1.0]))

    root_investment!(; container)
    root_investment!(; container=container_line)

    root_invest_amc_l = copy(container_line.calc.root_invest_amc)
    root_invest_srsa_l = copy(container_line.calc.root_invest_srsa)

    for x in LinRange(0.0, colorrange[2], 12)
        container_line.p.κ_ROOT_amc = x
        root_investment!(; container = container_line)
        lines!(container_line.traits.amc, container_line.calc.root_invest_amc;
               color = x, colorrange, colormap)
    end
    Colorbar(fig[1, 2]; colorrange, label = "κ_ROOT_amc [-]")

    lines!(container_line.traits.amc, root_invest_amc_l; color = p.κ_ROOT_amc,
           colorrange)
    scatter!(container.traits.amc, container.calc.root_invest_amc; color = p.κ_ROOT_amc,
             colorrange)

    Axis(fig[2, 1];
              ylabel = "Growth reduction due to\ninvestment in root surface area per\nbelowground biomass\n← stronger reduction, less reduction →",
              xlabel = "Root surface area per belowground biomass (rsa) [-]",
              limits = (nothing, nothing, -0.05, 1.05))
    for x in LinRange(0, colorrange[2], 12)
        container_line.p.κ_ROOT_rsa = x
        root_investment!(; container = container_line)
        lines!(ustrip.(container_line.traits.rsa), container_line.calc.root_invest_srsa;
               color = x, colorrange, colormap)
    end
    Colorbar(fig[2, 2]; colorrange, label = "κ_ROOT_rsa [-]")

    lines!(ustrip.(container_line.traits.rsa), root_invest_srsa_l;
           color =  p.κ_ROOT_rsa, colorrange)
    scatter!(ustrip.(container.traits.rsa), container.calc.root_invest_srsa;
             color = p.κ_ROOT_rsa, colorrange)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end

################################################################
# Plots for radiation, temperature and seasonal effects
################################################################
function plot_radiation_reducer(; PARs = LinRange(0.0, 15.0 * 100^2, 1000)u"MJ / ha",
    θ = nothing, path = nothing)

    nspecies, container = create_container_for_plotting(; nspecies = 1, θ)
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

function plot_temperature_reducer(; Ts = collect(LinRange(0.0, 40.0, 500)) .* u"°C",
     θ = nothing, path = nothing)

    nspecies, container = create_container_for_plotting(; nspecies = 1, θ)

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

function plot_seasonal_effect(; θ = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; nspecies = 1, θ)
    STs = LinRange(0, 3500, 1000)
    y  = Float64[]
    for ST in STs
        seasonal_reduction!(; ST = ST * u"°C", container)
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

    ylims!(-0.05, 2.5)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end


################################################################
# Plots for senescence
################################################################
function plot_seasonal_component_senescence(;
    STs = LinRange(0, 4000, 500),
    θ = nothing, path = nothing)

    nspecies, container = create_container_for_plotting(; nspecies = 1, θ)
    STs = sort(STs)

    y = Float64[]
    for ST in STs
        g = seasonal_component_senescence(; container, ST = ST * u"°C")
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


function plot_senescence_rate(; θ = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; θ)
    @unpack sla = container.traits
    @unpack β_sen_sla, α_sen_month = container.p
    @unpack p = container
    nvals = 200
    β_sen_sla_values = LinRange(0, 2, nvals)
    ymat = Array{Float64}(undef, nvals, nspecies)

    for i in eachindex(β_sen_sla_values)
        p.β_sen_sla = β_sen_sla_values[i]
        initialize_senescence_rate!(; container)
        @. ymat[i, :] = container.calc.μ
    end

    sla_plot = ustrip.(sla)
    colorrange = (minimum(sla_plot), maximum(sla_plot))
    fig = Figure()
    Axis(fig[1,1]; xlabel = "β_sen_sla [Mg ha⁻¹]", ylabel = "Senescence rate [-]")

    for i in 1:nspecies
        lines!(β_sen_sla_values, ymat[:, i]; color = sla_plot[i], colorrange)
    end
    hlines!(α_sen_month; color = :orange, linewidth = 3, linestyle = :dash)
    vlines!(ustrip(β_sen_sla))
    text!(1.5, α_sen_month * 1.01, text = "α_sen_month";)

    Colorbar(fig[1, 2]; colorrange, label = "Specific leaf area [m² g⁻¹]")


    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end

################################################################
# Plots for grazing
################################################################
function plot_grazing(; α_GRZ = nothing, β_GRZ_lnc = nothing, θ = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; θ)

    if !isnothing(α_GRZ)
        container.p.α_GRZ = α_GRZ
    end

    if !isnothing(β_GRZ_lnc)
        container.p.β_GRZ_lnc = β_GRZ_lnc
    end

    nbiomass = 80
    LD = 2u"ha ^ -1"
    biomass_vec = LinRange(0, 500, nbiomass)u"kg / ha"
    grazing_mat = Array{Float64}(undef, nspecies, nbiomass)

    for (i, biomass_val) in enumerate(biomass_vec)
        container.calc.defoliation .= 0.0u"kg / ha"
        above_biomass = 1 ./ container.traits.abp .* biomass_val

        grazing!(; container, LD, above_biomass, actual_height = container.traits.height)
        grazing_mat[:, i] = ustrip.(container.calc.defoliation)
    end

    idx = sortperm(container.traits.lnc)
    lnc = ustrip.(container.traits.lnc)[idx]
    grazing_mat = grazing_mat[idx, :]
    colorrange = (minimum(lnc), maximum(lnc))

    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1],
        xlabel = "Aboveground biomass per species [kg ha⁻¹]",
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

function plot_η_GRZ(; θ = nothing, path = nothing)
    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1],
        xlabel = "Total biomass [dry mass kg ha⁻¹]",
        ylabel = "Grazed biomass (totgraz)\n[dry mass kg ha⁻¹]",
        title = "")

    for η_GRZ in [1, 5, 10, 20]
        x = LinRange(0, 3000, 120)

        LD = 2
        κ_GRZ = 22

        k_exp = 2
        y = @. LD * κ_GRZ * x^k_exp / ((κ_GRZ * η_GRZ)^k_exp + x^k_exp)

        lines!(x, y, label = "$(κ_GRZ * η_GRZ)",
            linewidth = 3)
    end

    axislegend("η_GRZ"; framevisible = true, position = :rb)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end
end

################################################################
# Plots for mowing
################################################################
function plot_mowing(; mowing_height = 0.07u"m",
    θ = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; θ)

    nbiomass = 50
    max_biomass = 150
    biomass_vec = LinRange(0, max_biomass, nbiomass)u"kg / ha"
    mowing_mat = Array{Float64}(undef, nspecies, nbiomass)



    for (i, biomass_i) in enumerate(biomass_vec)
        above_biomass = 1 ./ container.traits.abp .* biomass_i


        container.calc.defoliation .= 0.0u"kg / ha"
        mowing!(; container, mowing_height, actual_height = container.traits.height,
                above_biomass)

        mowing_mat[:, i] = ustrip.(container.calc.defoliation)
    end

    idx = sortperm(container.traits.height)
    height = ustrip.(container.traits.height)[idx]
    mowing_mat = mowing_mat[idx, :]
    colorrange = (minimum(height), maximum(height))
    colormap = :viridis

    fig = Figure(; )
    Axis(fig[1, 1],
        xlabel = "Aboveground biomass per species [kg ha⁻¹]",
        ylabel = """Amount of aboveground biomass that is
                removed by mowing (mow) [kg ha⁻¹]""",
        title = "",
        width = 400, height = 400)

    for i in 1:nspecies
        lines!(ustrip.(biomass_vec), mowing_mat[i, :];
        linewidth = 3, color = height[i], colorrange, colormap)
        lines!([0, max_biomass], [0, max_biomass]; linestyle = :dash, color = (:black, 0.01))
    end

    Colorbar(fig[1, 2]; colorrange, colormap, label = "Plant height [m]")

    resize_to_layout!(fig)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
