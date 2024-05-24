@doc raw"""
```math
\begin{align}
\rho &= \left(\frac{LNCM}{LNCM_{cwm]}}\right) ^ {\text{β_PAL_lnc}} \\
μₘₐₓ &= κ \cdot \text{LD} \\
h &= \frac{1}{μₘₐₓ} \\
a &= \frac{1}{\text{α_GRZ}^2 \cdot h} \\
\text{totgraz} &= \frac{a \cdot (\sum \text{biomass})^2}
                    {1 + a\cdot h\cdot (\sum \text{biomass})^2} \\
\text{share} &= \frac{
    \rho \cdot \text{biomass}}
    {\sum \left[ \rho \cdot \text{biomass} \right]} \\
\text{graz} &= \text{share} \cdot \text{totgraz}
\end{align}
```

- `LD` daily livestock density [livestock units ha⁻¹]
- `κ` daily consumption of one livestock unit [kg], follows [Gillet2008](@cite)
- `ρ` palatability,
  dependent on nitrogen per leaf mass (LNCM) [-]
- `α_GRZ` is the half-saturation constant [kg ha⁻¹]
- equation partly based on [Moulin2021](@cite)

Influence of grazing (livestock density = 2), all plant species have
an equal amount of biomass (total biomass / 3)
and a leaf nitrogen content of 15, 30 and 40 mg/g:

- `β_PAL_lnc` = 1.5
![](../img/grazing_1_5.png)

- `β_PAL_lnc` = 5
![](../img/grazing_5.png)

Influence of `α_GRZ`:
![](../img/α_GRZ.svg)
"""
function grazing!(; container, LD)
    @unpack lnc = container.traits
    @unpack α_GRZ, β_PAL_lnc, κ = container.p
    @unpack defoliation, grazed_share, relative_lnc, ρ, grazed, actual_height,
            height_ρ_biomass, above_biomass = container.calc

    #################################### total grazed biomass
    sum_biomass = sum(above_biomass)
    biomass_exp = sum_biomass * sum_biomass
    total_grazed = κ * LD * biomass_exp / (α_GRZ * α_GRZ + biomass_exp)

    #################################### share of grazed biomass per species
    ## Palatability ρ
    relative_lnc .= lnc .* above_biomass ./ sum_biomass
    cwm_lnc = sum(relative_lnc)
    ρ .= (lnc ./ cwm_lnc) .^ β_PAL_lnc

    @. height_ρ_biomass = actual_height * ρ * above_biomass
    grazed_share .= height_ρ_biomass ./ sum(height_ρ_biomass)

    #################################### add grazed biomass to defoliation
    @. grazed = grazed_share * total_grazed
    defoliation .+= grazed

    return nothing
end

function plot_grazing(; α_GRZ = nothing, β_PAL_lnc = nothing, path = nothing)
    nspecies, container = create_container_for_plotting()

    if !isnothing(α_GRZ)
        container.p.α_GRZ = α_GRZ
    end

    if !isnothing(β_PAL_lnc)
        container.p.β_PAL_lnc = β_PAL_lnc
    end

    nbiomass = 80
    LD = 2u"ha ^ -1"
    biomass_vec = LinRange(0, 500, nbiomass)u"kg / ha"
    grazing_mat = Array{Float64}(undef, nspecies, nbiomass)

    for (i, biomass) in enumerate(biomass_vec)
        container.calc.defoliation .= 0.0u"kg / ha"
        grazing!(; t = 1, x = 1, y = 1, container, LD,
                     biomass = repeat([biomass], nspecies))
        grazing_mat[:, i] = ustrip.(container.calc.defoliation)
    end

    idx = sortperm(container.traits.lnc)
    lnc = ustrip.(container.traits.lnc)[idx]
    grazing_mat = grazing_mat[idx, :]
    colorrange = (minimum(lnc), maximum(lnc))

    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1],
        xlabel = "Biomass per species [kg ha⁻¹]",
        ylabel = "Grazed biomass per species (graz)\n[kg ha⁻¹]",
        title = "")

    for i in 1:nspecies
        lines!(ustrip.(biomass_vec), grazing_mat[i, :];
            color = lnc[i],
            colorrange,
            linewidth = 3)
    end

    Colorbar(fig[1, 2]; colorrange, colormap = :viridis,
        label = "Leaf nitrogen content [mg g⁻¹]")

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end

function plot_α_GRZ(; path = nothing)
    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1],
        xlabel = "Total biomass [green dry mass kg ha⁻¹]",
        ylabel = "Grazed biomass (totgraz)\n[green dry mass kg ha⁻¹]",
        title = "")

    for α_GRZ in [10, 50, 150, 200, 750, 1500, 2000]
        x = LinRange(0, 3000, 120)

        LD = 2
        κ = 22
        k_exp = 2
        μₘₐₓ = κ * LD
        h = 1 / μₘₐₓ
        a = 1 / (α_GRZ^k_exp * h)
        y = @. a * x^k_exp / (1^k_exp + a * h * x^k_exp)

        lines!(x, y, label = "$α_GRZ",
            linewidth = 3)
    end

    axislegend("α_GRZ";
        framevisible = true, position = :rb)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end
end
