function create_axes_paneC(layout)
    axes = Dict()

    axes[:static_water_reducer] = Axis(layout[1, 1];
        xlabel = "Scaled soil water content",
        ylabel = "Growth reduction factor (Wred)\n← stronger reduction, less reduction →",
        title = "Water growth reducer",
        limits = (0, 1, -0.05, 1.05),
        alignmode = Inside())
    axes[:static_nutrient_reducer] = Axis(layout[1, 2];
        xlabel = "Nutrient index",
        ylabel = "Growth reduction factor (Nutred)\n← stronger reduction, less reduction →",
        title = "Nutrient growth reducer",
        limits = (0, 1, -0.05, 1.05),
        alignmode = Inside())

    axes[:water_reducer] = Axis(layout[2, 1];
                                limits = (nothing, nothing, -0.05, 1.05))
    axes[:nutrient_reducer] = Axis(layout[2, 2];
                                   limits = (nothing, nothing, -0.05, 1.05))
    axes[:root_invest] = Axis(layout[2, 3];
                              limits = (nothing, nothing, -0.05, 1.05),
                              title = "Root investment")

    return axes
end

function update_plots_paneC(; kwargs...)
    plot_static_nutrient_reducer(; kwargs...)
    plot_static_water_reducer(; kwargs...)

    plot_water_reducer(; kwargs...)
    plot_nutrient_reducer(; kwargs...)
    plot_root_invest(; kwargs...)
end

function plot_static_nutrient_reducer(; plot_obj, sol, kwargs...)
    ax = clear_plotobj_axes(plot_obj, :static_nutrient_reducer)

    real_nutrients = mean(sol.patch_variables.nutrients; dims = (:x, :y))[1, 1]
    nspecies = sol.simp.nspecies
    δ_namc = sol.p.δ_namc
    δ_nrsa = sol.p.δ_nrsa
    srsa = sol.traits.srsa
    amc = sol.traits.amc
    abp = sol.traits.abp

    xs = LinRange(0.0, 1.0, 20)
    ymat_amc = fill(0.0, length(xs), nspecies)
    ymat_rsa = fill(0.0, length(xs), nspecies)
    ymat_both = fill(0.0, length(xs), nspecies)

    @. sol.calc.above_proportion = abp
    @. sol.calc.nutrients_adj_factor = 1.0

    for (i, x) in enumerate(xs)
        nutrient_reduction!(; container = sol, nutrients = x)
        ymat_amc[i, :] .= sol.calc.N_amc
        ymat_rsa[i, :] .= sol.calc.N_rsa
        ymat_both[i, :] .= sol.calc.Nutred
    end

    for i in Base.OneTo(nspecies)
        lines!(ax, xs, ymat_amc[:, i]; color = (:darkorange, 0.2))
        lines!(ax, xs, ymat_rsa[:, i]; color = (:indianred, 0.2))
        lines!(ax, xs, ymat_both[:, i]; color = (:black, 0.6))
    end
    vlines!(ax, real_nutrients, color = :blue)


    return nothing
end

function plot_static_water_reducer(; plot_obj, sol, kwargs...)
    ax = clear_plotobj_axes(plot_obj, :static_water_reducer)

    nspecies = sol.simp.nspecies
    xs = LinRange(-0.1, 1.1, 200)
    ymat = fill(0.0, length(xs), nspecies)

    WHC = 1u"mm"
    PWP = 0u"mm"
    W = 1 * u"mm"

    total_biomass = fill(2, nspecies)u"kg/ha"
    above_biomass = sol.traits.abp .* total_biomass
    @. sol.calc.above_proportion = above_biomass / total_biomass

    for (i, x) in enumerate(xs)
        water_reduction!(; container = sol, W = x * u"mm", PWP, WHC)
        ymat[i, :] .= sol.calc.Waterred
    end

    idx = sortperm(sol.traits.srsa)
    R_05 = sol.transfer_function.R_05[idx]
    srsa = ustrip.(sol.traits.srsa[idx])
    abp = sol.traits.abp[idx]
    ymat = ymat[:, idx]

    fig = Figure(size = (1000, 500))
    ax1 = Axis(fig[1, 1],
        xlabel = "Plant available water (W_sc)",
        ylabel = "Growth reduction factor (W_rsa)\n← stronger reduction, less reduction →",
        limits = (-0.05, 1.05, -0.1, 1.1))

    for i in eachindex(R_05)
        lines!(ax, xs, ymat[:, i]; color = (:black, 0.3))
    end

    scatter!([0.4], [sol.p.α_wrsa_05];
        markersize = 15,
        color = :red)

    return nothing
end

function plot_water_reducer(; plot_obj, sol, kwargs...)
    ax = clear_plotobj_axes(plot_obj, :water_reducer)

    water_reducer = dropdims(mean(sol.output.water_growth; dims = (:x, :y));
                             dims = (:x, :y))

    for s in 1:sol.simp.nspecies
        lines!(ax, sol.simp.mean_input_date_num, water_reducer[:, s];
               color = (:black, 0.2))
    end
end

function plot_nutrient_reducer(; plot_obj, sol, kwargs...)
    ax = clear_plotobj_axes(plot_obj, :nutrient_reducer)

    nutrient_reducer = dropdims(mean(sol.output.nutrient_growth; dims = (:x, :y));
                             dims = (:x, :y))

    for s in 1:sol.simp.nspecies
        lines!(ax, sol.simp.mean_input_date_num, nutrient_reducer[:, s];
               color = (:black, 0.2))
    end
end

function plot_root_invest(; plot_obj, sol, kwargs...)
    ax = clear_plotobj_axes(plot_obj, :root_invest)

    root_invest = dropdims(mean(sol.output.root_invest; dims = (:x, :y));
                             dims = (:x, :y))

    for s in 1:sol.simp.nspecies
        lines!(ax, sol.simp.mean_input_date_num, root_invest[:, s];
               color = (:black, 0.2))
    end
end
