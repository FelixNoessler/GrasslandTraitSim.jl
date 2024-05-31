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

- `β_PAL_lnc` = 1.5
![](../img/grazing_default.png)

- `β_PAL_lnc` = 5
![](../img/grazing_2.png)

Influence of `α_GRZ`:
![](../img/α_GRZ.png)
"""
function grazing!(; container, LD, above_biomass, actual_height)
    @unpack lnc = container.traits
    @unpack η_GRZ, β_PAL_lnc, κ = container.p
    @unpack defoliation, grazed_share, relative_lnc, ρ, grazed,
            height_ρ_biomass = container.calc

    #################################### total grazed biomass
    sum_biomass = sum(above_biomass)
    biomass_exp = sum_biomass * sum_biomass
    α_GRZ = κ * LD * η_GRZ
    total_grazed = κ * LD * biomass_exp / (α_GRZ * α_GRZ + biomass_exp)

    #################################### share of grazed biomass per species
    ## Palatability ρ
    relative_lnc .= lnc .* above_biomass ./ sum_biomass
    cwm_lnc = sum(relative_lnc)
    # ρ .= (lnc ./ cwm_lnc) .^ β_PAL_lnc
    @. ρ = 2.0 / (1.0 + exp(β_PAL_lnc * (cwm_lnc - lnc))) # TODO change documentation

    @. height_ρ_biomass = actual_height * ρ * above_biomass
    grazed_share .= height_ρ_biomass ./ sum(height_ρ_biomass)

    #################################### add grazed biomass to defoliation
    @. grazed = grazed_share * total_grazed
    defoliation .+= grazed

    return nothing
end

function plot_grazing(; α_GRZ = nothing, β_PAL_lnc = nothing, θ = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; θ)

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

    for (i, biomass_val) in enumerate(biomass_vec)
        container.calc.defoliation .= 0.0u"kg / ha"
        above_biomass = 1 ./ container.traits.abp .* biomass_val

        grazing!(; container, LD, above_biomass, actual_height = container.traits.height)
        grazing_mat[:, i] = ustrip.(container.calc.defoliation)
    end

    idx = sortperm(container.traits.lnc)
    lnc = ustrip.(container.traits.lnc)[idx]
    grazing_mat = grazing_mat[idx, :]
    colorrange = (minimum(lnc), maximum(lnc))

    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1],
        xlabel = "Aboveground biomass per species [kg ha⁻¹]",
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

function plot_α_GRZ(; θ = nothing, path = nothing)
    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1],
        xlabel = "Total biomass [green dry mass kg ha⁻¹]",
        ylabel = "Grazed biomass (totgraz)\n[green dry mass kg ha⁻¹]",
        title = "")

    for η_GRZ in [1, 5, 10, 20]
        x = LinRange(0, 3000, 120)

        LD = 2
        κ = 22

        α_GRZ = κ * LD * η_GRZ
        k_exp = 2
        y = @. κ * LD * x^k_exp / (α_GRZ^k_exp + x^k_exp)

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
