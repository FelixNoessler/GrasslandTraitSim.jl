function prepare_input(; plot_obj, valid, posterior)
    # ------------- parameter values
    parameter_vals = nothing
    samplingtype = plot_obj.obs.menu_samplingtype.selection.val
    if samplingtype == :prior
        parameter_vals = valid.sample_prior()
    elseif samplingtype == :fixed
        parameter_vals = [s.value.val for s in plot_obj.obs.sliders_param.sliders]
    else
        samplingtype == :posterior
        if isnothing(posterior)
            error("No posterior draws given - cannot sample from posterior!")
        else
            parameter_vals = valid.sample_posterior(posterior)
        end
    end

    if samplingtype != :fixed
        for i in eachindex(parameter_vals)
            s = plot_obj.obs.sliders_param.sliders[i]
            set_close_to!(s, parameter_vals[i])
        end
    end

    parameter_names = valid.model_parameters().names
    inf_p = (; zip(Symbol.(parameter_names), parameter_vals)...)

    # ------------- whether parts of the simulation are included
    included = NamedTuple(
        [first(s) => last(s).active.val for s in plot_obj.obs.toggles_included])

    trait_input = load_trait_data(valid)

    plotID = plot_obj.obs.menu_plotID.selection.val
    input_obj = valid.validation_input(;
        plotID,
        nspecies = length(trait_input.sla),
        included)

    return inf_p, input_obj, trait_input
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
