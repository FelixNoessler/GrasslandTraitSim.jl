function band_patch(;
        plot_obj,
        patch = 1,
        sol,
        valid_data)
    ax = plot_obj.axes[:biomass]
    empty!(ax)
    ax.ylabel = "Green biomass [kg ha⁻¹]"
    ax.xlabel = "Time [years]"

    thin = 1

    t = sol.simp.output_date_num

    show_standingbiomass = plot_obj.obs.toggle_standingbiomass.active.val
    if show_standingbiomass
        biomass = vec(sum(ustrip.(sol.output.biomass); dims = (:x, :y, :species))) ./
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

        rangebars!(ax, t[1:thin:end], biomass_lower[1:thin:end],
            biomass_upper[1:thin:end]; color = (:black, 0.3), linewidth = 1)
        rangebars!(ax, t[1:thin:end], biomass_lower5[1:thin:end],
            biomass_upper5[1:thin:end]; color = (:black, 0.3), linewidth = 2)

        biomass = ustrip.(valid_data.biomass)
        num_t = sol.simp.output_date_num[LookupArrays.index(valid_data.biomass, :time)]

        unique_type = unique(valid_data.biomass_type)
        color_types = [findfirst(t .== unique_type) for t in valid_data.biomass_type]

        scatter!(ax, num_t, biomass, color = color_types, markersize = 6)
    end

    return nothing
end

function soilwater_plot(; sol, plot_obj)
    ax = plot_obj.axes[:soilwater]
    empty!(ax)

    thin = 1
    t = sol.simp.output_date_num[1:thin:end]

    water_μ = mean(ustrip.(sol.output.water); dims = (:x, :y))[1:thin:end]
    lines!(ax, t, water_μ; color = :turquoise3, markersize = 6, linewidth = 2)

    PWP = mean(ustrip(sol.patch_variables.PWP))
    WHC = mean(ustrip(sol.patch_variables.WHC))
    lines!(ax, [sol.simp.output_date_num[1], sol.simp.output_date_num[end]], [PWP, PWP];
        color = :blue)
    lines!(ax, [sol.simp.output_date_num[1], sol.simp.output_date_num[end]], [WHC, WHC];
        color = :blue)
    ax.ylabel = "Soil water [mm]"
    ax.xlabel = "Time [years]"
    ylims!(ax, 0.0, nothing)
end

function abiotic_plot(; sol, plot_obj)
    thin = 1

    ax = plot_obj.axes[:abiotic]
    empty!(ax)
    abiotic_colors = [:blue, :brown, :red, :red, :orange]
    abiotic = plot_obj.obs.menu_abiotic.selection.val
    name_index = getindex.([plot_obj.obs.menu_abiotic.options.val...], 2) .== abiotic
    abiotic_name = first.([plot_obj.obs.menu_abiotic.options.val...])[name_index][1]
    abiotic_color = abiotic_colors[name_index][1]

    scatterlines!(ax, sol.simp.mean_input_date_num[1:thin:end],
        ustrip.(sol.input[abiotic])[1:thin:end];
        color = abiotic_color, markersize = 4, linewidth = 0.1)
    ax.ylabel = abiotic_name
    ax.xlabel = "Time [years]"
end

function trait_time_plot(; sol, valid_data, plot_obj, trait)
    ax = plot_obj.axes[trait]
    empty!(ax)
    t = sol.simp.output_date_num

    trait_names = [
        "Specific leaf area [m² g⁻¹]", "Leaf nitrogen \nper leaf mass [mg g⁻¹]",
        "Height [m]", "Mycorrhizal colonisation",
        "Root surface area /\nabove ground biomass [m² g⁻¹]"]
    trait_symbols = [:sla, :lnc, :height, :amc, :rsa]
    name_index = trait_symbols .== trait
    trait_name = trait_names[name_index][1]

    trait_vals = ustrip.(sol.traits[trait])

    species_biomass = dropdims(
        mean(ustrip.(sol.output.biomass); dims = (:x, :y)); dims =(:x, :y))
    total_biomass = sum(species_biomass, dims = :species)
    relative_biomass = species_biomass ./ total_biomass

    ##  mean
    weighted_trait = Matrix(trait_vals .* relative_biomass')
    cwm_trait = vec(sum(weighted_trait; dims = 1))
    cwv_trait = sqrt.(vec(sum(relative_biomass .* (cwm_trait .- trait_vals') .^ 2; dims = 2)))
    ax.xlabel = "Time [years]"

    ### trait values of all species
    for i in 1:(sol.simp.nspecies)
        trait_i = trait_vals[i]
        lines!(ax, [t[1], t[end]], [trait_i, trait_i], color = (:grey, 0.2))
    end

    cwm_trait_dist = nothing
    if trait == :amc
        μ = cwm_trait
        φ = 1 / sol.p.b_amc
        α = @. μ * φ
        β = @. (1.0 - μ) * φ

        try
            cwm_trait_dist = Beta.(α, β)
        catch e
            @warn "Error in Beta distribution: $e"
            return nothing
        end
    else
        cwm_trait_dist = Laplace.(cwm_trait, sol.p[Symbol("b_$trait")])
    end

    median_trait = median.(cwm_trait_dist)

    lines!(ax, t, median_trait, color = :blue)
    band!(ax, t, median_trait .+ cwv_trait, median_trait .- cwv_trait;
        color = (:blue, 0.3))
    ax.ylabel = "CWM: $trait_name"

    if !isnothing(valid_data)
        cwm_trait_dist_sub = cwm_trait_dist[LookupArrays.index(valid_data.traits, :time)]
        tsub = t[LookupArrays.index(valid_data.traits, :time)]
        lower_trait = quantile.(cwm_trait_dist_sub, 0.025)
        upper_trait = quantile.(cwm_trait_dist_sub, 0.975)
        lower5_trait = quantile.(cwm_trait_dist_sub, 0.25)
        upper5_trait = quantile.(cwm_trait_dist_sub, 0.75)
        rangebars!(ax, tsub, lower_trait, upper_trait; color = (:black, 0.3))
        rangebars!(ax, tsub, lower5_trait, upper5_trait; color = (:black, 0.3), linewidth = 2)
        num_t = sol.simp.output_date_num[LookupArrays.index(valid_data.traits, :time)]
        y = vec(valid_data.traits[trait = At(trait)])
        scatter!(ax, num_t, y, color = :black, markersize = 8)

        if trait == :height
            num_t = sol.simp.output_date_num[LookupArrays.index(valid_data.height, :time)]
            y = vec(valid_data.height)
            scatter!(ax, num_t, y, color = :darkgrey, markersize = 8)
        end
    end
end
