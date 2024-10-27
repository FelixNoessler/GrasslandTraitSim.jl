function create_axes_paneB(layout)
    axes = Dict()
    axes[:sla] = Axis(layout[1, 1]; alignmode = Inside(),
                      xticklabelsvisible = false,
                      ylabel = "Specific leaf\narea [m² g⁻¹]")
    axes[:maxheight] = Axis(layout[1, 2]; alignmode = Inside(),
                         xticklabelsvisible = false,
                         ylabel = "Potential height [m]")
    axes[:lnc] = Axis(layout[1, 3]; alignmode = Inside(),
                      xticklabelsvisible = false,
                      ylabel = "Leaf nitrogen per\nleaf mass [mg g⁻¹]")
    axes[:rsa] = Axis(layout[2, 1]; alignmode = Inside(), xlabel = "Time [years]",
                       ylabel = "Root surface area per\nbelowground biomass [m² g⁻¹]")
    axes[:amc] = Axis(layout[2, 2]; alignmode = Inside(), xlabel = "Time [years]",
                      ylabel = "Arbuscular mycorrhizal\ncolonisation [-]")
    axes[:abp] = Axis(layout[2, 3]; alignmode = Inside(), xlabel = "Time [years]",
                      ylabel = "Potential aboveground biomass\nper total biomass [-]")


    axes[:trait_share] = Axis(layout[3, 1:2]; alignmode = Inside(),
                      ylabel = "Relative proportion", xlabel = "Time [year]",
                      xticks = 2006:2023)
    axes[:cb_trait_share] = Colorbar(layout[3, 3]; halign = :left,
                             limits = (0.0, 1.0), tellwidth = false)


    return axes
end

function update_plots_paneB(; kwargs...)
    for t in [:amc, :sla, :maxheight, :rsa, :lnc, :abp]
        trait_time_plot(; trait = t, kwargs...)
    end
    trait_share_plot(; kwargs...)
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

    lines!(ax, t[1:thin:end], cwm_trait[1:thin:end], color = :blue)
    band!(ax, t[1:thin:end], cwm_trait[1:thin:end] .+ cwv_trait[1:thin:end],
    cwm_trait[1:thin:end] .- cwv_trait[1:thin:end];
          color = (:blue, 0.3))

    if !isnothing(valid_data)
        num_t = sol.simp.output_date_num[LookupArrays.index(valid_data.traits, :time)]
        y = vec(valid_data.traits[trait = At(trait)])
        scatter!(ax, num_t, y, color = :black, markersize = 8)
    end
end

function trait_share_plot(; plot_obj, sol, kwargs...)

    trait_names = Dict(
        :sla => "Specific leaf area [m² g⁻¹]",
        :lnc => "Leaf nitrogen per leaf mass [mg g⁻¹]",
        :maxheight => "Maximum height [m]",
        :amc => "Arbuscular mycorrhizal colonisation [-]",
        :rsa => "Root surface area per belowground biomass [m² g⁻¹]",
        :abp => "Aboveground biomass per total biomass [-]"
    )

    trait = plot_obj.obs.menu_traits.selection.val
    ax = clear_plotobj_axes(plot_obj, :trait_share)

    color = ustrip.(sol.traits[trait])
    colormap = :viridis
    colorrange = (minimum(color), maximum(color))
    is = sortperm(color)
    cmap = cgrad(colormap)
    colors = [cmap[(co .- colorrange[1]) ./ (colorrange[2] - colorrange[1])]
            for co in color[is]]

    # calculate biomass proportion of each species
    biomass_site = dropdims(mean(sol.output.biomass; dims=(:x, :y)); dims = (:x, :y))
    biomass_ordered = biomass_site[:, sortperm(color)]
    biomass_fraction = biomass_ordered ./ sum(biomass_ordered; dims = :species)
    biomass_cumfraction = cumsum(biomass_fraction; dims = 2)

    limits!(ax, sol.simp.output_date_num[1], sol.simp.output_date_num[end], 0, 1)

    for i in 1:sol.simp.nspecies
        ylower = nothing
        if i == 1
            ylower = zeros(size(biomass_cumfraction, 1))
        else
            ylower = biomass_cumfraction[:, i-1]
        end
        yupper = biomass_cumfraction[:, i]

        band!(ax, sol.simp.output_date_num, vec(ylower), vec(yupper);
              color = colors[i])
    end

    plot_obj.axes[:cb_trait_share].limits[] = colorrange
    plot_obj.axes[:cb_trait_share].label[] = trait_names[trait]

    return nothing
end
