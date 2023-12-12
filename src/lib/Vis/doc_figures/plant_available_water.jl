function plant_available_water(sim, valid; path = nothing)
    #####################
    mp = valid.model_parameters()
    inf_p = (; zip(Symbol.(mp.names), mp.best)...)
    input_obj = valid.validation_input(;
        plotID = "HEG01", nspecies = 25)
    calc = sim.preallocate_vectors(; input_obj)
    container = sim.initialization(; input_obj, inf_p, calc)
    container.calc.biomass_density_factor .= 1
    #####################

    fig = Figure(; size = (900, 800))

    WHC = 100u"mm"
    PWP = 0u"mm"
    PET_vals = LinRange(0.0, 5.0, 200)u"mm / d"

    for (i, W) in enumerate([20, 80]u"mm")
        for (u, βₚₑₜ) in enumerate([0.2, 1])
            container = @set container.p.βₚₑₜ = βₚₑₜ

            x = (W - PWP) / (WHC - PWP)
            w = Float64[]

            for PET in PET_vals
                sim.plant_available_water!(; container, W, PWP, WHC, PET)
                push!(w, container.calc.water_splitted[1])
            end

            Axis(fig[i, u];
                title = i == 1 ? "βₚₑₜ = $βₚₑₜ" : "",
                xlabel = i == 2 ? "Potential evapotranspiration PET [mm d⁻¹]" : "",
                ylabel = u == 1 ? "Plant available water Wₚ" : "",
                yticks = 0.0:0.2:1.0,
                xticklabelsvisible = i == 2 ? true : false,
                yticklabelsvisible = u == 1 ? true : false,
                limits = (nothing, nothing, 0, 1.05))

            lines!(ustrip.(PET_vals), w;
                color = :black,
                linewidth = 2,
                linestyle = :solid)
            lines!(quantile(ustrip.(PET_vals), [0.0, 1.0]), [x, x];
                    color = :blue)
            lines!([2,2], [0,x]; color = :red, linestyle = :dash)

            if i == 1 && u == 1
                text!(ustrip.(PET_vals)[end], x;
                    text = L"W_{sc, txy}",
                    align = (:right, :bottom),
                    color = :blue)
                text!(2, 0.05, text = L"\alpha_{pet}", color = :red)
            end
        end
    end


    Axis(fig[3,1:2]; xticks = 0:1:10, ylabel = "probability",
         xlabel = "Potential evapotranspiration over grass for three regions in Germany in 2006 - 2021 [mm d⁻¹]")
    hist!(valid.data.input.pet.PET; bins=30, normalization = :probability)

    rowsize!(fig.layout, 3, Relative(0.2))
    rowgap!(fig.layout, 1, 5)
    colgap!(fig.layout, 1, 5)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
