function create_axes_paneA(layout)
    axes = Dict()
    axes[:biomass] = Axis(layout[1, 1]; alignmode = Inside(),
                          limits = (nothing, nothing, -100.0, nothing),
                          ylabel = "Aboveground biomass [kg ha⁻¹]",
                          xticklabelsvisible = false)

    axes[:simulated_height] = Axis(layout[1, 2]; alignmode = Inside(),
                                   ylabel = "Height [m]",
                                   limits = (nothing, nothing, -0.05, 0.71),
                                   yticks = 0.0:0.1:1.5, xticklabelsvisible = false)
    axes[:simulated_abp] = Axis(layout[2, 1]; alignmode = Inside(),
                                ylabel = "Aboveground biomass per total biomass [-]",
                                xticklabelsvisible = false)

    axes[:soilwater] = Axis(layout[2, 2]; alignmode = Inside(),
                            ylabel = "Soil water [mm]", xlabel = "Time [years]",
                            limits=(nothing, nothing, 0.0, nothing))

    return axes
end


function update_plots_paneA(; kwargs...)
    biomass_plot(; kwargs...)
    simulated_height_plot(; kwargs...)
    simulated_aboveground_proportion(; kwargs...)
    soilwater_plot(; kwargs...)


end

function biomass_plot(; plot_obj, sol, valid_data, kwargs...)
    ax = clear_plotobj_axes(plot_obj, :biomass)

    thin = 1
    t = sol.simp.output_date_num

    show_standingbiomass = plot_obj.obs.toggle_standingbiomass.active.val
    if show_standingbiomass
        biomass = vec(sum(ustrip.(sol.output.above_biomass); dims = (:x, :y, :species))) ./
                    sol.simp.npatches
        lines!(ax, t, biomass; color = :orange, linewidth = 2)

        # mean_speciesbiomass = biomass ./ sol.simp.nspecies
        # species_biomass = dropdims(mean(ustrip.(sol.output.biomass); dims = (:x, :y)); dims = (:x, :y))
        # biomass_var = vec(sum((mean_speciesbiomass .- species_biomass) .^ 2; dims = :species)) ./ mean_speciesbiomass
        # lines!(ax, t, biomass .+ biomass_var; color = :orange, linestyle = :dash, linewidth = 2)
        # lines!(ax, t, biomass .- biomass_var; color = :orange, linestyle = :dash, linewidth = 2)
    end

    show_grazmow = plot_obj.obs.toggle_grazmow.active.val
    if show_grazmow
        # -------------- grazing
        yupper = (.! isnan.(sol.input.LD_grazing)) .* 5500.0
        ylower = fill(0.0, length(yupper))
        band!(ax, sol.simp.mean_input_date_num, ylower, yupper;
            color = (:steelblue4, 0.6))

        # -------------- mowing
        mowing_f = .! isnan.(sol.input.CUT_mowing)
        xs = sol.simp.mean_input_date_num[mowing_f]

        for x in xs
            lines!(ax, [x, x], [0.0, 5500.0]; color = :magenta3)
        end
    end

    if !isnothing(valid_data)
        cutbiomass_μ = vec(ustrip.(sol.valid.cut_biomass))
        t = sol.simp.output_date_num[sol.valid.biomass_cutting_t]

        biomass_dist = Normal.(cutbiomass_μ, sol.p.b_biomass)
        biomass_median = median.(biomass_dist)

        scatter!(ax, t[1:thin:end], biomass_median[1:thin:end]; color = :orange)

        biomass_lower = quantile.(biomass_dist, 0.025)
        biomass_upper = quantile.(biomass_dist, 0.975)
        biomass_lower5 = quantile.(biomass_dist, 0.25)
        biomass_upper5 = quantile.(biomass_dist, 0.75)

        # rangebars!(ax, t[1:thin:end], biomass_lower[1:thin:end],
        #     biomass_upper[1:thin:end]; color = (:black, 0.3), linewidth = 1)
        # rangebars!(ax, t[1:thin:end], biomass_lower5[1:thin:end],
        #     biomass_upper5[1:thin:end]; color = (:black, 0.3), linewidth = 2)

        biomass = ustrip.(valid_data.biomass)
        num_t = sol.simp.output_date_num[LookupArrays.index(valid_data.biomass, :time)]

        # unique_type = unique(valid_data.biomass_type)
        # color_types = [findfirst(t .== unique_type) for t in valid_data.biomass_type]

        scatter!(ax, num_t, biomass, color = :black, markersize = 6)
    end

    return nothing
end

function soilwater_plot(; sol, plot_obj, kwargs...)
    ax = clear_plotobj_axes(plot_obj, :soilwater)

    thin = 1
    t = sol.simp.output_date_num[1:thin:end]
    water_μ = mean(ustrip.(sol.output.water); dims = (:x, :y))[1:thin:end]
    lines!(ax, t, water_μ; color = :orange, linewidth = 2)

    PWP = mean(ustrip(sol.patch_variables.PWP))
    WHC = mean(ustrip(sol.patch_variables.WHC))
    hlines!([PWP, WHC]; color = :blue)
end


function simulated_aboveground_proportion(; plot_obj, sol, valid_data, kwargs...)
    ax = clear_plotobj_axes(plot_obj, :simulated_abp)

    ###### calculate biomass weighted proportion of aboveground biomass / total biomass
    species_totalbiomass = dropdims(
        mean(ustrip.(sol.output.biomass); dims = (:x, :y)); dims =(:x, :y))
    totalbiomass = sum(species_totalbiomass, dims = :species)
    species_abovegroundbiomass = dropdims(
        mean(ustrip.(sol.output.above_biomass); dims = (:x, :y)); dims =(:x, :y))
    species_above_proportion = species_abovegroundbiomass ./ species_totalbiomass
    relative_biomass = species_totalbiomass ./ totalbiomass
    above_proportion = dropdims(sum(species_above_proportion .* relative_biomass;
                                    dims = :species); dims = :species)

    ###### calculate alpha values
    mean_species_biomass = vec(mean(species_totalbiomass; dims = (:time)))
    mean_total_biomass = sum(mean_species_biomass)
    alpha_val = min.(2 .* mean_species_biomass ./ mean_total_biomass, 1)

    for s in 1:sol.simp.nspecies
        lines!(ax, sol.simp.output_date_num, species_above_proportion[:, s],
               color = (:grey, alpha_val[s]))
    end
    lines!(ax, sol.simp.output_date_num, vec(above_proportion), color = :orange,
           linewidth = 2)

    return nothing
end

function simulated_height_plot(; plot_obj, sol, valid_data, kwargs...)
    ax = clear_plotobj_axes(plot_obj, :simulated_height)

    species_biomass = dropdims(
        mean(ustrip.(sol.output.biomass); dims = (:x, :y)); dims =(:x, :y))
    total_biomass = sum(species_biomass, dims = :species)
    relative_biomass = species_biomass ./ total_biomass
    height = dropdims(
        mean(sol.output.height; dims = (:x, :y)),
        dims = (:x, :y))
    mean_height = vec(sum(height .* relative_biomass; dims = :species))

    ###### calculate alpha values
    mean_species_biomass = vec(mean(species_biomass; dims = (:time)))
    mean_total_biomass = sum(mean_species_biomass)
    alpha_val = min.(2 .* mean_species_biomass ./ mean_total_biomass, 1)

    for s in 1:sol.simp.nspecies
        lines!(ax, sol.simp.output_date_num, ustrip.(height)[:, s],
               color = (:grey, alpha_val[s]))
    end
    lines!(ax, sol.simp.output_date_num, ustrip(mean_height), color = :orange)

    if !isnothing(valid_data)
        num_t = sol.simp.output_date_num[LookupArrays.index(valid_data.height, :time)]
        y = vec(valid_data.height)
        scatter!(ax, num_t, y, color = :black, markersize = 8)
    end

    return nothing
end
