function plant_available_water(sim, valid; path = nothing)
    nspecies, container = create_container(; sim, valid)
    container.calc.biomass_density_factor .= 1.0

    fig = Figure(; size = (900, 800))

    WHC = 100u"mm"
    PWP = 0u"mm"
    PET_vals = LinRange(0.0, 5.0, 200)u"mm"

    for (i, W) in enumerate([20, 80]u"mm")
        for (u, β_pet) in enumerate([0.1, 0.3]u"mm^-1")
            container = @set container.p.β_pet = β_pet

            x = (W - PWP) / (WHC - PWP)
            w = Float64[]

            for PET in PET_vals
                sim.water_reduction!(; container, W, PET, PWP, WHC)
                push!(w, container.calc.Wp[1])
            end

            Axis(fig[i, u];
                title = i == 1 ? "β_pet = $β_pet" : "",
                xlabel = i == 2 ? "Potential evapotranspiration PET [mm]" : "",
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
         xlabel = "Potential evapotranspiration over grass for three regions in Germany in 2006 - 2021 [mm]")
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
