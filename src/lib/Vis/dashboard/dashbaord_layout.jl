function dashboard_layout(; valid)
    fig = Figure(; resolution = (1700, 950))

    top_menu = fig[1, 1:2] = GridLayout()
    plots_layout = fig[2, 1] = GridLayout()
    param_layout = fig[2, 2] = GridLayout()

    colsize!(fig.layout, 2, Relative(0.3))
    rowsize!(fig.layout, 2, Relative(0.7))

    run_button = Button(top_menu[1, 1]; label = "run")

    #------------- scenario
    # scenario_layout = top_menu[1, 2:4] = GridLayout()
    # scenarioleft_layout = scenario_layout[1, 1] = GridLayout()
    # scenariocenter_layout = scenario_layout[1, 2] = GridLayout()
    # scenarioright_layout = scenario_layout[1, 3] = GridLayout()
    # Box(scenario_layout[1, 1:3], alignmode = Outside(-8);
    #     color = (:black, 0.0))

    #------------- scenario and validation
    sim_layout = top_menu[1, 2] = GridLayout()
    Box(top_menu[1, 2], alignmode = Outside(-8);
        color = (:black, 0.0))

    #------------- validation and plotting settings
    topright_layout = top_menu[1, 3] = GridLayout()
    validation_layout = topright_layout[1, 1] = GridLayout()
    Box(topright_layout[1, 1], alignmode = Outside(-8);
        color = (:black, 0.0))

    plottingmenu_layout = topright_layout[2, 1] = GridLayout()

    # [colgap!(top_menu, i, s) for (i, s) in enumerate([50, 20, 20, 50, 50])]
    # colsize!(top_menu, 6, Relative(0.34))

    ############# Exploratory
    # Label(scenarioleft_layout[1, 1:2], "Scenario";
    #     tellwidth = false, halign = :left,
    #     font = :bold)
    # menu_explo = Menu(scenarioleft_layout[2, 1:2],
    #     options = zip([
    #             "Schorfheide-Chorin",
    #             "Hainich",
    #             "Schwäbische Alb",
    #         ], ["SCH", "HAI", "ALB"]),
    #     tellwidth = false)

    ############# Number of years
    # Label(scenarioleft_layout[3, 1], "Number of\nyears";
    #     tellwidth = false, halign = :right)
    # nyears = Observable(10)
    # tb_years = Textbox(scenarioleft_layout[3, 2],
    #     placeholder = string(nyears.val),
    #     stored_string = string(nyears.val),
    #     validator = Int64)

    # on(tb_years.stored_string) do s
    #     nyears[] = parse(Int64, s)
    # end
    # [rowgap!(scenarioleft_layout, i, dist) for (i, dist) in enumerate([10, 15])]

    ############# Mowing
    # Label(scenariocenter_layout[1, 1:2], "Mowing (date)";
    #     tellwidth = true, halign = :left)
    # toggles_mowing = [Toggle(scenariocenter_layout[i + 1, 1],
    #     active = false, halign = :left) for i in 1:5]
    # tb_mowing_date = [Textbox(scenariocenter_layout[i + 1, 2],
    #     halign = :left,
    #     placeholder = mow_date, validator = test_date,
    #     stored_string = mow_date) for (i, mow_date) in enumerate([
    #     "05-01",
    #     "06-01",
    #     "07-01",
    #     "08-01",
    #     "09-01",
    # ])]
    # [rowgap!(scenariocenter_layout, i, 4) for i in 1:5]
    # colgap!(scenariocenter_layout, 1, 10)

    ############# Grazing
    # Label(scenarioright_layout[1, 1:4], "Grazing (start date, end date, LD)";
    #     halign = :left)
    # toggles_grazing = [Toggle(scenarioright_layout[i + 1, 1], active = false) for i in 1:2]
    # tb_grazing_start = [Textbox(scenarioright_layout[i + 1, 2],
    #     placeholder = graz_start, validator = test_date,
    #     stored_string = graz_start) for (i, graz_start) in enumerate(["05-01", "08-01"])]
    # tb_grazing_end = [Textbox(scenarioright_layout[i + 1, 3],
    #     placeholder = graz_end, validator = test_date,
    #     stored_string = graz_end) for (i, graz_end) in enumerate(["07-01", "10-01"])]
    # tb_grazing_intensity = [Textbox(scenarioright_layout[i + 1, 4],
    #     placeholder = string(intensity), validator = Float64,
    #     stored_string = string(intensity)) for (i, intensity) in enumerate([2, 2])]

    ############# Nutrients
    # slidergrid_nut = SliderGrid(scenarioright_layout[4, 1:4],
    #     (label = "Nutrient\nindex",
    #         range = 0.0:0.01:1.0,
    #         format = "{:.2f}",
    #         startvalue = 0.8))
    # slider_nut = slidergrid_nut.sliders[1]

    ############# water holding capacity and permanent wilting point
    # Label(scenarioright_layout[5, 1], "PWP, WHC";
    #     halign = :left)
    # slider_pwp_whc = IntervalSlider(scenarioright_layout[5, 2:3],
    #     range = LinRange(30, 350, 500),
    #     startvalues = (80, 150))
    # whc_pwp_labeltext = lift(slider_pwp_whc.interval) do pwp_whc
    #     string(Int.(round.(pwp_whc)))
    # end
    # Label(scenarioright_layout[5, 4], whc_pwp_labeltext)
    # [colgap!(scenarioright_layout, i, dist) for (i, dist) in enumerate([5, 4, 4])]
    # [rowgap!(scenarioright_layout, i, dist) for (i, dist) in enumerate([5, 4, 10, 10])]

    ############# Number of species and patches
    Label(sim_layout[1, 1:2], "Simulation settings";
        tellwidth = true, halign = :left,
        font = :bold)

    ### number of species
    Label(sim_layout[2, 1], "Number of species";
        fontsize = 15,
        tellwidth = true, halign = :right)
    nspecies = Observable(25)
    tb_species = Textbox(sim_layout[2, 2],
        fontsize = 12,
        textpadding = (10, 10, 2, 2),
        placeholder = string(nspecies.val),
        stored_string = string(nspecies.val),
        validator = Int64)
    on(tb_species.stored_string) do s
        nspecies[] = parse(Int64, s)
    end

    ### number of patches
    Label(sim_layout[3, 1], "Number of patches";
        fontsize = 15,
        tellwidth = true, halign = :right)
    npatches = Observable(1)
    tb_npatches = Textbox(sim_layout[3, 2],
        fontsize = 12,
        textpadding = (10, 10, 2, 2),
        placeholder = string(npatches.val),
        stored_string = string(npatches.val),
        validator = test_patchnumber)
    on(tb_npatches.stored_string) do s
        npatches[] = parse(Int64, s)
    end

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
    [Label(sim_layout[3 + i, 1], labels[i];
        tellwidth = true, halign = :right,
        fontsize = 10) for i in eachindex(labels)]
    toggle_senescence_included = Toggle(sim_layout[4, 2],
        active = true, height = 10)
    toggle_potgrowth_included = Toggle(sim_layout[5, 2],
        active = true, height = 10)
    toggle_mowing_included = Toggle(sim_layout[6, 2],
        active = true, height = 10)
    toggle_grazing_included = Toggle(sim_layout[7, 2],
        active = true, height = 10)
    toggle_below_included = Toggle(sim_layout[8, 2],
        active = true, height = 10)
    toggle_height_included = Toggle(sim_layout[9, 2],
        active = true, height = 10)
    toggle_water_red = Toggle(sim_layout[10, 2],
        active = true, height = 10)
    toggle_nutr_red = Toggle(sim_layout[11, 2],
        active = true, height = 10)
    toggle_temperature_red = Toggle(sim_layout[12, 2],
        active = true, height = 10)
    toggle_season_red = Toggle(sim_layout[13, 2],
        active = true, height = 10)
    toggle_radiation_red = Toggle(sim_layout[14, 2],
        active = true, height = 10)

    [rowgap!(sim_layout, i, dist) for (i, dist) in enumerate(fill(5, 13))]
    colgap!(sim_layout, 1, 5)

    ############# Plot ID
    Label(validation_layout[1, 1], "Validation";
        tellwidth = true, halign = :left,
        font = :bold)

    Label(validation_layout[1, 2], "predictive check?";
        tellwidth = true, halign = :left,)
    toggle_predcheck = Toggle(validation_layout[1, 3],
        active = false,
        tellwidth = false,
        halign = :left)

    menu_samplingtype = Menu(validation_layout[2, 1:2];
        options = zip(["fixed", "sample prior", "sample posterior"],
            [:fixed, :prior, :posterior]))

    menu_plotID = Menu(validation_layout[2, 3];
        options = ["$(explo)$(lpad(i, 2, "0"))" for i in 1:50
                   for explo in ["HEG", "SEG", "AEG"]])

    ############# Abiotic variable
    Label(plottingmenu_layout[1, 1], "Abiotic variable (right lower plot)";
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

    ############# Coloring -> traits or biomass
    Label(plottingmenu_layout[3, 1], "Color/trait (right upper plot)";
        tellwidth = false, halign = :left)
    menu_color = Menu(plottingmenu_layout[4, 1],
        options = zip([
                "Specific leaf area [m² g⁻¹]",
                "Leaf nitrogen \nper leaf mass [mg g⁻¹]",
                "Height [m]",
                "Mycorrhizal colonisation",
                "Root surface area /\nabove ground biomass [m² g⁻¹]",
            ], [:sla, :lncm, :height, :amc, :rsa_above]))
    [rowgap!(plottingmenu_layout, i, dist) for (i, dist) in enumerate([5, 15, 5])]

    ############# Checkbox bands and mowing/grazing visible?
    righttoggles_layout = plottingmenu_layout[1:4, 2] = GridLayout()

    Label(righttoggles_layout[1, 1], "bands visible?";
        halign = :left)
    toggle_bands = Toggle(righttoggles_layout[1, 2], active = false)
    Label(righttoggles_layout[2, 1], "grazing/mowing?";
        halign = :left)
    toggle_grazmow = Toggle(righttoggles_layout[2, 2], active = false)
    Label(righttoggles_layout[3, 1], "valid data?";
        halign = :left)
    toggle_validdata = Toggle(righttoggles_layout[3, 2], active = true)

    ############# Trait Colorbar
    rowsize!(param_layout, 1, Fixed(70))

    ############# Time SliderGrid
    slidergrid_time = SliderGrid(param_layout[1, 1],
        (label = "time",
            range = 1:10:5000,
            startvalue = 100,
            snap = false),
        (label = "nutheterog.",
            range = 0:0.01:1,
            startvalue = 0.0),
        tellwidth = false, tellheight = false,
        valign = :top,
        halign = :right)
    slider_time = slidergrid_time.sliders[1]
    slider_nutheterog = slidergrid_time.sliders[2]
    rowgap!(slidergrid_time.layout, 1, 0)

    ############# Likelihood
    lls = (;
        biomass = Observable(0.0),
        traits = Observable(0.0),
        traits_var = Observable(0.0),
        soilmoisture = Observable(0.0))
    ll_label = @lift("LL biomass: $(round($(lls.biomass))) traits (cwm, cwv): $(round($(lls.traits))), $(round($(lls.traits_var))) moist: $(round($(lls.soilmoisture)))")
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
    axes = [Axis(plots_layout[i, u];
        alignmode = Outside())
            for (i, u) in zip([1, 1, 1, 2, 2, 2], [1, 2, 3, 1, 2, 3])]
    toggle_traitvar = Toggle(plots_layout[1, 2], active = false;
        tellwidth = false, tellheight = false, halign = :right, valign = :top)

    display(fig)

    obs = (;
        run_button,
        menu_samplingtype,
        menu_plotID,
        menu_abiotic,
        menu_color,
        sliders_param,
        nspecies,
        npatches,
        toggle_predcheck,
        toggle_bands,
        toggle_grazmow,
        toggle_validdata,
        toggle_traitvar,
        slider_time,
        slider_nutheterog,
        toggle_senescence_included,
        toggle_potgrowth_included,
        toggle_mowing_included,
        toggle_grazing_included,
        toggle_below_included,
        toggle_height_included,
        toggle_water_red,
        toggle_nutr_red,
        toggle_temperature_red,
        toggle_season_red,
        toggle_radiation_red,
        lls

        ##### Scenario
        # menu_explo,
        # slider_nut,
        # slider_pwp_whc,
        # nyears,
        # toggles_grazing,
        # tb_grazing_start,
        # tb_grazing_end,
        # tb_grazing_intensity,
        # toggles_mowing,
        # tb_mowing_date,
    )

    return (; axes, obs)
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
