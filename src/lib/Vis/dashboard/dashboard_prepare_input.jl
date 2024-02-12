function prepare_input(; plot_obj, sim, valid, posterior)


    # ------------- whether parts of the simulation are included
    included = NamedTuple(
        [first(s) => last(s).active.val for s in plot_obj.obs.toggles_included])
    plotID = plot_obj.obs.menu_plotID.selection.val
    input_obj = valid.validation_input(;
        plotID,
        nspecies = 43,
        included)

    # ------------- parameter values
    p = nothing
    samplingtype = plot_obj.obs.menu_samplingtype.selection.val

    if samplingtype == :prior
        inference_obj = sim.calibrated_parameter(; input_obj)
        θ = valid.sample_prior(; inference_obj)
        θ = sim.add_units(θ; inference_obj)
        p = sim.parameter(; input_obj, variable_p = θ)

    elseif samplingtype == :fixed
        parameter_vals = [s.value.val for s in plot_obj.obs.sliders_param.sliders]
        p_fixed = sim.parameter(; input_obj)
        unit_vec = unit.(collect(p_fixed))
        value_vec = Float64[]

        for p_k in keys(p_fixed)
            f = plot_obj.obs.parameter_keys .== p_k
            push!(value_vec, parameter_vals[findfirst(f)])
        end
        plot_obj.obs.parameter_keys
        p = (; zip(keys(p_fixed), value_vec .* unit_vec)...)
    else
        samplingtype == :posterior
        if isnothing(posterior)
            error("No posterior draws given - cannot sample from posterior!")
        else
            parameter_vals = valid.sample_posterior(posterior)
        end
    end

    if samplingtype != :fixed
        for p_k in keys(p)
            f = plot_obj.obs.parameter_keys .== p_k
            s = plot_obj.obs.sliders_param.sliders[findfirst(f)]
            set_close_to!(s, ustrip(p[p_k]))
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
