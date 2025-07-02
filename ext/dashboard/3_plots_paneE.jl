function create_axes_paneE(layout)
    axes = Dict()
    axes[:abiotic] = Axis(layout[1, 1]; alignmode = Inside(),
                          xlabel = "Time [years]",
                          xticks = 2006:2022)
    return axes
end

function update_plots_paneE(; kwargs...)
    abiotic_plot(; kwargs...)
end

function abiotic_plot(; sol, plot_obj, kwargs...)
    thin = 1
    ax = clear_plotobj_axes(plot_obj, :abiotic)

    abiotic_colors = [:blue, :brown, :red, :red, :orange]
    abiotic = plot_obj.obs.menu_abiotic.selection.val
    name_index = getindex.([plot_obj.obs.menu_abiotic.options.val...], 2) .== abiotic
    abiotic_name = first.([plot_obj.obs.menu_abiotic.options.val...])[name_index][1]
    abiotic_color = abiotic_colors[name_index][1]

    scatterlines!(ax, sol.simp.mean_input_date_num[1:thin:end],
        ustrip.(vec(sol.input[abiotic]))[1:thin:end];
        color = abiotic_color, markersize = 4, linewidth = 0.1)
    ax.ylabel = abiotic_name
end
