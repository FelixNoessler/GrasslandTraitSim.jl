function prepare_input(; plot_obj, posterior, biomass_stats = nothing)
    # ------------- whether parts of the simulation are included
    included = NamedTuple(
        [first(s) => last(s).active.val for s in plot_obj.obs.toggles_included])
    plotID = plot_obj.obs.menu_plotID.selection.val
    time_step_days = plot_obj.obs.menu_timestep.selection.val

    input_obj = if time_step_days == 14
        path = assetpath("data/input/inputs_14_days.jld2")
        gts.load_input(path; included,
                   plotIDs = [plotID])[Symbol(plotID)]
    else
        gts.validation_input(; plotID, nspecies = 71, included, biomass_stats,
                                    time_step_days)
    end
    # ------------- parameter values
    p = nothing
    samplingtype = plot_obj.obs.menu_samplingtype.selection.val

    if samplingtype == :prior
        priors = get_priors(plot_obj.obs.prior_obj)
        θ = sample_prior(priors)
        p = add_to_p(θ)

    elseif samplingtype == :fixed
        p = gts.SimulationParameter()
        for (i, k) in enumerate(plot_obj.obs.parameter_keys)
            p[k] = parse(Float64, plot_obj.obs.tb_p[i].stored_string[]) * unit(p[k])
        end
    else
        samplingtype == :posterior
        if isnothing(posterior)
            error("No posterior draws given - cannot sample from posterior!")
        else
            parameter_vals = sample_posterior(posterior)
        end
    end

    if samplingtype != :fixed
        for (i, k) in enumerate(plot_obj.obs.parameter_keys)
            val = round(ustrip(p[k]); digits = 5)
            Makie.set!(plot_obj.obs.tb_p[i], string(val))
        end
    end

    return p, input_obj
end
