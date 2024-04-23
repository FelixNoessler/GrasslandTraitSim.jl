function dashboard_layout(; variable_p)
    fig = Figure(; size = (1800, 800))

    ##############################################################################
    # Define grid layouts
    ##############################################################################
    top_menu = GridLayout(fig[1, 1])
    sim_layout = GridLayout(top_menu[1, 2]; tellwidth = false)
    validation_layout = GridLayout(top_menu[1, 3]; valign = :top)
    plottingmenu_layout = GridLayout(top_menu[1, 4]; valign = :top)
    graz_mow_layout = GridLayout(plottingmenu_layout[3, 1]; halign = :left)

    plots_layout = GridLayout(fig[2, 1])
    topplots_layout = GridLayout(plots_layout[1, 1])
    bottomplots_layout = GridLayout(plots_layout[2, 1])

    right_layout = GridLayout(fig[1:2, 2])
    righttop_layout = GridLayout(right_layout[1, 1]; halign = :left)
    param_layout = GridLayout(right_layout[2, 1]; tellheight = false, valign = :top)

    ##############################################################################
    # Draw boxes
    ##############################################################################
    # Box(top_menu[1, 1], cornerradius = 10, color = (:tomato, 0.2), strokecolor = :transparent)
    # Box(top_menu[1, 2], cornerradius = 10, color = (:tomato, 0.2), strokecolor = :transparent)
    # Box(top_menu[1, 3], cornerradius = 10, color = (:tomato, 0.2), strokecolor = :transparent)
    # Box(top_menu[1, 4], cornerradius = 10, color = (:tomato, 0.2), strokecolor = :transparent)
    # Box(plots_layout[1, 1], cornerradius = 10, color = (:orange, 0.2), strokecolor = :transparent)
    # Box(plots_layout[2, 1], cornerradius = 10, color = (:orange, 0.2), strokecolor = :transparent)
    # Box(right_layout[1, 1], cornerradius = 10, color = (:teal, 0.2), strokecolor = :transparent)
    # Box(right_layout[2, 1], cornerradius = 2, color = (:teal, 0.2), strokecolor = :transparent)

    ##############################################################################
    # Run button
    ##############################################################################
    run_button = Button(top_menu[1, 1]; label = "run")

    ##############################################################################
    # Left box: turn off parts of the model
    ##############################################################################
    Label(sim_layout[1, 1:2], "Simulation settings";
        halign = :left, font = :bold, fontsize = 16)
    input_obj = validation_input(; plotID = "HEG01", nspecies = 1)
    included_symbols = keys(input_obj.simp.included)
    labels = String.(included_symbols)
    nstart2 = length(labels) - length(labels) ÷ 2 + 1
    nend1 = nstart2 - 1
    [Label(sim_layout[i+1, 1], labels[i]; halign = :right, fontsize = 10) for i in 1:nend1]
    [Label(sim_layout[i+2-nstart2, 3], labels[i]; halign = :right)
        for i in nstart2:length(labels)]
    left_toggles = [Toggle(sim_layout[i+1, 2], active = true, height = 10) for i in 1:nend1]
    right_toggle = [Toggle(sim_layout[i+2-nstart2, 4],
               active = true, height = 10) for i in nstart2:length(labels)]
    toggles_included_prep = vcat(left_toggles, right_toggle)
    toggles_included = Dict(zip(included_symbols, toggles_included_prep))

    ##############################################################################
    # Middle box: validation settings
    ##############################################################################
    Label(validation_layout[1, 1], "Validation";
        tellwidth = true, halign = :left,
        font = :bold, fontsize = 16)
    Label(validation_layout[2, 1], "validation data?";
        halign = :left, fontsize = 16)
    toggle_validdata = Toggle(validation_layout[2, 2],
        active = true,
        tellwidth = false,
        halign = :left)
    Label(validation_layout[3, 1], "standing biomass?";
        halign = :left, fontsize = 16)
    toggle_standingbiomass = Toggle(validation_layout[3, 2],
        active = true,
        tellwidth = false,
        halign = :left)
    Label(validation_layout[4, 1], "Parameter:";
        tellwidth = true, halign = :left, fontsize = 16)
    menu_samplingtype = Menu(validation_layout[5, 1];
        options = zip(["fixed (see right)", "sample prior", "sample posterior"],
            [:fixed, :prior, :posterior]),
        halign = :left)
    Label(validation_layout[4, 2], "PlotID:";
        tellwidth = true, halign = :left, fontsize = 16)
    menu_plotID = Menu(validation_layout[5, 2];
        options = ["$(explo)$(lpad(i, 2, "0"))"  for explo in ["HEG", "SEG", "AEG"]
                   for i in 1:50],
        width = 100,
        halign = :left)

    ##############################################################################
    # Right box: abiotic and grazing/mowing
    ##############################################################################
    Label(plottingmenu_layout[1, 1], "Abiotic variable\n(right upper plot)";
          halign = :left, fontsize = 16)
    menu_abiotic = Menu(plottingmenu_layout[2, 1],
        options = zip([
                "Precipitation [mm]",
                "Potential evapo-\ntranspiration [mm]",
                "Air temperature [°C]\n",
                "Air temperaturesum [°C]\n",
                "Photosynthetically active\nradiation [MJ ha⁻¹]",
            ], [
                :precipitation,
                :PET,
                :temperature,
                :temperature_sum,
                :PAR,
            ]))
    Label(graz_mow_layout[1, 1], "grazing/mowing?"; fontsize = 16)
    toggle_grazmow = Toggle(graz_mow_layout[1, 2], active = false)

    ##############################################################################
    # Right part: likelihood and parameter settings
    ##############################################################################
    lls = (;
        biomass = Observable(0.0),
        traits = Observable(0.0))
    ll_label = @lift("Loglikelihood biomass: $(round($(lls.biomass))) traits: $(round($(lls.traits)))   gradient:")
    Label(righttop_layout[1, 1], ll_label; fontsize = 16)
    gradient_toggle = Toggle(righttop_layout[1, 2]; active = false)
    preset_button = Button(righttop_layout[1, 3]; label = "reset parameter")

    p = SimulationParameter()
    for k in keys(variable_p)
        p[k] = variable_p[k]
    end
    inference_obj = calibrated_parameter(; input_obj)

    parameter_keys = keys(p)

    lb = 0.01 .* ustrip.(collect(p))
    ub = 3 .* ustrip.(collect(p))

    for k in keys(inference_obj.lb)
        key_index = findfirst(k .== parameter_keys)

        lb[key_index] = inference_obj.lb[k]
        ub[key_index] = inference_obj.ub[k]
    end
    p_val = ustrip.(collect(p))

    inference_keys = keys(inference_obj.priordists)
    all_keys = collect(keys(p))
    is_inf_p = parameter_keys .∈ Ref(keys(inference_obj.priordists))
    inf_str = ifelse.(is_inf_p, "θ: ", "")

    nstart2 = length(p) - length(p) ÷ 2 + 1
    nend1 = nstart2 - 1
    [Label(param_layout[i, 1],
           "$(inf_str[i]) $(parameter_keys[i]) [$(@sprintf("%.1E", lb[i])), $(@sprintf("%.1E", ub[i]))]";
           halign = :left) for i in 1:nend1]
    [Label(param_layout[i+1-nstart2, 4],
           "$(inf_str[i]) $(parameter_keys[i]) [$(@sprintf("%.1E", lb[i])), $(@sprintf("%.1E", ub[i]))]";
            halign = :left) for i in nstart2:length(p)]

    tb1 = [Textbox(param_layout[i, 2],
                   stored_string = "$(p_val[i])",
                   validator = Float64,
             textpadding = (2, 2, 2, 2), halign = :left) for i in 1:nend1]
    tb2 = [Textbox(param_layout[i+1-nstart2, 5],
                   stored_string = "$(p_val[i])",
                   validator = Float64, textpadding = (2, 2, 2, 2),
                   halign = :left) for i in nstart2:length(p)]
    tb_p = vcat(tb1, tb2)

    gradient_values = [Observable(0.0) for _ in eachindex(p)]
    [Label(param_layout[i, 3],
           @lift("$(@sprintf("%.1E", $(gradient_values[i])))");
           halign = :left) for i in 1:nend1]
    [Label(param_layout[i+1-nstart2, 6],
           @lift("$(@sprintf("%.1E", $(gradient_values[i])))");
           halign = :left) for i in nstart2:length(p)]

    ##############################################################################
    # Adjust gap size
    ##############################################################################
    [rowgap!(param_layout, i, 0) for i in 1:(length(p) ÷ 2 - 1)]
    colgap!(fig.layout, 1, 10)
    colgap!(param_layout, 3, 15)

    ##############################################################################
    # Plot axes
    ##############################################################################
    axes = Dict()
    axes[:biomass] = Axis(topplots_layout[1, 1:2]; alignmode = Outside(),
                          limits = (nothing, nothing, -100.0, 5500.0))
    axes[:soilwater] = Axis(topplots_layout[1, 3]; alignmode = Outside())
    axes[:abiotic] = Axis(topplots_layout[1, 4]; alignmode = Outside())
    axes[:sla] = Axis(bottomplots_layout[1, 1]; alignmode = Outside())
    axes[:rsa] = Axis(bottomplots_layout[1, 2]; alignmode = Outside())
    axes[:height] = Axis(bottomplots_layout[1, 3]; alignmode = Outside())
    axes[:lnc] = Axis(bottomplots_layout[1, 4]; alignmode = Outside())
    axes[:amc] = Axis(bottomplots_layout[1, 5]; alignmode = Outside())

    ##############################################################################
    # Put all plot objects and observables in a named tuple
    ##############################################################################
    obs = (;
        run_button,
        preset_button,
        menu_samplingtype,
        menu_plotID,
        menu_abiotic,
        parameter_keys,
        tb_p,
        toggles_included,
        toggle_grazmow,
        toggle_validdata,
        toggle_standingbiomass,
        lls,
        gradient_values,
        gradient_toggle)

    return (; fig, axes, obs)
end

function test_date(x)
    return isnothing(tryparse(Dates.Date, x, Dates.dateformat"mm-dd")) ? false : true
end

function test_patchnumber(x)
    parsed_num = tryparse(Int64, x)
    if isnothing(parsed_num)
        return false
    else
        isinteger(sqrt(parsed_num))
    end
end
