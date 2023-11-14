function amc_nut_response(sim, valid;
        nspecies = 50,
        max_AMC_nut_reduction,
        path = nothing)

    ######## input prep
    mp = valid.model_parameters()
    inf_p = (; zip(Symbol.(mp.names), mp.best)...)
    inf_p = @set inf_p.max_AMC_nut_reduction = max_AMC_nut_reduction
    input_obj = valid.validation_input(;
        plotID = "HEG01", nspecies,

        npatches = 1, nutheterog = 0.0)
    calc = sim.preallocate_vectors(; input_obj)
    container = sim.initialization(; input_obj, inf_p, calc)
    ########

    xs = 0:0.01:1
    ymat = fill(0.0, length(xs), nspecies)

    for (i, x) in enumerate(xs)
        container.calc.nutrients_splitted .= x
        sim.amc_nut_reduction!(; container)
        ymat[i, :] .= container.calc.amc_nut
    end

    idx = sortperm(container.traits.amc)
    Ks = container.funresponse.amc_nut_upper[idx]
    x0s = container.funresponse.amc_nut_midpoint[idx]
    A = container.p.amc_nut_lower
    amc = container.traits.amc[idx]
    ymat = ymat[:, idx]

    fig = Figure(resolution = (900, 500))
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

function rsa_above_water_response(sim, valid; nspecies = 25,
        max_rsa_above_water_reduction,
        path = nothing)

    #####################
    mp = valid.model_parameters()
    inf_p = (; zip(Symbol.(mp.names), mp.best)...)
    inf_p = @set inf_p.max_rsa_above_water_reduction = max_rsa_above_water_reduction
    input_obj = valid.validation_input(;
        plotID = "HEG01", nspecies,
        npatches = 1, nutheterog = 0.0)
    calc = sim.preallocate_vectors(; input_obj)
    container = sim.initialization(; input_obj, inf_p, calc)
    #####################

    xs = 0:0.01:1
    ymat = fill(0.0, length(xs), nspecies)

    for (i, x) in enumerate(xs)
        container.calc.water_splitted .= x
        sim.rsa_above_water_reduction!(; container)
        ymat[i, :] .= container.calc.rsa_above_water
    end

    idx = sortperm(container.traits.rsa_above)
    Ks = container.funresponse.rsa_above_water_upper[idx]
    x0s = container.funresponse.rsa_above_midpoint[idx]
    A = container.p.rsa_above_water_lower
    rsa_above = container.traits.rsa_above[idx]
    ymat = ymat[:, idx]

    fig = Figure(resolution = (900, 500))
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

function rsa_above_nut_response(sim, valid;
        nspecies = 25,
        max_rsa_above_nut_reduction,
        path = nothing)

    #####################
    mp = valid.model_parameters()
    inf_p = (; zip(Symbol.(mp.names), mp.best)...)
    inf_p = @set inf_p.max_rsa_above_nut_reduction = max_rsa_above_nut_reduction
    input_obj = valid.validation_input(;
        plotID = "HEG01", nspecies,
        npatches = 1, nutheterog = 0.0)
    calc = sim.preallocate_vectors(; input_obj)
    container = sim.initialization(; input_obj, inf_p, calc)
    #####################

    xs = 0:0.01:1
    ymat = fill(0.0, length(xs), nspecies)

    for (i, x) in enumerate(xs)
        container.calc.nutrients_splitted .= x

        sim.rsa_above_nut_reduction!(; container)
        ymat[i, :] .= container.calc.rsa_above_nut
    end

    ##################
    idx = sortperm(container.traits.rsa_above)
    Ks = container.funresponse.rsa_above_nut_upper[idx]
    x0s = container.funresponse.rsa_above_midpoint[idx]
    A = container.p.rsa_above_nut_lower
    rsa_above = container.traits.rsa_above[idx]
    ymat = ymat[:, idx]
    ##################

    fig = Figure(resolution = (900, 500))
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

function sla_water_response(sim, valid;
        nspecies = 25,
        max_SLA_water_reduction,
        path = nothing)

    #####################
    mp = valid.model_parameters()
    inf_p = (; zip(Symbol.(mp.names), mp.best)...)
    inf_p = @set inf_p.max_SLA_water_reduction = max_SLA_water_reduction
    input_obj = valid.validation_input(;
        plotID = "HEG01", nspecies,
        npatches = 1, nutheterog = 0.0)
    calc = sim.preallocate_vectors(; input_obj)
    container = sim.initialization(; input_obj, inf_p, calc)
    #####################

    xs = 0:0.01:1
    ymat = fill(0.0, length(xs), nspecies)

    for (i, x) in enumerate(xs)
        container.calc.water_splitted .= x
        sim.sla_water_reduction!(; container)
        ymat[i, :] .= container.calc.sla_water
    end

    ##################
    idx = sortperm(container.traits.sla)
    x0s = container.funresponse.sla_water_midpoint[idx]
    sla = container.traits.sla[idx]
    ymat = ymat[:, idx]
    ##################

    fig = Figure(resolution = (900, 400))
    Axis(fig[1, 1];
        xlabel = "Scaled water availability",
        ylabel = "Growth reduction factor\n← no growth, less reduction →",
        title = "Influence of the specific leaf area")

    for i in eachindex(x0s)
        lines!(xs, ymat[:, i];
            color = i,
            colorrange = (1, nspecies))

        ##### midpoint
        x0_y = 1 - max_SLA_water_reduction / 2
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
