function plot_N_amc(; δ_amc = 0.5, path = nothing)
    nspecies, container = create_container(; param = (; δ_amc))
    container.calc.biomass_density_factor .= 1.0

    xs = LinRange(0.0, 1.5, 20)
    ymat = fill(0.0, length(xs), nspecies)

    for (i, x) in enumerate(xs)
        nutrient_reduction!(; container, nutrients = x)
        ymat[i, :] .= container.calc.N_amc
    end

    idx = sortperm(container.traits.amc)
    Ks = container.transfer_function.K_amc[idx]
    x0s = container.transfer_function.A_amc[idx]
    A = 1 - container.p.δ_amc
    amc = container.traits.amc[idx]
    ymat = ymat[:, idx]

    fig = Figure(size = (1000, 600))
    Axis(fig[1:2, 1];
        xlabel = "Nutrient index",
        ylabel = "Growth reduction factor (N_amc)\n← stronger reduction, less reduction →",
        title = "Influence of the mycorrhizal colonisation")
    hlines!([1-δ_amc]; color = :black)
    text!(1.2, 1-δ_amc + 0.02; text = "1 - δ_amc")
    for i in Base.OneTo(nspecies)
        lines!(xs, ymat[:, i],
            color = i,
            colorrange = (1, nspecies))

        ##### right upper bound
        scatter!([1.5], [Ks[i]];
            marker = :ltriangle,
            color = i,
            colorrange = (1, nspecies))

        ##### midpoint
        x0_y = (Ks[i] - A) / 2 + A
        scatter!([x0s[i]], [x0_y];
            marker = :x,
            color = i,
            colorrange = (1, nspecies))
    end
    ylims!(-0.05, 1.05)

    Axis(fig[1, 2];
        ylabel = "Right upper bound\n(K_amc)",
        xticklabelsvisible = false)
    for i in Base.OneTo(nspecies)
        scatter!(amc[i], Ks[i];
            marker = :ltriangle,
            color = i,
            colorrange = (1, nspecies))
    end
    ymin, ymax = 1-container.p.δ_amc*container.p.κ_red_amc, 1
    hlines!([ymin, ymax]; color = :black)
    text!([0.0, 0.0], [1 - container.p.δ_amc * container.p.κ_red_amc, 1] .+ 0.02;
          text = ["1 - δ_amc ⋅ κ_red_amc", "1"])
    vlines!(container.p.ϕ_amc; color = :black, linestyle = :dash)
    text!(container.p.ϕ_amc + 0.01, 1-(ymax-ymin)/ 2; text = "ϕ_amc")
    ylims!(0.0, 1.15)

    Axis(fig[2, 2];
        xlabel = "Mycorrhizal colonization (AMC)",
        ylabel = "Nutrient index\nat midpoint (A_amc)")
    for i in Base.OneTo(nspecies)
        scatter!(amc[i], x0s[i];
            marker = :x,
            color = i,
            colorrange = (1, nspecies))
    end
    hlines!([container.p.η_min_amc, container.p.η_max_amc]; color = :black)
    text!([0.0, 0.0], [container.p.η_min_amc, container.p.η_max_amc] .+ 0.02;
          text = ["η_min_amc", "η_max_amc"])
    vlines!(container.p.ϕ_amc; color = :black, linestyle = :dash)
    text!(container.p.ϕ_amc + 0.01,
          (container.p.η_max_amc - container.p.η_min_amc) / 2;
          text = "ϕ_amc")
    ylims!(nothing, container.p.η_max_amc + 0.1)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end



function plot_N_rsa(; δ_nrsa = 0.8, path = nothing)
    nspecies, container = create_container(; param = (; δ_nrsa))
    container.calc.biomass_density_factor .= 1.0

    xs = LinRange(0, 1.5, 20)
    ymat = fill(0.0, length(xs), nspecies)

    for (i, x) in enumerate(xs)
        nutrient_reduction!(; container, nutrients = x)
        ymat[i, :] .= container.calc.N_rsa
    end

    ##################
    idx = sortperm(container.traits.rsa)
    Ks = container.transfer_function.K_nrsa[idx]
    x0s = container.transfer_function.A_nrsa[idx]
    A = 1 - container.p.δ_nrsa
    rsa = container.traits.rsa[idx]
    ymat = ymat[:, idx]
    ##################

    fig = Figure(size = (900, 500))
    Axis(fig[1:2, 1],
        xlabel = "Nutrient index",
        ylabel = "Growth reduction factor (N_rsa)\n← stronger reduction, less reduction →")
    hlines!([1-δ_nrsa]; color = :black)
    text!(1.2, 1-δ_nrsa + 0.02; text = "1 - δ_nrsa")
    for (i, (K, x0)) in enumerate(zip(Ks, x0s))
        lines!(xs, ymat[:, i];
            color = i,
            colorrange = (1, nspecies))

        ##### right upper bound
        scatter!([1.5], [K];
            marker = :ltriangle,
            color = i,
            colorrange = (1, nspecies))

        ##### midpoint
        x0_y = (K - A) / 2 + A
        scatter!([x0], [x0_y];
            marker = :x,
            color = i,
            colorrange = (1, nspecies))
    end
    ylims!(-0.1, 1.1)

    Axis(fig[1, 2];
        xticklabelsvisible = false,
        ylabel = "Right upper bound\n(K_nrsa)")
    scatter!(ustrip.(rsa), Ks;
        marker = :ltriangle,
        color = 1:nspecies,
        colorrange = (1, nspecies))
    ymin, ymax = 1-container.p.δ_nrsa*container.p.κ_red_nrsa, 1
    hlines!([ymin, ymax]; color = :black)
    text!([0.0, 0.0], [1 - container.p.δ_nrsa * container.p.κ_red_nrsa, 1] .+ 0.02;
          text = ["1 - δ_nrsa ⋅ κ_red_nrsa", "1"])
    vlines!(ustrip(container.p.ϕ_rsa); color = :black, linestyle = :dash)
    text!(ustrip(container.p.ϕ_rsa) + 0.01, 1-(ymax-ymin)/ 2; text = "ϕ_rsa")
    ylims!(0.0, 1.15)


    Axis(fig[2, 2];
        xlabel = "Root surface area /\nabove ground biomass [m² g⁻¹]",
        ylabel = "Nutrient index\nat midpoint (A_nrsa)")
    scatter!(ustrip.(rsa), x0s;
        marker = :x,
        color = 1:nspecies,
        colorrange = (1, nspecies))
    hlines!([container.p.η_min_nrsa, container.p.η_max_nrsa]; color = :black)
    text!([0.0, 0.0], [container.p.η_min_nrsa, container.p.η_max_nrsa] .+ 0.02;
            text = ["η_min_nrsa", "η_max_nrsa"])
    vlines!(ustrip(container.p.ϕ_rsa); color = :black, linestyle = :dash)
    text!(ustrip(container.p.ϕ_rsa) + 0.01,
            (container.p.η_max_nrsa - container.p.η_min_nrsa) / 2;
            text = "ϕ_rsa")
    ylims!(nothing, container.p.η_max_nrsa + 0.1)

    Label(fig[0, 1:2], "Influence of the root surface area / above ground biomass";
        halign = :left,
        font = :bold)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end