function climate_series(; sol)
    fig = Figure(resolution = (800, 1500))

    bax = Axis(fig[1, 1];
        ylabel = "Total green bio-\nmass of all patches\n[t DM ha⁻¹]",
        xticklabelsvisible = false)
    wax = Axis(fig[2, 1];
        ylabel = "Water of first\npatch [mm]",
        xticklabelsvisible = false)
    peax = Axis(fig[3, 1];
        ylabel = "Potential evapo-\ntranspiration [mm d⁻¹]",
        xticklabelsvisible = false)
    preax = Axis(fig[4, 1];
        ylabel = "Precipitation\n[mm d⁻¹]",
        xticklabelsvisible = false)
    tempax = Axis(fig[5, 1];
        ylabel = "Air temperature\n[°C]",
        xticklabelsvisible = false)
    tempsumax = Axis(fig[6, 1];
        ylabel = "Air temperature\nsum [°C]",
        xticklabelsvisible = false)
    pax = Axis(fig[7, 1];
        ylabel = "Photosynthetically active\nradiation [MJ m⁻² d⁻¹]",
        xlabel = "Time [years]")

    total_biomass = total_t_biomass(sol.biomass)

    my_set = Dict(:markersize => 4, :linewidth => 0.1)

    lines!(bax,
        sol.t ./ 365,
        ustrip.(uconvert.(u"Mg / ha", total_biomass));
        color = :grey)
    scatterlines!(wax, sol.t ./ 365, ustrip.(sol.water[:, 1]);
        my_set...,
        color = :turquoise3)

    scatterlines!(preax, sol.t[2:end] ./ 365,
        ustrip.(sol.p.env_data.precipitation);
        my_set...,
        color = :blue)

    scatterlines!(peax, sol.t[2:end] ./ 365, ustrip.(sol.p.env_data.PET);
        my_set...,
        color = :brown)

    scatterlines!(tempax,
        sol.t[2:end] ./ 365,
        ustrip.(sol.p.env_data.temperature);
        my_set...,
        color = :red)

    scatterlines!(tempsumax,
        sol.t[2:end] ./ 365,
        ustrip.(sol.p.env_data.temperature_sum);
        my_set...,
        color = :red)

    scatterlines!(pax, sol.t[2:end] ./ 365, ustrip.(sol.p.env_data.PAR);
        my_set...,
        color = :orange)

    display(fig)

    return nothing
end
