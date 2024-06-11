function create_axes_paneB(layout)
    axes = Dict()
    axes[:sla] = Axis(layout[1, 1]; alignmode = Inside(),
                      xticklabelsvisible = false,
                      ylabel = "Specific leaf\narea [m² g⁻¹]")
    axes[:height] = Axis(layout[1, 2]; alignmode = Inside(),
                         xticklabelsvisible = false,
                         ylabel = "Potential height [m]")
    axes[:lnc] = Axis(layout[1, 3]; alignmode = Inside(),
                      xticklabelsvisible = false,
                      ylabel = "Leaf nitrogen per\nleaf mass [mg g⁻¹]")
    axes[:srsa] = Axis(layout[2, 1]; alignmode = Inside(), xlabel = "Time [years]",
                       ylabel = "Root surface area per\nbelowground biomass [m² g⁻¹]")
    axes[:amc] = Axis(layout[2, 2]; alignmode = Inside(), xlabel = "Time [years]",
                      ylabel = "Arbuscular mycorrhizal\ncolonisation [-]")
    axes[:abp] = Axis(layout[2, 3]; alignmode = Inside(), xlabel = "Time [years]",
                      ylabel = "Potential aboveground biomass\nper total biomass [-]")

    return axes
end

function update_plots_paneB(; kwargs...)
    for t in [:amc, :sla, :height, :srsa, :lnc, :abp]
        trait_time_plot(; trait = t, kwargs...)
    end
end

function trait_time_plot(; sol, valid_data, plot_obj, trait, kwargs...)
    ax = clear_plotobj_axes(plot_obj, trait)

    thin = 30
    t = sol.simp.output_date_num
    trait_vals = ustrip.(sol.traits[trait])

    species_biomass = dropdims(
        mean(ustrip.(sol.output.biomass); dims = (:x, :y)); dims =(:x, :y))
    total_biomass = sum(species_biomass, dims = :species)
    relative_biomass = species_biomass ./ total_biomass

    ##  mean
    weighted_trait = Matrix(trait_vals .* relative_biomass')
    cwm_trait = vec(sum(weighted_trait; dims = 1))
    cwv_trait = sqrt.(vec(sum(relative_biomass .* (cwm_trait .- trait_vals') .^ 2; dims = 2)))

    ### trait values of all species
    for i in 1:(sol.simp.nspecies)
        trait_i = trait_vals[i]
        lines!(ax, [t[1], t[end]], [trait_i, trait_i], color = (:grey, 0.2))
    end

    cwm_trait_dist = Normal.(cwm_trait, sol.p[Symbol("b_$trait")])
    median_trait = median.(cwm_trait_dist)

    lines!(ax, t[1:thin:end], median_trait[1:thin:end], color = :blue)
    band!(ax, t[1:thin:end], median_trait[1:thin:end] .+ cwv_trait[1:thin:end],
          median_trait[1:thin:end] .- cwv_trait[1:thin:end];
          color = (:blue, 0.3))

    if !isnothing(valid_data)
        cwm_trait_dist_sub = cwm_trait_dist[LookupArrays.index(valid_data.traits, :time)]
        tsub = t[LookupArrays.index(valid_data.traits, :time)]
        lower_trait = quantile.(cwm_trait_dist_sub, 0.025)
        upper_trait = quantile.(cwm_trait_dist_sub, 0.975)
        lower5_trait = quantile.(cwm_trait_dist_sub, 0.25)
        upper5_trait = quantile.(cwm_trait_dist_sub, 0.75)
        # rangebars!(ax, tsub, lower_trait, upper_trait; color = (:black, 0.3))
        # rangebars!(ax, tsub, lower5_trait, upper5_trait; color = (:black, 0.3), linewidth = 2)
        num_t = sol.simp.output_date_num[LookupArrays.index(valid_data.traits, :time)]
        y = vec(valid_data.traits[trait = At(trait)])
        scatter!(ax, num_t, y, color = :black, markersize = 8)
    end
end
