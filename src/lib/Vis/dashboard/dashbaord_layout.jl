function dashboard_layout(; sim, valid, variable_p)
    fig = Figure(; size = (1700, 850))

    top_menu = GridLayout(fig[1, 1])
    plots_layout =  GridLayout(fig[2, 1])
    plots_trait_layout = GridLayout(plots_layout[2, 1:4])

    param_layout = GridLayout(fig[1:2, 2]; valign = :top)

    left_topmenu = GridLayout(top_menu[1, 1]; )
    right_topmenu = GridLayout(top_menu[1, 2]; valign = :top )

    sim_layout = GridLayout(left_topmenu[1, 2])


    validation_layout = GridLayout(right_topmenu[1, 1]; valign = :top)
    plottingmenu_layout = GridLayout(right_topmenu[1, 2]; valign = :top)
    righttoggles_layout = GridLayout(right_topmenu[1, 3]; valign = :top)


    colsize!(fig.layout, 2, Relative(0.3))
    rowsize!(fig.layout, 2, Relative(0.7))

    run_button = Button(left_topmenu[1, 1]; label = "run")

    #------------- Simulation settings
    Box(left_topmenu[1, 2], alignmode = Outside(-8);
        color = (:black, 0.0))

    #------------- validation and plotting settings
    Box(right_topmenu[1, 1], alignmode = Outside(-8);
        color = (:black, 0.0))
    Box(right_topmenu[1, 2:3], alignmode = Outside(-8);
        color = (:black, 0.0))

    ############# Number of species and patches
    Label(sim_layout[1, 1:2], "Simulation settings";
        tellwidth = true, halign = :left,
        font = :bold, fontsize = 16)

    ###########
    input_obj = valid.validation_input(; plotID = "HEG01", nspecies = 1)
    included_symbols = keys(input_obj.simp.included)
    labels = String.(included_symbols)

    nstart2 = length(labels) - length(labels) ÷ 2 + 1
    nend1 = nstart2 - 1

    [Label(sim_layout[i+1, 1], labels[i];
        tellwidth = true, halign = :right,
        fontsize = 10) for i in 1:nend1]
    [Label(sim_layout[i+2-nstart2, 3], labels[i];
        tellwidth = true, halign = :right,
        fontsize = 10) for i in nstart2:length(labels)]

    left_toggles = [Toggle(sim_layout[i+1, 2],
               active = true, height = 10) for i in 1:nend1]
    right_toggle = [Toggle(sim_layout[i+2-nstart2, 4],
               active = true, height = 10) for i in nstart2:length(labels)]

    toggles_included_prep = vcat(left_toggles, right_toggle)
    toggles_included = Dict(zip(included_symbols, toggles_included_prep))

    [rowgap!(sim_layout, i, dist)
        for (i, dist) in enumerate(fill(5, length(included_symbols) ÷ 2))]
    colgap!(sim_layout, 1, 5)
    colgap!(sim_layout, 3, 5)

    ############# Plot ID
    Label(validation_layout[1, 1], "Validation";
        tellwidth = true, halign = :left,
        font = :bold, fontsize = 16)
    Label(validation_layout[2, 1], "validation data?";
        halign = :left, fontsize = 16)
    toggle_validdata = Toggle(validation_layout[2, 2],
        active = true,
        tellwidth = false,
        halign = :left)

    Label(validation_layout[3, 1], "Parameter:";
        tellwidth = true, halign = :left, fontsize = 16)
    menu_samplingtype = Menu(validation_layout[4, 1];
        options = zip(["fixed (see right)", "sample prior", "sample posterior"],
            [:fixed, :prior, :posterior]),
        halign = :left)

    Label(validation_layout[3, 2], "PlotID:";
        tellwidth = true, halign = :left, fontsize = 16)
    menu_plotID = Menu(validation_layout[4, 2];
        options = ["$(explo)$(lpad(i, 2, "0"))"  for explo in ["HEG", "SEG", "AEG"]
                   for i in 1:50],
        width = 100,
        halign = :left)

    [rowgap!(validation_layout, i, 5) for i in 1:3]

    ############# Abiotic variable
    Label(plottingmenu_layout[1, 1], "Abiotic variable (right upper plot)";
        tellwidth = false, halign = :left, fontsize = 16)
    menu_abiotic = Menu(plottingmenu_layout[2, 1],
        options = zip([
                "Precipitation [mm d⁻¹]",
                "Potential evapo-\ntranspiration [mm d⁻¹]",
                "Air temperature [°C]\n",
                "Air temperaturesum [°C]\n",
                "Photosynthetically active\nradiation [MJ ha⁻¹ d⁻¹]",
            ], [
                :precipitation,
                :PET,
                :temperature,
                :temperature_sum,
                :PAR,
            ]))
    [rowgap!(plottingmenu_layout, i, dist) for (i, dist) in enumerate([5])]

    ############# Checkbox bands and mowing/grazing visible?
    Label(righttoggles_layout[1, 1], "grazing/mowing?";
        halign = :left, valign = :top, fontsize = 16)
    toggle_grazmow = Toggle(righttoggles_layout[1, 2], active = false)

    ############# Trait Colorbar
    rowsize!(param_layout, 1, Fixed(70))

    ############# Likelihood
    lls = (;
        biomass = Observable(0.0),
        traits = Observable(0.0))
    ll_label = @lift("Loglikelihood biomass: $(round($(lls.biomass))) traits: $(round($(lls.traits)))")
    Label(param_layout[1, 1], ll_label;
        tellwidth = false, halign = :left,
        fontsize = 16)

    preset_button = Button(param_layout[1, 2]; label = "reset")

    ############# Parameter values
    p = sim.parameter(; input_obj, variable_p)
    inference_obj = sim.calibrated_parameter(; input_obj)
    inference_keys = keys(inference_obj.units)
    all_keys = collect(keys(p))
    is_inf_p = all_keys .∈ Ref(inference_keys)

    p_inf_label = (; zip(Symbol.(:θ_, all_keys[is_inf_p]), collect(p)[is_inf_p])...)
    p_inf = (; zip(Symbol.(all_keys[is_inf_p]), collect(p)[is_inf_p])...)
    p_fixed = (; zip(all_keys[.!is_inf_p], collect(p)[.!is_inf_p])...)
    p = merge(p_inf_label, p_fixed)
    p_val = ustrip.(collect(p))
    parameter_keys = keys(merge(p_inf, p_fixed))
    lb = vcat(collect(inference_obj.lb), 0.01 .* ustrip.(collect(p_fixed)))
    ub = vcat(collect(inference_obj.ub), 3 .* ustrip.(collect(p_fixed)))

    param_slider_prep = [(label = string(name),
        range = LinRange(p1, p2, 1000),
        snap = false,
        format = "{:.5f}",
        linewidth = 10,
        startvalue = val) for (name, val, p1, p2) in zip(keys(p), p_val, lb, ub)]
    sliders_param = SliderGrid(param_layout[2, 1:2], param_slider_prep...; valign = :top)

    [rowgap!(sliders_param.layout, i, -2) for i in 1:(length(p) - 1)]
    rowgap!(param_layout, 1, -10)

    #############
    axes = Dict()
    axes[:biomass] = Axis(plots_layout[1, 1:2]; alignmode = Outside())
    axes[:soilwater] = Axis(plots_layout[1, 3]; alignmode = Outside())
    axes[:abiotic] = Axis(plots_layout[1, 4]; alignmode = Outside())
    axes[:sla] = Axis(plots_trait_layout[1, 1]; alignmode = Outside())
    axes[:rsa_above] = Axis(plots_trait_layout[1, 2]; alignmode = Outside())
    axes[:height] = Axis(plots_trait_layout[1, 3]; alignmode = Outside())
    axes[:lncm] = Axis(plots_trait_layout[1, 4]; alignmode = Outside())
    axes[:amc] = Axis(plots_trait_layout[1, 5]; alignmode = Outside())

    obs = (;
        run_button,
        preset_button,
        menu_samplingtype,
        menu_plotID,
        menu_abiotic,
        sliders_param,
        parameter_keys,
        toggles_included,
        toggle_grazmow,
        toggle_validdata,
        lls)

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
