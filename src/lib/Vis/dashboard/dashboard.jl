function dashboard(; sim::Module, valid::Module, posterior = nothing)
    Makie.inline!(false)

    plot_obj = dashboard_layout(; valid)

    still_running = false
    sol = nothing
    valid_data = nothing
    predictive_data = nothing
    updating_slider = false

    on(plot_obj.obs.run_button.clicks) do n
        if !still_running
            still_running = true

            inf_p, input_obj = prepare_input(; plot_obj, valid, posterior)
            sol = sim.solve_prob(; input_obj, inf_p)
            valid_data = get_valid_data(;
                plot_obj, valid)

            show_predictive = plot_obj.obs.toggle_predcheck.active.val
            predictive_data = nothing
            if show_predictive
                predictive_data = valid.predictive_check(; sol, valid_data)
            end

            show_validdata = plot_obj.obs.toggle_validdata.active.val
            if show_validdata
                update_plots(; sol, plot_obj, valid_data, predictive_data)
            else
                update_plots(; sol, plot_obj, predictive_data)
            end

            updating_slider = true
            plot_obj.obs.slider_time.range = sol.ts
            set_close_to!(plot_obj.obs.slider_time, sol.ts[end])
            updating_slider = false

            ll_obj = valid.loglikelihood_model(sim;
                inf_p,
                plotID = plot_obj.obs.menu_plotID.selection.val,
                data = valid_data,
                sol = sol,
                return_seperate = true)

            plot_obj.obs.lls.biomass[] = ll_obj.biomass
            plot_obj.obs.lls.traits[] = ll_obj.trait
            plot_obj.obs.lls.traits_var[] = ll_obj.trait_var
            plot_obj.obs.lls.soilmoisture[] = ll_obj.soilmoisture

            still_running = false
        end
    end

    on(plot_obj.obs.menu_plotID.selection) do n
        plot_obj.obs.run_button.clicks[] = 1
    end

    plot_obj.obs.run_button.clicks[] = 1

    on(plot_obj.obs.toggle_grazmow.active) do n
        band_patch(; plot_obj, sol, valid_data, predictive_data)
    end

    on(plot_obj.obs.toggle_bands.active) do n
        band_patch(; plot_obj, sol, valid_data, predictive_data)
    end

    on(plot_obj.obs.menu_color.selection) do n
        band_patch(; plot_obj, sol, valid_data, predictive_data)
        trait_time_plot(; plot_obj, sol, valid_data)
        trait_mean_biomass(; sol, plot_obj, t = sol.ts[end])
    end

    on(plot_obj.obs.menu_abiotic.selection) do n
        abiotic_plot(; sol, plot_obj)
    end

    on(plot_obj.obs.toggle_traitvar.active) do n
        trait_time_plot(; plot_obj, sol, valid_data)
    end

    on(plot_obj.obs.toggle_validdata.active) do n
        valid_data = nothing
        if n
            valid_data = get_valid_data(;
                plot_obj, valid)
        end
        band_patch(; plot_obj, sol, valid_data, predictive_data)
        trait_time_plot(; plot_obj, sol, valid_data)
        soilwater_plot(; sol, valid_data, plot_obj, predictive_data)
    end

    time_slider_changed = Dates.now()
    on(plot_obj.obs.slider_time.value) do t
        ms_since_change = Dates.value(Dates.now() - time_slider_changed)
        if !updating_slider && ms_since_change > 100
            updating_slider = true
            time_slider_changed = Dates.now()
            t = plot_obj.obs.slider_time.value.val
            trait_mean_biomass(; sol, plot_obj, t)
            patch_plot(; sol, plot_obj, t)
            updating_slider = false
        end
    end

    return nothing
end

function get_valid_data(; plot_obj, valid)
    plotID = plot_obj.obs.menu_plotID.selection.val

    data = valid.get_validation_data(; plotID)

    return data
end

function update_plots(; sol, plot_obj, valid_data = nothing, predictive_data)

    ########### Biomass
    band_patch(;
        plot_obj,
        sol,
        valid_data,
        predictive_data)

    ########### Trait changes over time
    trait_time_plot(;
        plot_obj, sol, valid_data)

    ########### biomass vs traits
    trait_mean_biomass(;
        sol,
        plot_obj,
        t = sol.ts[end])

    ########### Soil water
    soilwater_plot(; sol, valid_data, predictive_data, plot_obj)

    ########### Patches
    patch_plot(;
        sol, plot_obj,
        t = sol.ts[end])

    ########### Abiotic plot
    abiotic_plot(; sol, plot_obj)

    return nothing
end
