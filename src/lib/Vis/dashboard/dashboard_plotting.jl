function band_patch(;
        plot_obj,
        patch = 1,
        sol,
        valid_data,
        predictive_data)
    ax = plot_obj.axes[:biomass]
    empty!(ax)

    ax.ylabel = "Green biomass [kg ha⁻¹]"
    ax.xlabel = "Time [years]"

    thin = 7

    t = sol.numeric_date
    biomass_μ = vec(sum(ustrip.(sol.output.biomass); dims = (:x, :y, :species))) ./
                sol.simp.npatches
    biomass_dist = truncated.(Laplace.(biomass_μ, sol.p.b_biomass); lower = 0)
    biomass_median = median.(biomass_dist)
    biomass_lower = quantile.(biomass_dist, 0.025)
    biomass_upper = quantile.(biomass_dist, 0.975)
    biomass_lower5 = quantile.(biomass_dist, 0.25)
    biomass_upper5 = quantile.(biomass_dist, 0.75)

    band!(ax, t[1:thin:end], biomass_lower[1:thin:end],
        biomass_upper[1:thin:end]; color = (:black, 0.1))
    band!(ax, t[1:thin:end], biomass_lower5[1:thin:end],
        biomass_upper5[1:thin:end]; color = (:black, 0.1))
    lines!(ax, t[1:thin:end], biomass_median[1:thin:end]; color = :orange)


    show_grazmow = plot_obj.obs.toggle_grazmow.active.val
    if show_grazmow
        ymax = maximum(biomass_median) * 1.5

        # -------------- grazing
        ylower = fill(0.0, length(sol.daily_input.grazing))
        yupper = (.! isnan.(sol.daily_input.grazing)) .* ymax
        band!(ax, sol.numeric_date, ylower, yupper;
            color = (:steelblue4, 0.6))

        # -------------- mowing
        mowing_f = .! isnan.(sol.daily_input.mowing)
        xs = sol.numeric_date[mowing_f]

        for x in xs
            lines!(ax, [x, x], [0.0, ymax]; color = :magenta3)
        end
    end



    if !isnothing(valid_data)
        biomass = ustrip.(valid_data.biomass)
        num_t = sol.numeric_date[LookupArrays.index(valid_data.biomass, :time)]

        scatter!(ax, num_t, biomass, color = :black, markersize = 8)
    end

    if !isnothing(predictive_data)
        scatter!(ax, t[predictive_data.t_biomass], predictive_data.biomass;
            color = :red, markersize = 8)
    end

    return nothing
end



# function trait_mean_biomass(;
#         sol,
#         markersize = 15,
#         patch = 1,
#         t, plot_obj, ax_num = 3)
#     ax = plot_obj.axes[ax_num]
#     empty!(ax)

#     trait = plot_obj.obs.menu_color.selection.val
#     name_index = getindex.([plot_obj.obs.menu_color.options.val...], 2) .== trait
#     trait_name = first.([plot_obj.obs.menu_color.options.val...])[name_index][1]
#     color = ustrip.(sol.traits[trait])
#     colormap = :viridis
#     colorrange = (minimum(color), maximum(color) + 0.0001)

#     print_date = Dates.format(sol.date[t], "dd.mm.yyyy")

#     ax.ylabel = "Biomass at $(print_date) [kg ha⁻¹]"
#     ax.xlabel = trait_name

#     scatter!(ax,
#         ustrip.(sol.traits[trait]),
#         ustrip.(sol.o.biomass[t, patch, :]);
#         color, colormap, colorrange,
#         markersize)

#     return nothing
# end

function soilwater_plot(; sol, plot_obj)
    ax = plot_obj.axes[:soilwater]
    empty!(ax)

    thin = 7
    t = sol.numeric_date[1:thin:end]

    water_μ = mean(ustrip.(sol.output.water); dims = (:x, :y))[1:thin:end]
    lines!(ax, t, water_μ; color = :turquoise3, markersize = 6, linewidth = 2)

    PWP = mean(ustrip(sol.patch_variables.PWP))
    WHC = mean(ustrip(sol.patch_variables.WHC))
    lines!(ax, [sol.numeric_date[1], sol.numeric_date[end]], [PWP, PWP];
        color = :blue)
    lines!(ax, [sol.numeric_date[1], sol.numeric_date[end]], [WHC, WHC];
        color = :blue)
    ax.ylabel = "Soil water [mm]"
    ax.xlabel = "Time [years]"
    # ylims!(ax, 0.0, nothing)
end

function abiotic_plot(; sol, plot_obj)
    thin = 7

    ax = plot_obj.axes[:abiotic]
    empty!(ax)
    abiotic_colors = [:blue, :brown, :red, :red, :orange]
    abiotic = plot_obj.obs.menu_abiotic.selection.val
    name_index = getindex.([plot_obj.obs.menu_abiotic.options.val...], 2) .== abiotic
    abiotic_name = first.([plot_obj.obs.menu_abiotic.options.val...])[name_index][1]
    abiotic_color = abiotic_colors[name_index][1]

    scatterlines!(ax, sol.numeric_date[1:thin:end],
        ustrip.(sol.daily_input[abiotic])[1:thin:end];
        color = abiotic_color, markersize = 4, linewidth = 0.1)
    ax.ylabel = abiotic_name
    ax.xlabel = "Time [years]"
end

function trait_time_plot(; sol, valid_data, plot_obj, trait)
    ax = plot_obj.axes[trait]
    empty!(ax)
    t = sol.numeric_date

    trait_names = [
        "Specific leaf area [m² g⁻¹]", "Leaf nitrogen \nper leaf mass [mg g⁻¹]",
        "Height [m]", "Mycorrhizal colonisation",
        "Root surface area /\nabove ground biomass [m² g⁻¹]"]
    trait_symbols = [:sla, :lncm, :height, :amc, :rsa_above]
    name_index = trait_symbols .== trait
    trait_name = trait_names[name_index][1]

    trait_vals = ustrip.(sol.traits[trait])

    species_biomass = dropdims(
        mean(ustrip.(sol.output.biomass); dims = (:x, :y)); dims =(:x, :y))
    total_biomass = sum(species_biomass, dims = :species)
    relative_biomass = species_biomass ./ total_biomass

    ##  mean
    weighted_trait = trait_vals .* relative_biomass'
    cwm_trait = vec(sum(weighted_trait; dims = 1))

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
        cwm_trait_dist = Beta.(α, β)
    else
        cwm_trait_dist = truncated.(
            Laplace.(cwm_trait, sol.p[Symbol("b_$trait")]);
            lower = 0)
    end

    median_trait = median.(cwm_trait_dist)
    lower_trait = quantile.(cwm_trait_dist, 0.025)
    upper_trait = quantile.(cwm_trait_dist, 0.975)
    lower5_trait = quantile.(cwm_trait_dist, 0.25)
    upper5_trait = quantile.(cwm_trait_dist, 0.75)

    band!(ax, t, lower_trait, upper_trait; color = (:black, 0.1))
    band!(ax, t, lower5_trait, upper5_trait; color = (:black, 0.1))
    lines!(ax, t, median_trait, color = :blue)
    ax.ylabel = "CWM: $trait_name"

    if !isnothing(valid_data)
        num_t = sol.numeric_date[LookupArrays.index(valid_data.traits, :time)]
        y = vec(valid_data.traits[trait = At(trait)])
        scatter!(ax, num_t, y, color = :black, markersize = 8)
    end
end
