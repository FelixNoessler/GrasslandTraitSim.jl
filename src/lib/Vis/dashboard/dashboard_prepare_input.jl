function prepare_input(; plot_obj, sim, valid, posterior, biomass_stats = nothing)
    # ------------- whether parts of the simulation are included
    included = NamedTuple(
        [first(s) => last(s).active.val for s in plot_obj.obs.toggles_included])
    plotID = plot_obj.obs.menu_plotID.selection.val
    input_obj = valid.validation_input(; plotID, nspecies = 43, included, biomass_stats)

    # ------------- parameter values
    p = nothing
    samplingtype = plot_obj.obs.menu_samplingtype.selection.val

    if samplingtype == :prior
        inference_obj = sim.calibrated_parameter(; input_obj)
        θ = valid.sample_prior(; inference_obj)
        p = sim.Parameter()
        for k in keys(θ)
            p[k] = θ[k] * unit(p[k])
        end

    elseif samplingtype == :fixed
        p = sim.Parameter()
        for (i, k) in enumerate(keys(plot_obj.obs.parameter_keys))
            p[k] = parse(Float64, plot_obj.obs.tb_p[i].stored_string[]) * unit(p[k])
        end
    else
        samplingtype == :posterior
        if isnothing(posterior)
            error("No posterior draws given - cannot sample from posterior!")
        else
            parameter_vals = valid.sample_posterior(posterior)
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


function load_trait_data(valid)
    trait_df = valid.data.input.traits
    return (;
        amc = trait_df.amc,
        sla = trait_df.sla * u"m^2/g",
        height = trait_df.height * u"m",
        rsa_above = trait_df.rsa_above * u"m^2/g",
        ampm = trait_df.ampm,
        lmpm = trait_df.lmpm,
        lncm = trait_df.lncm * u"mg/g")
end
