function add_nans(t, b)
    append!(t, [365 * i for i in 1:10])
    append!(b, [NaN for i in 1:10])

    return sort(t), b[sortperm(t)]
end

function biomass_validation2(sim::Module, valid::Module; plotID, inf_p)
    fig = Figure()
    Axis(fig[1, 1];
        xticks = 2012:2:2022,
        xminorticks = 2012:2022,
        xminorticksvisible = true,
        xlabel = "Time [years]",
        ylabel = "Total biomass [kg/ha]")

    for _ in 1:5
        data, sol = valid.get_plottingdata(sim;
            plotID, inf_p,
            startyear = 2012,
            endyear = 2021)

        biomass_sim = vec(sum(ustrip.(sol.biomass); dims = 3))
        sim_t = 2012 .+ sol.t ./ 365

        lines!(sim_t, biomass_sim; color = (:grey, 0.2))
    end

    data, sol = valid.get_plottingdata(sim;
        plotID, inf_p,
        startyear = 2012,
        endyear = 2021)

    mdata_t = 2012 .+ data.measured_biomass_t ./ 365
    mdata = data.measured_biomass
    mdata1 = data.measured_biomass1
    f_mdata = mdata_t .< 2022 .&& mdata_t .> 2016

    scatter!(mdata_t[f_mdata], mdata[f_mdata],
        marker = :hexagon, color = :black, markersize = 15,
        label = "Cutted and weighted biomass")
    scatter!(mdata_t[f_mdata], mdata1[f_mdata],
        marker = :hexagon, color = :black, markersize = 15)

    return fig
end

function biomass_validation(data, sol; plotID = "")
    biomass_sim = vec(sum(ustrip.(sol.biomass); dims = 3))

    data_t_prep, data_biomass = add_nans(data.biomass_t, data.biomass)
    data_t = 2012 .+ data_t_prep ./ 365

    mdata_t = 2012 .+ data.measured_biomass_t ./ 365
    mdata = data.measured_biomass
    mdata1 = data.measured_biomass1
    f_mdata = mdata_t .< 2022

    sim_t = 2012 .+ sol.t ./ 365

    fig = Figure(; resolution = (900, 600))
    ax = Axis(fig[1, 1];
        title = "$plotID, WHC: $(round(typeof(1u"mm"), sol.p.site.WHC)), PWP: $(round(typeof(1u"mm"), sol.p.site.PWP)), Nut: $(round(sol.p.site.nutrient_index; digits=2))",
        xticks = 2012:2:2022,
        xminorticks = 2012:2022,
        xminorticksvisible = true,
        xlabel = "Time [years]",
        ylabel = "Total biomass [kg/ha]",
        limits = (2011.8, 2022.2, 0, 6000))
    add_mowing!(ax, sol;)
    add_grazing!(ax, sol;)
    scatterlines!(data_t,
        data_biomass;
        label = "Statistical satellite model",
        color = (:red, 0.6),
        linewidth = 5)
    lines!(sim_t, biomass_sim;
        label = "Mechanistic simulation model",
        color = (:green, 0.6),
        linewidth = 5)
    scatter!(mdata_t[f_mdata], mdata[f_mdata],
        marker = :hexagon, color = :black, markersize = 15,
        label = "Cutted and weighted biomass")
    scatter!(mdata_t[f_mdata], mdata1[f_mdata],
        marker = :hexagon, color = :black, markersize = 15)

    axislegend(; position = :lt)

    return fig
end

function add_mowing!(ax, sol; ymax = 6000)
    mowing_f = .!isnan.(sol.daily_input.mowing)
    xs = sol.numeric_date[mowing_f]

    for x in xs
        lines!(ax, [x, x], [0.0, ymax]; color = :magenta3)
    end
end

function add_grazing!(ax, sol; ymax = 6000)
    ylower = fill(0.0, length(sol.daily_input.grazing))
    yupper = (.!isnan.(sol.daily_input.grazing)) .* ymax
    band!(ax, sol.numeric_date, ylower, yupper;
        color = (:steelblue4, 0.6))
end

function soilmoisture_validation(data, sol;
        inityears = 5, converted = true, patch = 1)
    moisture = ustrip.(sol.water[:, patch]) ./ sol.p.site.root_depth
    moisture[moisture .> 1] .= 1

    if converted
        moisture .*= sol.p.inf_p.moisture_conv
    end

    data_t = 2012 .+ data.soilmoisture_t ./ 365
    sim_t = 2012 .+ sol.t ./ 365
    fig = Figure()
    Axis(fig[1, 1];
        xticks = 2012:2022)
    scatterlines!(data_t,
        data.soilmoisture;
        label = "Measured soil moisture")
    scatterlines!(sim_t, moisture;
        label = "Simulated soil moisture$(converted ? "_conv" : "")")

    axislegend(; position = :lb)

    return fig
end

function evaporation_validation(data, sol; patch = 1)
    evaporation = ustrip.(sol.evaporation[:, patch])

    data_t = 2012 .+ data.evaporation_t ./ 365
    sim_t = 2012 .+ sol.t ./ 365
    fig = Figure()
    Axis(fig[1, 1];
        xticks = 2012:2022,
        ylabel = "Evaporation [mm]",
        xlabel = "Time [years]")
    scatterlines!(data_t,
        data.evaporation;
        label = "Measured evaporation")
    scatterlines!(sim_t, evaporation;
        label = "Simulated evaporation")

    axislegend(; position = :lt)

    return fig
end
