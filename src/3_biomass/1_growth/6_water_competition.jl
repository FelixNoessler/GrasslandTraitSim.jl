"""
Initialisation of the transfer functions that link the traits to
the response to water and nutrient stress.
"""
function init_water_transfer_functions!(; input_obj, prealloc, p)
    @unpack included = input_obj.simp
    if included.water_growth_reduction
        @unpack δ_sla, δ_wrsa, ϕ_rsa, ϕ_sla, η_min_sla, η_max_sla,
                β_η_wrsa, β_η_sla, η_max_wrsa, η_min_wrsa = p
        @unpack srsa, sla, abp, lbp = prealloc.traits
        @unpack A_sla, A_wrsa = prealloc.transfer_function

        ##### Specific leaf area
        @. A_sla = (η_min_sla + (η_max_sla - η_min_sla) / (1 + exp(-β_η_sla * (lbp * sla - ϕ_sla)))) # TODO

        #### Root surface area per above ground biomass
        @. A_wrsa =  (η_max_wrsa + (η_min_wrsa - η_max_wrsa) /
            (1 + exp(-β_η_wrsa * ((1 - abp) * srsa - ϕ_rsa))))  # TODO add to documentation and manuscript
    end

    return nothing
end

@doc raw"""
Reduction of growth based on the plant available water
and the traits specific leaf area and root surface area
per belowground biomass.

Reduction of growth due to stronger water stress for plants with
higher specific leaf area (`sla`):

- the strength of the reduction is modified by the parameter `δ_sla`

`δ_sla` equals 1:
![](../img/plot_W_sla.svg)

`δ_sla` equals 0.5:
![](../img/W_sla_response_0_5.svg)

Reduction of growth due to stronger water stress for plants with
lower specific root surface area per above ground biomass (`srsa`).

- the strength of the reduction is modified by the parameter `δ_wrsa`

`δ_wrsa` equals 1:
![Graphical overview of the functional response](../img/plot_W_srsa.png)

`δ_wrsa` equals 0.5:
# ![Graphical overview of the functional response](../img/W_rsa_response_0_5.png)
"""
function water_reduction!(; container, W, PWP, WHC)
    @unpack included = container.simp
    @unpack Waterred = container.calc
    if !included.water_growth_reduction
        @info "No water reduction!" maxlog=1
        @. Waterred = 1.0
        return nothing
    end

    Wsc = W > WHC ? 1.0 : W > PWP ? (W - PWP) / (WHC - PWP) : 0.0

    @unpack W_sla, W_rsa = container.calc
    @unpack δ_sla, δ_wrsa, β_sla, β_wrsa = container.p
    @unpack A_wrsa, A_sla = container.transfer_function

    if included.sla_water_growth_reducer
        @. W_sla = 1 - δ_sla + δ_sla / (1 + exp(-β_sla * (Wsc - A_sla)))
    else
        W_sla .= 1.0
    end

    if included.rsa_water_growth_reducer
        @. W_rsa = 1 - δ_wrsa + δ_wrsa / (1 + exp(-β_wrsa * (Wsc - A_wrsa)))
    else
        W_rsa .= 1.0
    end

    @. Waterred = W_sla * W_rsa

    return nothing
end

function plot_W_srsa(; δ_wrsa = 0.5, path = nothing)
    nspecies, container = create_container_for_plotting(; param = (; δ_wrsa))
    xs = LinRange(0, 1.0, 20)
    ymat = fill(0.0, length(xs), nspecies)

    WHC = 1u"mm"
    PWP = 0u"mm"
    W = 1 * u"mm"

    for (i, x) in enumerate(xs)
        water_reduction!(; container, W = x * u"mm", PWP, WHC)
        ymat[i, :] .= container.calc.W_rsa
    end

    idx = sortperm(container.traits.srsa)
    x0s = container.transfer_function.A_wrsa[idx]
    A = 1 - container.p.δ_wrsa
    srsa = ustrip.(container.traits.srsa[idx])
    abp = container.traits.abp[idx]
    ymat = ymat[:, idx]
    colorrange = (minimum(srsa), maximum(srsa))

    fig = Figure(size = (1000, 500))
    Axis(fig[1, 1],
        xlabel = "Plant available water (W_sc)",
        ylabel = "Growth reduction factor (W_rsa)\n← stronger reduction, less reduction →")
    hlines!([1-δ_wrsa]; color = :black)
    text!(0.75, 1-δ_wrsa + 0.02; text = "1 - δ_wrsa")
    for (i, x0) in enumerate(x0s)
        lines!(xs, ymat[:, i];
            color = srsa[i],
            colorrange)

        ##### midpoint
        x0_y = (1 - A) / 2 + A
        scatter!([x0], [x0_y];
            marker = :x,
            color = srsa[i],
            colorrange)
    end
    ylims!(-0.1, 1.1)

    Axis(fig[1, 2];
        xlabel = "root surface area per total biomass [m² g⁻¹]\n = belowground biomass fraction ⋅\nroot surface area per belowground biomass [m² g⁻¹]",
        ylabel = "Scaled water availability\nat midpoint (A_wrsa)")
    scatter!((1 .- abp) .* srsa, x0s;
        marker = :x,
        color = srsa,
        colorrange)
    hlines!([container.p.η_min_wrsa, container.p.η_max_wrsa]; color = :black)
    text!([0.04, 0.04], [container.p.η_min_wrsa, container.p.η_max_wrsa] .+ 0.02;
            text = ["η_min_wrsa", "η_max_wrsa"])
    vlines!(ustrip(container.p.ϕ_rsa); color = :black, linestyle = :dash)
    text!(ustrip(container.p.ϕ_rsa) + 0.001,
            (container.p.η_max_wrsa - container.p.η_min_wrsa) * 4/5;
            text = "ϕ_rsa")
    ylims!(nothing, container.p.η_max_wrsa + 0.1)

    Label(fig[0, 1:2], "Influence of the root surface area";
        halign = :left,
        font = :bold)
    Colorbar(fig[1, 3]; colorrange, label = "Root surface area per belowground biomass [m² g⁻¹]")


    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end


function plot_W_sla(;δ_sla = 0.5, path = nothing)
    nspecies, container = create_container_for_plotting(; param = (; δ_sla))
    xs = LinRange(0, 1, 20)
    ymat = fill(0.0, length(xs), nspecies)
    WHC = 1u"mm"
    PWP = 0u"mm"

    for (i, x) in enumerate(xs)
        W = x * u"mm"
        water_reduction!(; container, W, PWP, WHC)
        ymat[i, :] .= container.calc.W_sla
    end

    ##################
    idx = sortperm(container.traits.sla)
    x0s = container.transfer_function.A_sla[idx]
    sla = ustrip.(container.traits.sla[idx])
    lbp = container.traits.lbp[idx]
    ymat = ymat[:, idx]
    colorrange = (minimum(sla), maximum(sla))
    ##################

    fig = Figure(size = (900, 400))
    Axis(fig[1, 1];
        xlabel = "Plant available water (W_sc)",
        ylabel = "Growth reduction factor (W_sla)\n← stronger reduction, less reduction →",
        title = "")
    hlines!([1-δ_sla]; color = :black)
    text!(0.8, 1-δ_sla + 0.02; text = "1 - δ_sla")

    for i in eachindex(x0s)
        lines!(xs, ymat[:, i];
            color = sla[i],
            colorrange)

        ##### midpoint
        x0_y = 1 - δ_sla / 2
        scatter!([x0s[i]], [x0_y];
            marker = :x,
            color = sla[i],
            colorrange)
    end
    ylims!(-0.1, 1.1)
    xlims!(-0.02, nothing)

    Axis(fig[1, 2];
        xlabel = "leaf biomass fraction ⋅ specific leaf area [m² g⁻¹]",
        ylabel = "Scaled water availability\nat midpoint (A_sla)")
    scatter!(lbp .* sla, x0s;
        marker = :x,
        color = sla,
        colorrange)
    hlines!([container.p.η_min_sla, container.p.η_max_sla]; color = :black)
    text!([0.01, 0.01], [container.p.η_min_sla, container.p.η_max_sla] .+ 0.02;
            text = ["η_min_sla", "η_max_sla"])
    vlines!(ustrip(container.p.ϕ_sla); color = :black, linestyle = :dash)
    text!(ustrip(container.p.ϕ_sla),
          container.p.η_max_sla - (container.p.η_max_sla - container.p.η_min_sla) / 6;
          text = " ϕ_sla")
    ylims!(nothing, container.p.η_max_sla + 0.2)
    Colorbar(fig[1, 3]; colorrange, label = "Specific leaf area [m² g⁻¹]")

    if !isnothing(path)
        save(path, fig)
    else
        display(fig)
    end

    return nothing
end
