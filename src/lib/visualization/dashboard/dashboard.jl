function dashboard(; posterior = nothing, variable_p = (;),
                   biomass_stats = nothing)
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
    trait_input = input_traits()

    on(plot_obj.obs.run_button.clicks) do n
        if !still_running
            still_running = true

            p, input_obj = prepare_input(; plot_obj, posterior, biomass_stats)
            sol = solve_prob(; input_obj, p, trait_input)

            mean_input_date = input_obj.simp.mean_input_date
            valid_data = get_valid_data(; plot_obj, biomass_stats, mean_input_date)

            show_validdata = plot_obj.obs.toggle_validdata.active.val
            if show_validdata
                update_plots(; sol, plot_obj, valid_data)
            else
                update_plots(; sol, plot_obj)
            end

            ll_obj = loglikelihood_model(;
                p,
                plotID = plot_obj.obs.menu_plotID.selection.val,
                data = valid_data,
                sol = sol,
                return_seperate = true)

            plot_obj.obs.lls.biomass[] = ll_obj.biomass
            plot_obj.obs.lls.traits[] = ll_obj.trait

            calculate_gradient = plot_obj.obs.gradient_toggle.active.val
            if calculate_gradient
                @info "Calculating gradient"
                plotID = plot_obj.obs.menu_plotID.selection.val

                g = gradient_evaluation(; plotID, input_obj, valid_data,
                                        p, trait_input)

                p_keys = keys(p)
                for i in eachindex(g)
                    f = p_keys[i] .== plot_obj.obs.parameter_keys
                    plot_obj.obs.gradient_values[findfirst(f)][] = 2.0 #round(g[i]; digits = 2)
                end
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
        for (i, k) in enumerate(keys(plot_obj.obs.parameter_keys))
            Makie.set!(plot_obj.obs.tb_p[i], string(ustrip(p[k])))
        end
    end

    plot_obj.obs.run_button.clicks[] = 1

    on(plot_obj.obs.toggle_grazmow.active) do n
        band_patch(; plot_obj, sol, valid_data)
    end

    on(plot_obj.obs.toggle_standingbiomass.active) do n
        band_patch(; plot_obj, sol, valid_data)
    end

    on(plot_obj.obs.menu_abiotic.selection) do n
        abiotic_plot(; sol, plot_obj)
    end

    on(plot_obj.obs.toggle_validdata.active) do n
        valid_data = nothing
        if n
            valid_data = get_valid_data(; plot_obj, biomass_stats, mean_input_date)
        end
        band_patch(; plot_obj, sol, valid_data)
        [trait_time_plot(; plot_obj, sol, valid_data, trait = t) for t in
            [:amc, :sla, :height, :srsa, :lnc]]
    end

    display(plot_obj.fig)
    return nothing
end

function get_valid_data(; plot_obj, biomass_stats = nothing, mean_input_date)
    plotID = plot_obj.obs.menu_plotID.selection.val

    data = get_validation_data(; plotID, biomass_stats, mean_input_date)

    return data
end

function update_plots(; sol, plot_obj, valid_data = nothing)
    ########### Biomass
    band_patch(;
        plot_obj,
        sol,
        valid_data)

    ########### Soil water
    soilwater_plot(; sol, plot_obj)

    ########### Abiotic plot
    abiotic_plot(; sol, plot_obj)

    ########### Trait changes over time
    [trait_time_plot(; plot_obj, sol, valid_data, trait = t) for t in
        [:amc, :sla, :height, :srsa, :lnc]]

    return nothing
end
