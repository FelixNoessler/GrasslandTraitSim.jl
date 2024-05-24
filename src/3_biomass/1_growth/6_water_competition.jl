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
        @. A_sla = (η_min_sla + (η_max_sla - η_min_sla) / (1 + exp(-β_η_sla * (sla - 2.0 * lbp * ϕ_sla)))) # TODO

        #### Root surface area per above ground biomass
        @. A_wrsa =  (η_max_wrsa + (η_min_wrsa - η_max_wrsa) /
            (1 + exp(-β_η_wrsa * (srsa - 1.6 * abp * ϕ_rsa))))  # TODO add to documentation and manuscript
    end

    return nothing
end

@doc raw"""
Reduction of growth based on the plant available water
and the traits specific leaf area and root surface area
per aboveground biomass.


Derives the plant available water.

The plant availabe water is dependent on the soil water content,
the water holding capacity (`WHC`), the permanent
wilting point (`PWP`), the potential evaporation (`PET`) and a
belowground competition factor:

```math
\begin{align*}
    W_{sc, txy} &= \frac{W_{txy} - PWP_{xy}}{WHC_{xy}-PWP_{xy}} \\
    W_{p, txys} &= D_{txys} \cdot 1 \bigg/ \left(1 + \frac{\text{exp}\left(\beta_{pet} \cdot \left(PET_{txy} - \alpha_{pet} \right) \right)}{ 1 / (1-W_{sc, txy}) - 1}\right)
\end{align*}
```

- ``W_{sc, txy}`` is the scaled soil water content ``\in [0, 1]`` [-]
- ``W_{txy}`` is the soil water content [mm]
- ``PWP_{xy}`` is the permanent wilting point [mm]
- ``WHC_{xy}`` is the water holding capacity [mm]
- ``W_{p, txys}`` is the plant available water [-]
- ``D_{txys}`` is the belowground competition factor [-], in the programming code
  is is called `biomass_density_factor`
- ``PET_{txy}`` is the potential evapotranspiration [mm]
- ``β_{pet}`` is a parameter that defines the steepness of the reduction function
- ``α_{pet}`` is a parameter that defines the midpoint of the reduction function

Derive the water stress based on the specific leaf area and the
plant availabe water.

It is assumed, that plants with a higher specific leaf area have a higher
transpiration per biomass and are therefore more sensitive to water stress.
A transfer function is used to link the specific leaf area to the water
stress reduction.

**Initialization:**

The specicies-specifc parameter `A_sla` is initialized
and later used in the reduction function.

```math
\text{A_sla} = \text{min_sla_mid} +
    \frac{\text{max_sla_mid} - \text{min_sla_mid}}
    {1 + exp(-\text{β_sla_mid} \cdot (sla - \text{mid_sla}))}
```

- `sla` is the specific leaf area of the species [m² g⁻¹]
- `min_sla_mid` is the minimum of `A_sla` that
  can be reached with a very low specific leaf area [-]
- `max_sla_mid` is the maximum of `A_sla` that
  can be reached with a very high specific leaf area [-]
- `mid_sla` is a mean specific leaf area [m² g⁻¹]
- `β_sla_mid` is a parameter that defines the steepness
  of function that relate the `sla` to `A_sla`


**Reduction factor based on the plant availabe water:**
```math
\text{W_sla} = 1 - \text{δ_sla} +
    \frac{\text{δ_sla}}
    {1 + exp(-\text{k_sla} \cdot
        (\text{W_{sc}} - \text{A_sla}))}
```

- `W_sla` is the reduction factor for the growth based on the
  specific leaf area [-]
- `A_sla` is the value of the plant available water
  at which the reduction factor is in the middle between
  1 - `δ_sla` and 1 [-]
- `δ_sla` is the maximal reduction of the
  growth based on the specific leaf area
- `k_sla` is a parameter that defines the steepness of the reduction function

**Overview over the parameters:**

| Parameter                 | Type                      | Value          |
| ------------------------- | ------------------------- | -------------- |
| `min_sla_mid`             | fixed                     | -0.8 [-]       |
| `max_sla_mid`             | fixed                     | 0.8  [-]       |
| `mid_sla`                 | fixed                     | 0.025 [m² g⁻¹] |
| `β_sla_mid`               | fixed                     | 75 [g m⁻²]     |
| `k_sla`                   | fixed                     | 5 [-]          |
| `δ_sla` | calibrated                | -              |
| `A_sla`      | species-specific, derived | -              |


Reduction of growth due to stronger water stress for lower specific
root surface area per above ground biomass (`srsa`).

- the strength of the reduction is modified by the parameter `δ_wrsa`

`δ_wrsa` equals 1:
![Graphical overview of the functional response](../img/plot_W_srsa.svg)

`δ_wrsa` equals 0.5:
# ![Graphical overview of the functional response](../img/W_rsa_response_0_5.svg)
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
    xs = LinRange(0, 1.5, 20)
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
    srsa = container.traits.srsa[idx]
    ymat = ymat[:, idx]
    colorrange = (minimum(x0s), maximum(x0s))

    fig = Figure(size = (1000, 500))
    Axis(fig[1, 1],
        xlabel = "Plant available water (W_sc)",
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
        xlabel = "Root surface area per\nbelowground ground biomass [m² g⁻¹]",
        ylabel = "Scaled water availability\nat midpoint (A_wrsa)")
    scatter!(ustrip.(srsa), x0s;
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
    nspecies, container = create_container_for_plotting(; param = (; δ_sla))
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
        xlabel = "Plant available water (W_sc)",
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