function dashboard(; sim::Module, valid::Module, posterior = nothing, variable_p = (;))
    # Makie.inline!(true)
    set_theme!(
        Theme(
            Label = (; fontsize = 12)),
            Axis = (xgridvisible = false, ygridvisible = false,
                    topspinevisible = false, rightspinevisible = false),
            GLMakie = (title = "Grassland Simulation",
                       focus_on_show = true))

    plot_obj = dashboard_layout(; sim, valid, variable_p)

    still_running = false
    sol = nothing
    valid_data = nothing
    trait_input = load_trait_data(valid)

    on(plot_obj.obs.run_button.clicks) do n
        if !still_running
            still_running = true

            p, input_obj = prepare_input(; plot_obj, sim, valid, posterior)
            sol = sim.solve_prob(; input_obj, p, trait_input)
            valid_data = get_valid_data(; plot_obj, valid)

            show_validdata = plot_obj.obs.toggle_validdata.active.val
            if show_validdata
                update_plots(; sol, plot_obj, valid_data)
            else
                update_plots(; sol, plot_obj)
            end

            ll_obj = valid.loglikelihood_model(sim;
                θ = p,
                plotID = plot_obj.obs.menu_plotID.selection.val,
                data = valid_data,
                sol = sol,
                return_seperate = true)

            plot_obj.obs.lls.biomass[] = ll_obj.biomass
            plot_obj.obs.lls.traits[] = ll_obj.trait

            still_running = false
        end
    end

    on(plot_obj.obs.menu_plotID.selection) do n
        plot_obj.obs.run_button.clicks[] = 1
    end

    on(plot_obj.obs.preset_button.clicks) do n
        @info "Parameter reset"
        included = NamedTuple(
            [first(s) => last(s).active.val for s in plot_obj.obs.toggles_included])
        plotID = plot_obj.obs.menu_plotID.selection.val
        input_obj = valid.validation_input(;
            plotID,
            nspecies = 43,
            included)
        p = sim.parameter(; input_obj)
        for p_k in keys(p)
            f = plot_obj.obs.parameter_keys .== p_k
            s = plot_obj.obs.sliders_param.sliders[findfirst(f)]
            set_close_to!(s, ustrip(p[p_k]))
        end
    end

    plot_obj.obs.run_button.clicks[] = 1

    on(plot_obj.obs.toggle_grazmow.active) do n
        band_patch(; plot_obj, sol, valid_data)
    end

    on(plot_obj.obs.menu_abiotic.selection) do n
        abiotic_plot(; sol, plot_obj)
    end

    on(plot_obj.obs.toggle_validdata.active) do n
        valid_data = nothing
        if n
            valid_data = get_valid_data(;
                plot_obj, valid)
        end
        band_patch(; plot_obj, sol, valid_data)
        [trait_time_plot(; plot_obj, sol, valid_data, trait = t) for t in
            [:amc, :sla, :height, :rsa_above, :lncm]]
    end

    display(plot_obj.fig)
    return nothing
end

function get_valid_data(; plot_obj, valid)
    plotID = plot_obj.obs.menu_plotID.selection.val

    data = valid.get_validation_data(; plotID)

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
        [:amc, :sla, :height, :rsa_above, :lncm]]

    return nothing
end
