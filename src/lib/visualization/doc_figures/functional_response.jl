function amc_nut_response(; δ_amc, path = nothing)
    nspecies, container = create_container(; )
    container = @set container.p.δ_amc = δ_amc
    container.calc.biomass_density_factor .= 1.0

    xs = 0:0.01:1
    ymat = fill(0.0, length(xs), nspecies)

    for (i, x) in enumerate(xs)
        nutrient_reduction!(; container, nutrients = x)
        ymat[i, :] .= container.calc.amc_nut
    end

    idx = sortperm(container.traits.amc)
    Ks = container.transfer_function.K_amc[idx]
    x0s = container.transfer_function.H_amc[idx]
    A = 1 - container.p.δ_amc
    amc = container.traits.amc[idx]
    ymat = ymat[:, idx]

    fig = Figure(size = (900, 500))
    Axis(fig[1:2, 1];
        xlabel = "Nutrient index",
        ylabel = "Growth reduction factor\n← no growth, less reduction →",
        title = "Influence of the mycorrhizal colonisation")

    for i in Base.OneTo(nspecies)
        lines!(xs, ymat[:, i],
            color = i,
            colorrange = (1, nspecies))

        ##### right upper bound
        scatter!([1], [Ks[i]];
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
        ylabel = "Right upper bound",
        xticklabelsvisible = false)
    for i in Base.OneTo(nspecies)
        scatter!(amc[i], Ks[i];
            marker = :ltriangle,
            color = i,
            colorrange = (1, nspecies))
    end
    ylims!(nothing, 1.01)

    Axis(fig[2, 2];
        xlabel = "Mycorrhizal colonisation",
        ylabel = "Nutrient index\nat midpoint")
    for i in Base.OneTo(nspecies)
        scatter!(amc[i], x0s[i];
            marker = :x,
            color = i,
            colorrange = (1, nspecies))
    end

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end

function W_rsa_response(; δ_wrsa = 0.5, path = nothing)
    nspecies, container = create_container(; )
    setfield!(container.p, :δ_wrsa, δ_wrsa)

    xs = 0:0.01:1
    ymat = fill(0.0, length(xs), nspecies)

    PET = container.p.α_PET
    WHC = 1u"mm"
    PWP = 0u"mm"
    container.calc.biomass_density_factor .= 1.0

    for (i, x) in enumerate(xs)
        W = x * u"mm"
        water_reduction!(; container, W, PET, PWP, WHC)
        ymat[i, :] .= container.calc.W_rsa
    end

    idx = sortperm(container.traits.rsa_above)
    Ks = container.transfer_function.K_wrsa[idx]
    x0s = container.transfer_function.H_rsa[idx]
    A = 1 - container.p.δ_wrsa
    rsa_above = container.traits.rsa_above[idx]
    ymat = ymat[:, idx]

    fig = Figure(size = (900, 500))
    Axis(fig[1:2, 1],
        xlabel = "Scaled water availability",
        ylabel = "Growth reduction factor\n← no growth, less reduction →")

    for (i, (K, x0)) in enumerate(zip(Ks, x0s))
        lines!(xs, ymat[:, i];
            color = i,
            colorrange = (1, nspecies))

        ##### right upper bound
        scatter!([1], [K];
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
        ylabel = "Right upper bound")
    scatter!(ustrip.(rsa_above), Ks;
        marker = :ltriangle,
        color = 1:nspecies,
        colorrange = (1, nspecies))
    ylims!(nothing, 1.01)

    Axis(fig[2, 2];
        xlabel = "Root surface area /\nabove ground biomass [m² g⁻¹]",
        ylabel = "Scaled water availability\nat midpoint")
    scatter!(ustrip.(rsa_above), x0s;
        marker = :x,
        color = 1:nspecies,
        colorrange = (1, nspecies))

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

function rsa_above_nut_response(; δ_nrsa, path = nothing)
    nspecies, container = create_container(; )
    setfield!(container.p, :δ_nrsa, δ_nrsa)
    container.calc.biomass_density_factor .= 1.0

    xs = 0:0.01:1
    ymat = fill(0.0, length(xs), nspecies)

    for (i, x) in enumerate(xs)
        nutrient_reduction!(; container, nutrients = x)
        ymat[i, :] .= container.calc.rsa_above_nut
    end

    ##################
    idx = sortperm(container.traits.rsa_above)
    Ks = container.transfer_function.K_nrsa[idx]
    x0s = container.transfer_function.H_rsa[idx]
    A = 1 - container.p.δ_nrsa
    rsa_above = container.traits.rsa_above[idx]
    ymat = ymat[:, idx]
    ##################

    fig = Figure(size = (900, 500))
    Axis(fig[1:2, 1],
        xlabel = "Nutrient index",
        ylabel = "Growth reduction factor\n← no growth, less reduction →")

    for (i, (K, x0)) in enumerate(zip(Ks, x0s))
        lines!(xs, ymat[:, i];
            color = i,
            colorrange = (1, nspecies))

        ##### right upper bound
        scatter!([1], [K];
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
        ylabel = "Right upper bound")
    scatter!(ustrip.(rsa_above), Ks;
        marker = :ltriangle,
        color = 1:nspecies,
        colorrange = (1, nspecies))
    ylims!(nothing, 1.01)

    Axis(fig[2, 2];
        xlabel = "Root surface area /\nabove ground biomass [m² g⁻¹]",
        ylabel = "Nutrient index\nat midpoint")
    scatter!(ustrip.(rsa_above), x0s;
        marker = :x,
        color = 1:nspecies,
        colorrange = (1, nspecies))

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

function W_sla_response(;δ_sla = 0.5, path = nothing)
    nspecies, container = create_container(; )
    container = @set container.p.δ_sla = δ_sla

    xs = 0:0.01:1
    ymat = fill(0.0, length(xs), nspecies)

    PET = container.p.α_PET
    WHC = 1u"mm"
    PWP = 0u"mm"
    container.calc.biomass_density_factor .= 1.0

    for (i, x) in enumerate(xs)
        W = x * u"mm"
        water_reduction!(; container, W, PET, PWP, WHC)
        ymat[i, :] .= container.calc.W_sla
    end

    ##################
    idx = sortperm(container.traits.sla)
    x0s = container.transfer_function.H_sla[idx]
    sla = container.traits.sla[idx]
    ymat = ymat[:, idx]
    ##################

    fig = Figure(size = (900, 400))
    Axis(fig[1, 1];
        xlabel = "Plant available water (Wp)",
        ylabel = "Growth reduction factor\n← no growth, less reduction →",
        title = "")

    for i in eachindex(x0s)
        lines!(xs, ymat[:, i];
            color = i,
            colorrange = (1, nspecies))

        ##### midpoint
        x0_y = 1 - δ_sla / 2
        scatter!([x0s[i]], [x0_y];
            marker = :x,
            color = i,
            colorrange = (1, nspecies))
    end

    ylims!(-0.1, 1.1)
    xlims!(-0.02, 1.02)

    Axis(fig[1, 2];
        xlabel = "Specific leaf area [m² g⁻¹]",
        ylabel = "Scaled water availability\nat midpoint")
    scatter!(ustrip.(sla), x0s;
        marker = :x,
        color = 1:nspecies,
        colorrange = (1, nspecies))

    if !isnothing(path)
        save(path, fig)
    else
        display(fig)
    end

    return nothing
end
