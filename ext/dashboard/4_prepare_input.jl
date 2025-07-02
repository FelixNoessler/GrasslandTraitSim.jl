function prepare_input(; plot_obj)
    # ------------- whether parts of the simulation are included
    included = NamedTuple(
        [first(s) => last(s).active.val for s in plot_obj.obs.toggles_included])
    plotID = plot_obj.obs.menu_plotID.selection.val
    input_obj = gts.create_input(plotID; included)

    # ------------- parameter values
    p = gts.SimulationParameter()
    for (i, k) in enumerate(plot_obj.obs.parameter_keys)
        p[k] = parse(Float64, plot_obj.obs.tb_p[i].stored_string[]) * unit(p[k])
    end

    return p, input_obj
end
