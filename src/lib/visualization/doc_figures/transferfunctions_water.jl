function plot_W_rsa(; δ_wrsa = 0.5, path = nothing)
    nspecies, container = create_container(; param = (; δ_wrsa))
    xs = LinRange(0, 1.5, 20)
    ymat = fill(0.0, length(xs), nspecies)

    PET = container.p.α_PET
    WHC = 1u"mm"
    PWP = 0u"mm"
    W = 1 * u"mm"

    for (i, x) in enumerate(xs)
        container.calc.biomass_density_factor .= x
        water_reduction!(; container, W, PET, PWP, WHC)
        ymat[i, :] .= container.calc.W_rsa
    end

    idx = sortperm(container.traits.rsa)
    x0s = container.transfer_function.A_wrsa[idx]
    A = 1 - container.p.δ_wrsa
    rsa = container.traits.rsa[idx]
    ymat = ymat[:, idx]
    colorrange = (minimum(x0s), maximum(x0s))

    fig = Figure(size = (1000, 500))
    Axis(fig[1, 1],
        xlabel = "Plant available water (W_p)",
        ylabel = "Growth reduction factor (W_rsa)\n← stronger reduction, less reduction →")
    hlines!([1-δ_wrsa]; color = :black)
    text!(1.2, 1-δ_wrsa + 0.02; text = "1 - δ_wrsa")
    for (i, x0) in enumerate(x0s)
        lines!(xs, ymat[:, i];
            color = x0s[i],
            colorrange)

        ##### midpoint
        x0_y = (1 - A) / 2 + A
        scatter!([x0], [x0_y];
            marker = :x,
            color = x0s[i],
            colorrange)
    end
    ylims!(-0.1, 1.1)

    Axis(fig[1, 2];
        xlabel = "Root surface area /\nabove ground biomass [m² g⁻¹]",
        ylabel = "Scaled water availability\nat midpoint (A_wrsa)")
    scatter!(ustrip.(rsa), x0s;
        marker = :x,
        color = x0s,
        colorrange)
    hlines!([container.p.η_min_wrsa, container.p.η_max_wrsa]; color = :black)
    text!([0.1, 0.22], [container.p.η_min_wrsa, container.p.η_max_wrsa] .+ 0.02;
            text = ["η_min_wrsa", "η_max_wrsa"])
    vlines!(ustrip(container.p.ϕ_rsa); color = :black, linestyle = :dash)
    text!(ustrip(container.p.ϕ_rsa) + 0.01,
            (container.p.η_max_wrsa - container.p.η_min_wrsa) / 2;
            text = "ϕ_rsa")
    ylims!(nothing, container.p.η_max_wrsa + 0.1)

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


function plot_W_sla(;δ_sla = 0.5, path = nothing)
    nspecies, container = create_container(; param = (; δ_sla))
    xs = LinRange(0, 1.5, 20)
    ymat = fill(0.0, length(xs), nspecies)

    PET = container.p.α_PET
    WHC = 1u"mm"
    PWP = 0u"mm"
    W = 1u"mm"

    for (i, x) in enumerate(xs)
        container.calc.biomass_density_factor .= x
        water_reduction!(; container, W, PET, PWP, WHC)
        ymat[i, :] .= container.calc.W_sla
    end

    ##################
    idx = sortperm(container.traits.sla)
    x0s = container.transfer_function.A_sla[idx]
    sla = container.traits.sla[idx]
    ymat = ymat[:, idx]
    colorrange = (minimum(x0s), maximum(x0s))
    ##################

    fig = Figure(size = (900, 400))
    Axis(fig[1, 1];
        xlabel = "Plant available water (W_p)",
        ylabel = "Growth reduction factor (W_sla)\n← stronger reduction, less reduction →",
        title = "")
    hlines!([1-δ_sla]; color = :black)
    text!(1.2, 1-δ_sla + 0.02; text = "1 - δ_sla")

    for i in eachindex(x0s)
        lines!(xs, ymat[:, i];
            color = x0s[i],
            colorrange)

        ##### midpoint
        x0_y = 1 - δ_sla / 2
        scatter!([x0s[i]], [x0_y];
            marker = :x,
            color = x0s[i],
            colorrange)
    end
    ylims!(-0.1, 1.1)
    xlims!(-0.02, nothing)

    Axis(fig[1, 2];
        xlabel = "Specific leaf area [m² g⁻¹]",
        ylabel = "Scaled water availability\nat midpoint (A_sla)")
    scatter!(ustrip.(sla), x0s;
        marker = :x,
        color = x0s,
        colorrange)
    hlines!([container.p.η_min_sla, container.p.η_max_sla]; color = :black)
    text!([0.0, 0.0], [container.p.η_min_sla, container.p.η_max_sla] .+ 0.02;
            text = ["η_min_sla", "η_max_sla"])
    vlines!(ustrip(container.p.ϕ_sla); color = :black, linestyle = :dash)
    text!(ustrip(container.p.ϕ_sla),
          container.p.η_max_sla - (container.p.η_max_sla - container.p.η_min_sla) / 2;
          text = "ϕ_sla")
    ylims!(nothing, container.p.η_max_sla + 0.1)
    if !isnothing(path)
        save(path, fig)
    else
        display(fig)
    end

    return nothing
end
