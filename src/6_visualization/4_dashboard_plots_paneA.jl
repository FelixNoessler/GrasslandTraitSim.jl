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
    axes[:simulated_abp] = Axis(layout[1, 3]; alignmode = Inside(),
                                ylabel = "Aboveground biomass per total biomass [-]",
                                xticklabelsvisible = false)

    axes[:soilwater] = Axis(layout[2, 1]; alignmode = Inside(),
                            ylabel = "Soil water [mm]", xlabel = "Time [years]",
                            limits=(nothing, nothing, 0.0, nothing))
    axes[:functional_dispersion] = Axis(layout[2, 2]; alignmode = Inside(),
                                        ylabel = "Functional dispersion [-]",
                                        xlabel = "Time [year]")
    axes[:trait_share] = Axis(layout[2, 3]; alignmode = Inside(),
                              ylabel = "Relative proportion", xlabel = "Time [year]")
    axes[:cb_trait_share] = Colorbar(layout[2, 4]; halign = :left,
                                     limits = (0.0, 1.0))

    return axes
end


function update_plots_paneA(; kwargs...)
    biomass_plot(; kwargs...)
    simulated_height_plot(; kwargs...)
    simulated_aboveground_proportion(; kwargs...)
    soilwater_plot(; kwargs...)
    functional_dispersion_plot(; kwargs...)
    trait_share_plot(; kwargs...)
end

function biomass_plot(;
    plot_obj,
    patch = 1,
    sol,
    valid_data, kwargs...)

    ax = clear_plotobj_axes(plot_obj, :biomass)

    thin = 20
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

        unique_type = unique(valid_data.biomass_type)
        color_types = [findfirst(t .== unique_type) for t in valid_data.biomass_type]

        scatter!(ax, num_t, biomass, color = color_types, markersize = 6)
    end

    return nothing
end

function soilwater_plot(; sol, plot_obj, kwargs...)
    ax = clear_plotobj_axes(plot_obj, :soilwater)

    thin = 1
    t = sol.simp.output_date_num[1:thin:end]
    water_μ = mean(ustrip.(sol.output.water); dims = (:x, :y))[1:thin:end]
    lines!(ax, t, water_μ; color = :turquoise3, linewidth = 2)

    PWP = mean(ustrip(sol.patch_variables.PWP))
    WHC = mean(ustrip(sol.patch_variables.WHC))
    lines!(ax, [sol.simp.output_date_num[1], sol.simp.output_date_num[end]], [PWP, PWP];
        color = :blue)
    lines!(ax, [sol.simp.output_date_num[1], sol.simp.output_date_num[end]], [WHC, WHC];
        color = :blue)
end

function trait_share_plot(; plot_obj, sol, kwargs...)

    trait_names = Dict(
        :sla => "Specific leaf area [m² g⁻¹]",
        :lnc => "Leaf nitrogen per leaf mass [mg g⁻¹]",
        :height => "Potential height [m]",
        :amc => "Arbuscular mycorrhizal colonisation [-]",
        :srsa => "Root surface area per belowground biomass [m² g⁻¹]",
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
    alpha_val = min.(10 .* mean_species_biomass ./ mean_total_biomass, 1)

    for s in 1:sol.simp.nspecies
        lines!(ax, sol.simp.output_date_num, species_above_proportion[:, s],
               color = (:grey, alpha_val[s]))
    end
    lines!(ax, sol.simp.output_date_num, vec(above_proportion), color = :black)

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
    alpha_val = min.(10 .* mean_species_biomass ./ mean_total_biomass, 1)

    for s in 1:sol.simp.nspecies
        lines!(ax, sol.simp.output_date_num, ustrip.(height)[:, s],
               color = (:grey, alpha_val[s]))
    end
    lines!(ax, sol.simp.output_date_num, ustrip(mean_height), color = :black)

    if !isnothing(valid_data)
        num_t = sol.simp.output_date_num[LookupArrays.index(valid_data.height, :time)]
        y = vec(valid_data.height)
        scatter!(ax, num_t, y, color = :black, markersize = 8)
    end

    return nothing
end


function functional_dispersion_plot(; plot_obj, sol, valid_data, kwargs...)
    ax = clear_plotobj_axes(plot_obj, :functional_dispersion)

    traits = (; height = sol.traits.height, sla = sol.traits.sla, lnc = sol.traits.lnc)
    biomass = dropdims(
        mean(ustrip.(sol.output.biomass); dims = (:x, :y)); dims =(:x, :y))

    fdis = functional_dispersion(traits, biomass; )

    lines!(ax, sol.simp.output_date_num, fdis; color = :red)

    if !isnothing(valid_data)
        num_t = valid_data.fun_diversity.num_t
        y = valid_data.fun_diversity.fdis
        scatter!(ax, num_t, y, color = :black, markersize = 8)
    end

    return nothing
end

function traits_to_matrix(trait_data; std_traits = true)
    trait_names = keys(trait_data)
    ntraits = length(trait_names)
    nspecies = length(trait_data[trait_names[1]])
    m = Matrix{Float64}(undef, nspecies, ntraits)

    for i in eachindex(trait_names)

        if std_traits
            m[:, i] = trait_data[trait_names[i]] ./ mean(trait_data[trait_names[i]])
        else
            m[:, i] = ustrip.(trait_data[trait_names[i]])
        end
    end

    return m
end

function functional_dispersion(trait_data, biomass_data; kwargs...)
    # Laliberté & Legendre 2010, checked results with fundiversity R package

    ntimesteps = size(biomass_data, :time)
    nspecies = size(biomass_data, :species)
    ntraits = length(trait_data)
    fdis = Vector{Float64}(undef, ntimesteps)

    trait_m = traits_to_matrix(trait_data; kwargs...)

    for t in 1:ntimesteps
        relative_biomass = biomass_data[t, :] / sum(biomass_data[t, :])

        z_squarred = zeros(nspecies)
        for t in 1:ntraits
            weighted_trait = trait_m[:, t] .* relative_biomass
            cwm = sum(weighted_trait)
            z_squarred .+= (trait_m[:, t] .- cwm) .^ 2
        end

        z = sqrt.(z_squarred)
        fdis[t] = sum(z .* relative_biomass)
    end

    return fdis
end
