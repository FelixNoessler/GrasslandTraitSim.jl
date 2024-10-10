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
![](../img/η_GRZ.png)
"""
function grazing!(; container, LD, above_biomass, actual_height)
    @unpack lnc = container.traits
    @unpack η_GRZ, β_PAL_lnc, β_height_GRZ, κ = container.p
    @unpack defoliation, grazed_share, relative_lnc, ρ, relative_height, grazed,
            heightinfluence, height_ρ_biomass = container.calc

    min_height = 0.05u"m"
    height_proportion_feedible = max.(1 .- min_height ./ actual_height, 0)

    feedible_biomass = height_proportion_feedible .* above_biomass
    sum_feedible_biomass = sum(feedible_biomass)

    if iszero(sum_feedible_biomass)
        container.calc.com.fodder_supply = κ * LD
        @. grazed = 0.0u"kg/ha"
        defoliation .+= grazed
        return nothing
    end

    #################################### total grazed biomass
    biomass_squarred = sum_feedible_biomass * sum_feedible_biomass
    α_GRZ = κ * LD * η_GRZ
    total_grazed = κ * LD * biomass_squarred / (α_GRZ * α_GRZ + biomass_squarred)

    # biomass_squarred = sum_feedible_biomass * sum_feedible_biomass
    # α_GRZ = κ * η_GRZ / u"ha"
    # total_grazed = κ * LD * biomass_squarred / (α_GRZ * α_GRZ + biomass_squarred)

    # total_grazed = κ * LD
    container.calc.com.fodder_supply = κ * LD - total_grazed

    #################################### share of grazed biomass per species
    ## Palatability ρ
    relative_lnc .= lnc .* feedible_biomass ./ sum_feedible_biomass
    cwm_lnc = sum(relative_lnc)
    @. ρ = (lnc / cwm_lnc) ^ β_PAL_lnc

    ## Grazers feed more on tall plants
    relative_height .= actual_height .* feedible_biomass ./ sum_feedible_biomass
    cwm_height = sum(relative_height)
    @. heightinfluence = (actual_height / cwm_height) ^ β_height_GRZ

    @. height_ρ_biomass = heightinfluence * ρ * feedible_biomass
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

function plot_η_GRZ(; θ = nothing, path = nothing)
    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1],
        xlabel = "Total biomass [dry mass kg ha⁻¹]",
        ylabel = "Grazed biomass (totgraz)\n[dry mass kg ha⁻¹]",
        title = "")

    for η_GRZ in [1, 5, 10, 20]
        x = LinRange(0, 3000, 120)

        LD = 2
        κ = 22

        k_exp = 2
        y = @. LD * κ * x^k_exp / ((κ * η_GRZ)^k_exp + x^k_exp)

        lines!(x, y, label = "$(κ * η_GRZ)",
            linewidth = 3)
    end

    axislegend("η_GRZ"; framevisible = true, position = :rb)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end
end
