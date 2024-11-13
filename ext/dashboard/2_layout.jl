function dashboard_layout(; variable_p)
    fig = Figure(; size = (1900, 950))

    ##############################################################################
    # Define grid layouts
    ##############################################################################
    top_menu = GridLayout(fig[1, 1])
    sim_layout = GridLayout(top_menu[1, 2]; tellwidth = false)
    plotsettings_layout = GridLayout(top_menu[1, 3]; valign = :top)

    plots_layout = GridLayout(fig[2, 1])
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
    # Turn off parts of the model
    ##############################################################################
    Label(sim_layout[1, 1:2], "Turn off parts of the model";
        halign = :left, font = :bold, fontsize = 16)
    input_obj = gts.validation_input("HEG01"; nspecies = 1)
    included_symbols = keys(input_obj.simp.included)
    is_included = collect(values(input_obj.simp.included))
    labels = String.(included_symbols)
    nstart2 = length(labels) - length(labels) ÷ 2 + 1
    nend1 = nstart2 - 1
    [Label(sim_layout[i+1, 1], labels[i]; halign = :right, fontsize = 10) for i in 1:nend1]
    [Label(sim_layout[i+2-nstart2, 3], labels[i]; halign = :right)
        for i in nstart2:length(labels)]
    left_toggles = [Toggle(sim_layout[i+1, 2], active = is_included[i], height = 10) for i in 1:nend1]
    right_toggle = [Toggle(sim_layout[i+2-nstart2, 4],
               active = is_included[i], height = 10) for i in nstart2:length(labels)]
    toggles_included_prep = vcat(left_toggles, right_toggle)
    toggles_included = Dict(zip(included_symbols, toggles_included_prep))

    ##############################################################################
    # Select panel
    ##############################################################################
    Label(plotsettings_layout[1, 1], "Select panel";
        tellwidth = true, halign = :left,
        font = :bold, fontsize = 16)

    which_pane = Observable(1)
    button_panelA = Button(plotsettings_layout[2, 1][1, 1], label = "Panel A: State variables")
    button_panelB = Button(plotsettings_layout[2, 1][1, 2], label = "Panel B: Traits")
    button_panelC = Button(plotsettings_layout[2, 1][1, 3], label = "Panel C: Growth reducer")
    button_panelD = Button(plotsettings_layout[2, 1][1, 4], label = "Panel D: Diversity")
    button_panelE = Button(plotsettings_layout[2, 1][1, 5], label = "Panel E: Abiotic input")


    ##############################################################################
    # Settings
    ##############################################################################
    Label(plotsettings_layout[3, 1], "Settings"; tellwidth = true, halign = :left,
          font = :bold, fontsize = 16)
    leftplotsettings_layout = GridLayout(plotsettings_layout[4, 1][1, 1])
    rightplotsettings_layout = GridLayout(plotsettings_layout[4, 1][1, 2];
                                          valign = :top)


    Label(leftplotsettings_layout[1, 1], "PlotID of the Biodiversity Exploratories:";
        tellwidth = true, halign = :left, justification = :left, fontsize = 16)
    menu_plotID = Menu(leftplotsettings_layout[1, 2];
        options = ["$(explo)$(lpad(i, 2, "0"))"  for explo in ["HEG", "SEG", "AEG"]
                   for i in 1:50],
        halign = :left)

    trait_keys =  [:amc, :sla, :maxheight, :rsa, :lnc, :abp]
    Label(leftplotsettings_layout[2, 1], "Trait (panel B):";
          halign = :left, justification = :left, fontsize = 16)
    menu_traits = Menu(leftplotsettings_layout[2, 2];
                       options = zip(string.(trait_keys), trait_keys))

    Label(leftplotsettings_layout[3, 1], "Abiotic variable (panel E):";
          halign = :left, justification = :left, fontsize = 16)
    menu_abiotic = Menu(leftplotsettings_layout[3, 2],
        options = zip([
                "Precipitation",
                "Potential evapotranspiration",
                "Air temperature",
                "Air temperaturesum",
                "Photosynthetically active radiation",
            ], [
                :precipitation,
                :PET,
                :temperature,
                :temperature_sum,
                :PAR,
            ]))


    Label(rightplotsettings_layout[1, 1], "show validation\ndata (panel A, B, D)?";
        halign = :left, justification = :left, fontsize = 16)
    toggle_validdata = Toggle(rightplotsettings_layout[1, 2],
        active = true,
        tellwidth = false,
        halign = :left)

    Label(rightplotsettings_layout[2, 1], "show standing\nbiomass (panel A)?";
        halign = :left, justification = :left, fontsize = 16)
    toggle_standingbiomass = Toggle(rightplotsettings_layout[2, 2],
        active = true,
        tellwidth = false,
        halign = :left)

    Label(rightplotsettings_layout[3, 1], "show grazing and\nmowing (panel A)?";
          halign = :left, justification = :left, fontsize = 16)
    toggle_grazmow = Toggle(rightplotsettings_layout[3, 2], active = false)


    ##############################################################################
    # Right part: Parameter settings
    ##############################################################################
    preset_button = Button(righttop_layout[1, 1]; label = "reset parameter")

    p = gts.optim_parameter()
    parameter_keys = collect(keys(p))
    for k in keys(variable_p)
        p[k] = variable_p[k]
    end
    p_val = round.(ustrip.(collect(p)); digits = 5)

    nstart2 = length(p) - length(p) ÷ 2 + 1
    nend1 = nstart2 - 1
    [Label(param_layout[i, 1],
           "$(parameter_keys[i]) ";
           halign = :left) for i in 1:nend1]
    [Label(param_layout[i+1-nstart2, 4],
           "$(parameter_keys[i])";
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
    rowgap!(fig.layout, 1, 50)
    colgap!(param_layout, 3, 15)

    ##############################################################################
    # Plot axes
    ##############################################################################
    axes = create_axes_paneA(plots_layout)

    ##############################################################################
    # Put all plot objects and observables in a named tuple
    ##############################################################################
    obs = (;
        run_button,
        preset_button,
        button_panelA,
        button_panelB,
        button_panelC,
        button_panelD,
        button_panelE,
        which_pane,
        menu_plotID,
        menu_abiotic,
        menu_traits,
        parameter_keys,
        tb_p,
        toggles_included,
        toggle_grazmow,
        toggle_validdata,
        toggle_standingbiomass,
        plots_layout)

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

function clear_panel!(layout)
    clear!(x) = delete!(x)
    function clear!(x::GridLayout)
        for el in contents(x)
            clear!(el)
        end
    end
    clear!(layout)
    Makie.trim!(layout)
end

function clear_plotobj_axes(obj, key)
    ax = obj.axes[key]
    for plot in copy(ax.scene.plots)
        delete!(ax.scene, plot)
    end

    return ax
end
