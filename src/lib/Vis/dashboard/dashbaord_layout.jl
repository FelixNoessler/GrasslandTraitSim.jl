function dashboard_layout(; valid)
    fig = Figure(; size = (1700, 850))

    top_menu = fig[1, 1] = GridLayout()
    plots_layout = fig[2, 1] = GridLayout()
    plots_trait_layout = plots_layout[2, 1:3] = GridLayout()

    param_layout = fig[1:2, 2] = GridLayout(; valign = :top)


    left_topmenu = top_menu[1, 1] = GridLayout(; )
    right_topmenu = top_menu[1, 2] = GridLayout(; valign = :top )

    sim_layout = left_topmenu[1, 2] = GridLayout()


    validation_layout = right_topmenu[1, 1] = GridLayout(; valign = :top)
    plottingmenu_layout = right_topmenu[1, 2] = GridLayout(; valign = :top)
    righttoggles_layout = right_topmenu[1, 3] = GridLayout(; valign = :top)


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
        font = :bold)

    ###########
    labels = [
        "include senescence?", "potentital growth?",
        "include mowing?", "include grazing?",
        "include below comp.?", "plant height influence?",
        "include water reduction?",
        "include nutrient reduction?",
        "include temperature reduction?",
        "include seasonal reduction?",
        "include radtion reduction?"]
    included_symbols = [
        :senescence, :potential_growth,
        :mowing, :grazing,
        :belowground_competition, :height_competition,
        :water_growth_reduction,
        :nutrient_growth_reduction,
        :temperature_growth_reduction,
        :season_red, :radiation_red]
    [Label(sim_layout[i+1, 1], labels[i];
        tellwidth = true, halign = :right,
        fontsize = 10) for i in eachindex(labels)]
    toggles_included_prep = [
        Toggle(sim_layout[i+1, 2], active = true, height = 10) for i in eachindex(labels)]
    toggles_included = Dict(zip(included_symbols, toggles_included_prep))

    [rowgap!(sim_layout, i, dist) for (i, dist) in enumerate(fill(5, 11))]
    colgap!(sim_layout, 1, 5)

    ############# Plot ID
    Label(validation_layout[1, 1], "Validation";
        tellwidth = true, halign = :left,
        font = :bold)

    Label(validation_layout[2, 1], "predictive check?";
        tellwidth = true, halign = :left,)
    toggle_predcheck = Toggle(validation_layout[2, 2],
        active = true,
        tellwidth = false,
        halign = :left)
    Label(validation_layout[3, 1], "validation data?";
        halign = :left)
    toggle_validdata = Toggle(validation_layout[3, 2],
        active = true,
        tellwidth = false,
        halign = :left)

    Label(validation_layout[4, 1], "Parameter:";
        tellwidth = true, halign = :left)
    menu_samplingtype = Menu(validation_layout[5, 1];
        options = zip(["fixed (see right)", "sample prior", "sample posterior"],
            [:fixed, :prior, :posterior]),
        halign = :left)

    Label(validation_layout[4, 2], "PlotID:";
        tellwidth = true, halign = :left)
    menu_plotID = Menu(validation_layout[5, 2];
        options = ["$(explo)$(lpad(i, 2, "0"))" for i in 1:50
                   for explo in ["HEG", "SEG", "AEG"]],
        width = 100,
        halign = :left)

    [rowgap!(validation_layout, i, 5) for i in 1:4]

    ############# Abiotic variable
    Label(plottingmenu_layout[1, 1], "Abiotic variable (right upper plot)";
        tellwidth = false, halign = :left)
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
        halign = :left, valign = :top)
    toggle_grazmow = Toggle(righttoggles_layout[1, 2], active = false)

    ############# Trait Colorbar
    rowsize!(param_layout, 1, Fixed(70))

    ############# Likelihood
    lls = (;
        biomass = Observable(0.0),
        traits = Observable(0.0))
    ll_label = @lift("Loglikelihood biomass: $(round($(lls.biomass))) traits: $(round($(lls.traits)))")
    Label(param_layout[2, 1], ll_label;
        tellwidth = false, halign = :left,
        fontsize = 16)

    ############# Parameter values
    mp = valid.model_parameters()
    param_slider_prep = [(label = string(name),
        range = LinRange(p1 + 1e-10, p2, 1000),
        format = "{:.5f}",
        height = 15,
        linewidth = 15,
        startvalue = val) for (name, val, p1, p2) in zip(mp.names, mp.best, mp.lb, mp.ub)]
    sliders_param = SliderGrid(param_layout[3, 1], param_slider_prep...;)

    [rowgap!(sliders_param.layout, i, -3) for i in 1:(length(mp.names) - 1)]
    rowgap!(param_layout, 1, 5)
    rowgap!(param_layout, 2, 5)

    #############
    axes = Dict()
    axes[:biomass] = Axis(plots_layout[1, 1]; alignmode = Outside())
    axes[:soilwater] = Axis(plots_layout[1, 2]; alignmode = Outside())
    axes[:abiotic] = Axis(plots_layout[1, 3]; alignmode = Outside())
    axes[:sla] = Axis(plots_trait_layout[1, 1]; alignmode = Outside())
    axes[:rsa_above] = Axis(plots_trait_layout[1, 2]; alignmode = Outside())
    axes[:height] = Axis(plots_trait_layout[1, 3]; alignmode = Outside())
    axes[:lncm] = Axis(plots_trait_layout[1, 4]; alignmode = Outside())
    axes[:amc] = Axis(plots_trait_layout[1, 5]; alignmode = Outside())


    obs = (;
        run_button,
        menu_samplingtype,
        menu_plotID,
        menu_abiotic,
        sliders_param,
        toggles_included,
        toggle_predcheck,
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
