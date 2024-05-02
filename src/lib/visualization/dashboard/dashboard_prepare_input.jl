function prepare_input(; plot_obj, posterior, biomass_stats = nothing, time_step_days)
    # ------------- whether parts of the simulation are included
    included = NamedTuple(
        [first(s) => last(s).active.val for s in plot_obj.obs.toggles_included])
    plotID = plot_obj.obs.menu_plotID.selection.val
    input_obj = validation_input(; plotID, nspecies = 43, included, biomass_stats, time_step_days)

    # ------------- parameter values
    p = nothing
    samplingtype = plot_obj.obs.menu_samplingtype.selection.val

    if samplingtype == :prior
        inference_obj = calibrated_parameter(; input_obj)
        θ = sample_prior(; inference_obj)
        p = SimulationParameter()
        for k in keys(θ)
            p[k] = θ[k] * unit(p[k])
        end

    elseif samplingtype == :fixed
        p = SimulationParameter()
        for (i, k) in enumerate(keys(plot_obj.obs.parameter_keys))
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
        for (i, k) in enumerate(keys(plot_obj.obs.parameter_keys))
            val = round(ustrip(p[k]); digits = 5)
            Makie.set!(plot_obj.obs.tb_p[i], string(val))
        end
    end

    return p, input_obj
end
