function dashboard(; posterior = nothing, variable_p = (;),
                   θ = nothing, path = nothing)
    set_theme!(
        Theme(
            colgap = 5,
            rowgap = 5,
            Label = (; fontsize = 12)),
            Axis = (xgridvisible = false, ygridvisible = false,
                    topspinevisible = false, rightspinevisible = false),
            GridLayout = (; halign = :left, valign = :top),
            GLMakie = (title = "Grassland Simulation",
                       focus_on_show = true,
                       fullscreen = true))

    plot_obj = dashboard_layout(; variable_p)

    still_running = false
    sol = nothing
    mean_input_date = nothing
    valid_data = nothing
    biomass_stats = nothing
    trait_input = input_traits()

    on(plot_obj.obs.run_button.clicks) do n
        if !still_running
            still_running = true

            biomass_stats = plot_obj.obs.menu_biomassvalid.selection.val

            p, input_obj = prepare_input(; plot_obj, posterior, biomass_stats)
            sol = solve_prob(; input_obj, p, trait_input)

            mean_input_date = input_obj.simp.mean_input_date
            valid_data = get_valid_data(; plot_obj, biomass_stats, mean_input_date)

            show_validdata = plot_obj.obs.toggle_validdata.active.val
            if show_validdata
                update_plots(; sol, plot_obj, valid_data)
            else
                update_plots(; sol, plot_obj, valid_data = nothing)
            end

            still_running = false
        end
    end

    on(plot_obj.obs.menu_plotID.selection) do n
        plot_obj.obs.run_button.clicks[] = 1
    end

    on(plot_obj.obs.menu_timestep.selection) do n
        plot_obj.obs.run_button.clicks[] = 1
    end

    on(plot_obj.obs.preset_button.clicks) do n
        @info "Parameter reset"
        p = SimulationParameter()
        for (i, k) in enumerate(plot_obj.obs.parameter_keys)
            Makie.set!(plot_obj.obs.tb_p[i], string(ustrip(p[k])))
        end
    end

    plot_obj.obs.run_button.clicks[] = 1

    on(plot_obj.obs.toggle_grazmow.active) do n
        update_plots(; sol, plot_obj, valid_data)
    end

    on(plot_obj.obs.toggle_standingbiomass.active) do n
        update_plots(; sol, plot_obj, valid_data)
    end

    on(plot_obj.obs.menu_abiotic.selection) do n
        update_plots(; sol, plot_obj, valid_data)
    end

    on(plot_obj.obs.menu_traits.selection) do _
        update_plots(; sol, plot_obj, valid_data)
    end

    on(plot_obj.obs.toggle_validdata.active) do n
        valid_data = nothing
        if n
            valid_data = get_valid_data(; plot_obj, biomass_stats, mean_input_date)
        end
        update_plots(; sol, plot_obj, valid_data)
    end

    on(plot_obj.obs.menu_biomassvalid.selection) do new_stat
        biomass_stats = new_stat
        if plot_obj.obs.toggle_validdata.active.val
            valid_data = get_valid_data(; plot_obj, biomass_stats, mean_input_date)
            update_plots(; sol, plot_obj, valid_data)
        end
    end

    on(plot_obj.obs.button_panelA.clicks) do _
        plot_obj.obs.which_pane[] = 1
        clear_panel!(plot_obj.obs.plots_layout)
        @reset plot_obj.axes = create_axes_paneA(plot_obj.obs.plots_layout)
        update_plots(; sol, plot_obj, valid_data)
    end

    on(plot_obj.obs.button_panelB.clicks) do _
        plot_obj.obs.which_pane[] = 2
        clear_panel!(plot_obj.obs.plots_layout)
        @reset plot_obj.axes = create_axes_paneB(plot_obj.obs.plots_layout)
        update_plots(; sol, plot_obj, valid_data)
    end

    on(plot_obj.obs.button_panelC.clicks) do _
        plot_obj.obs.which_pane[] = 3
        clear_panel!(plot_obj.obs.plots_layout)
        @reset plot_obj.axes = create_axes_paneC(plot_obj.obs.plots_layout)
        update_plots(; sol, plot_obj, valid_data)
    end

    on(plot_obj.obs.button_panelD.clicks) do _
        plot_obj.obs.which_pane[] = 4
        clear_panel!(plot_obj.obs.plots_layout)
        @reset plot_obj.axes = create_axes_paneD(plot_obj.obs.plots_layout)
        update_plots(; sol, plot_obj, valid_data)
    end

    on(plot_obj.obs.button_panelE.clicks) do _
        plot_obj.obs.which_pane[] = 5
        clear_panel!(plot_obj.obs.plots_layout)
        @reset plot_obj.axes = create_axes_paneE(plot_obj.obs.plots_layout)
        update_plots(; sol, plot_obj, valid_data)
    end


    if isnothing(path)
        display(plot_obj.fig)
    else
        save(path, plot_obj.fig)
    end

    return nothing
end

function get_valid_data(; plot_obj, biomass_stats = nothing, mean_input_date)
    plotID = plot_obj.obs.menu_plotID.selection.val

    data = get_validation_data(; plotID, biomass_stats, mean_input_date)

    return data
end


function update_plots(; plot_obj, kwargs...)
    pane = plot_obj.obs.which_pane.val

    if pane == 1
        update_plots_paneA(; plot_obj, kwargs...)
    elseif pane == 2
        update_plots_paneB(; plot_obj, kwargs...)
    elseif pane == 3
        update_plots_paneC(; plot_obj, kwargs...)
    elseif pane == 4
        update_plots_paneD(; plot_obj, kwargs...)
    elseif pane == 5
        update_plots_paneE(; plot_obj, kwargs...)
    end
end
