function band_patch(;
        plot_obj,
        patch = 1,
        sol,
        valid_data,
        predictive_data,
        ax_num = 1)
    ax = plot_obj.axes[ax_num]
    empty!(ax)

    ax.ylabel = "Green biomass [kg ha⁻¹]"
    ax.xlabel = "Time [years]"

    thin = 7

    t = sol.numeric_date
    biomass_μ = vec(sum(ustrip.(sol.o.biomass); dims = 2:3)) ./
                sol.simp.npatches
    biomass_dist = truncated.(Laplace.(biomass_μ, sol.p.b_biomass); lower = 0)
    biomass_median = median.(biomass_dist)
    biomass_lower = quantile.(biomass_dist, 0.025)
    biomass_upper = quantile.(biomass_dist, 0.975)
    biomass_lower5 = quantile.(biomass_dist, 0.25)
    biomass_upper5 = quantile.(biomass_dist, 0.75)

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

    show_bands = plot_obj.obs.toggle_bands.active.val
    if show_bands
        trait = plot_obj.obs.menu_color.selection.val
        color = ustrip.(sol.traits[trait])
        colormap = :viridis
        colorrange = (minimum(color), maximum(color) + 0.0001)
        is = sortperm(color)
        cmap = cgrad(colormap)
        colors = [cmap[(co .- colorrange[1]) ./ (colorrange[2] - colorrange[1])]
                  for co in color[is]]

        biomass_cumsum = zeros(size(sol.o.biomass, 1))
        for i in eachindex(is)
            biomass_i = ustrip.(uconvert.(u"kg / ha", sol.o.biomass[:, patch, is[i]]))
            band!(ax, t[1:thin:end], biomass_cumsum[1:thin:end],
                biomass_cumsum[1:thin:end] + biomass_i[1:thin:end];
                color = colors[i])
            biomass_cumsum += biomass_i
        end
    else
        band!(ax, t[1:thin:end], biomass_lower[1:thin:end],
            biomass_upper[1:thin:end]; color = (:black, 0.1))
        band!(ax, t[1:thin:end], biomass_lower5[1:thin:end],
            biomass_upper5[1:thin:end]; color = (:black, 0.1))
        lines!(ax, t[1:thin:end], biomass_median[1:thin:end]; color = :orange)
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

function trait_time_plot(;
        sol, patch = 1, valid_data, plot_obj, ax_num = 2)
    ax = plot_obj.axes[ax_num]
    empty!(ax)
    t = sol.numeric_date

    trait = plot_obj.obs.menu_color.selection.val
    name_index = getindex.([plot_obj.obs.menu_color.options.val...], 2) .== trait
    trait_name = first.([plot_obj.obs.menu_color.options.val...])[name_index][1]

    trait_vals = ustrip.(sol.traits[trait])

    biomass_vals = ustrip.(sol.o.biomass[:, patch, :])
    total_biomass = sum(biomass_vals, dims = 2)
    relative_biomass = biomass_vals ./ total_biomass

    ##  mean
    weighted_trait = trait_vals .* relative_biomass'
    cwm_trait = vec(sum(weighted_trait; dims = 1))

    # biomass_median = median.(biomass_dist)
    # biomass_lower = quantile.(biomass_dist, 0.025)
    # biomass_upper = quantile.(biomass_dist, 0.975)
    # biomass_lower5 = quantile.(biomass_dist, 0.25)
    # biomass_upper5 = quantile.(biomass_dist, 0.75)

    ax.xlabel = "Time [years]"

    show_traitvar = plot_obj.obs.toggle_traitvar.active.val
    if show_traitvar
        ## variance
        trait_diff = (trait_vals' .- cwm_trait) .^ 2
        weighted_trait_diff = trait_diff .* relative_biomass
        cwv_trait = vec(sum(weighted_trait_diff; dims = 2))

        cwv_trait_dist = truncated.(Laplace.(cwv_trait, sol.p[Symbol("b_var_$trait")]);
            lower = 0)
        median_trait = median.(cwv_trait_dist)
        lower_trait = quantile.(cwv_trait_dist, 0.025)
        upper_trait = quantile.(cwv_trait_dist, 0.975)
        lower5_trait = quantile.(cwv_trait_dist, 0.25)
        upper5_trait = quantile.(cwv_trait_dist, 0.75)

        band!(ax, t, lower_trait, upper_trait; color = (:black, 0.1))
        band!(ax, t, lower5_trait, upper5_trait; color = (:black, 0.1))
        lines!(ax, t, cwv_trait, color = :red)
        ax.ylabel = "Var: $trait_name"
    else
        ### trait values of all species
        for i in 1:(sol.simp.nspecies)
            trait_i = trait_vals[i]
            lines!(ax, [t[1], t[end]], [trait_i, trait_i], color = (:grey, 0.2))
        end

        cwm_trait_dist = truncated.(Laplace.(cwm_trait, sol.p[Symbol("b_$trait")]);
            lower = 0)
        median_trait = median.(cwm_trait_dist)
        lower_trait = quantile.(cwm_trait_dist, 0.025)
        upper_trait = quantile.(cwm_trait_dist, 0.975)
        lower5_trait = quantile.(cwm_trait_dist, 0.25)
        upper5_trait = quantile.(cwm_trait_dist, 0.75)

        band!(ax, t, lower_trait, upper_trait; color = (:black, 0.1))
        band!(ax, t, lower5_trait, upper5_trait; color = (:black, 0.1))
        lines!(ax, t, median_trait, color = :blue)
        ax.ylabel = "Mean: $trait_name"
    end

    if !isnothing(valid_data)
        num_t = sol.numeric_date[LookupArrays.index(valid_data.traits, :time)]
        y = nothing

        if !show_traitvar
            y = vec(valid_data.traits[type = At(:cwm), trait = At(trait)])
        else
            y = vec(valid_data.traits[type = At(:cwv), trait = At(trait)])
        end

        scatter!(ax, num_t, y, color = :black, markersize = 8)
    end
end

function trait_mean_biomass(;
        sol,
        markersize = 15,
        patch = 1,
        t, plot_obj, ax_num = 3)
    ax = plot_obj.axes[ax_num]
    empty!(ax)

    trait = plot_obj.obs.menu_color.selection.val
    name_index = getindex.([plot_obj.obs.menu_color.options.val...], 2) .== trait
    trait_name = first.([plot_obj.obs.menu_color.options.val...])[name_index][1]
    color = ustrip.(sol.traits[trait])
    colormap = :viridis
    colorrange = (minimum(color), maximum(color) + 0.0001)

    print_date = Dates.format(sol.date[t], "dd.mm.yyyy")

    ax.ylabel = "Biomass at $(print_date) [kg ha⁻¹]"
    ax.xlabel = trait_name

    scatter!(ax,
        ustrip.(sol.traits[trait]),
        ustrip.(sol.o.biomass[t, patch, :]);
        color, colormap, colorrange,
        markersize)

    return nothing
end

function soilwater_plot(; sol, valid_data, predictive_data, plot_obj, ax_num = 4)
    ax = plot_obj.axes[ax_num]
    empty!(ax)

    thin = 7
    t = sol.numeric_date[1:thin:end]

    water_μ = mean(ustrip.(sol.o.water); dims = 2)[1:thin:end]
    water_dist = truncated.(Laplace.(water_μ, sol.p.b_soilmoisture); lower = 0)
    water_median = median.(water_dist)
    water_lower = quantile.(water_dist, 0.025)
    water_upper = quantile.(water_dist, 0.975)
    water_lower5 = quantile.(water_dist, 0.25)
    water_upper5 = quantile.(water_dist, 0.75)

    band!(ax, t, water_lower5, water_upper5; color = (:black, 0.1))
    band!(ax, t, water_lower, water_upper; color = (:black, 0.1))
    lines!(ax, t, water_median; color = :turquoise3, markersize = 6, linewidth = 2)

    PWP = mean(ustrip(sol.patch.PWP))
    WHC = mean(ustrip(sol.patch.WHC))
    lines!(ax, [sol.numeric_date[1], sol.numeric_date[end]], [PWP, PWP];
        color = :blue)
    lines!(ax, [sol.numeric_date[1], sol.numeric_date[end]], [WHC, WHC];
        color = :blue)
    ax.ylabel = "Soil water [mm]"
    ax.xlabel = "Time [years]"
    ylims!(ax, 0.0, nothing)

    if !isnothing(valid_data)
        moist = @. sol.site.rootdepth * (sol.p.moistureconv_alpha +
                    sol.p.moistureconv_beta * valid_data.soilmoisture)

        num_t = sol.numeric_date[LookupArrays.index(valid_data.soilmoisture, :time)]

        scatter!(ax, num_t[1:thin:end], moist[1:thin:end]; color = :black, markersize = 4)
    end

    if !isnothing(predictive_data)
        scatter!(ax, sol.numeric_date[predictive_data.t_soilwater][1:thin:end],
            predictive_data.soilwater[1:thin:end]; color = :red, markersize = 4)
    end
end

function patch_plot(; sol, plot_obj, t, ax_num = 5)
    ax = plot_obj.axes[ax_num]
    empty!(ax)

    xdim, ydim = sol.simp.patch_xdim, sol.simp.patch_ydim
    xs = [[x for x in 1:xdim, y in 1:ydim]...]
    ys = [[y for x in 1:xdim, y in 1:ydim]...]

    patch_biomass = vec(sum(ustrip.(sol.o.biomass[t, :, :]); dims = 2))
    # colorrange = quantile(mean(ustrip.(sol.biomass); dims=3), [0.0, 1.0])
    colorrange = quantile(patch_biomass, [0.0, 1.0])

    scatter!(ax, xs, ys;
        marker = :rect,
        markersize = 1.5,
        markerspace = :data,
        color = patch_biomass,
        colorrange,
        colormap = :viridis)

    # text!(ax, xs, ys;
    #     text = string.(1:sol.p.npatches),
    #     align = (:center, :center))

    ax.aspect = DataAspect()
    ax.yticks = 1:ydim
    ax.xticks = 1:xdim
    ax.limits = (0, xdim + 1, 0, ydim + 1)
end

function abiotic_plot(; sol, plot_obj, ax_num = 6)
    thin = 7

    ax = plot_obj.axes[ax_num]
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

# function growth_rates(ax; patch = 1, sol, color, colormap, colorrange, plotID)
#     biomass = sol.biomass
#     bio1 = biomass[1:(end - 1), patch, :]
#     bio2 = biomass[2:end, patch, :]
#     growth = ustrip.((bio2 .- bio1) ./ ((bio2 .+ bio1) ./ 2))

#     ax.xlabel = "Time [years]"
#     ax.ylabel = "Net growth [kg/kg ha⁻¹ d⁻¹]"

#     # skip = length(sol.t) > 1000 ? 10 : 1
#     skip = 1
#     t = sol.numeric_date[2:end] .+ (0.5 / 365)

#     for i in 1:(sol.p.nspecies)
#         lines!(ax, t, growth[1:skip:end, i];
#             color = color[i],
#             colormap = (colormap, 0.8), colorrange)
#     end

#     # ylims!(ax, -0.3*maximum(growth), nothing)

#     return nothing
# end
