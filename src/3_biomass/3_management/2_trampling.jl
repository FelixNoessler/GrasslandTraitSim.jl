@doc raw"""
```math
\begin{align}
\text{trampled_proportion} &=
    \text{height} \cdot \text{LD} \cdot \text{β_TRM}  \\
\text{trampled_biomass} &=
    \min(\text{biomass} ⋅ \text{trampled_proportion},
        \text{biomass}) \\
\end{align}
```

It is assumed that tall plants (trait: `height`) are stronger affected by trampling.
A linear function is used to model the influence of trampling.


Maximal the whole biomass of a plant species is removed by trampling.

- `biomass` [$\frac{kg}{ha}$]
- `LD` daily livestock density [$\frac{\text{livestock units}}{ha}$]
- `β_TRM` [ha m⁻¹]
- height canopy height [$m$]

![Image of effect of biomass of plants on the trampling](../img/trampling_biomass.png)
![Image of effect of livestock density on trampling](../img/trampling_LD.png)
![](../img/trampling_biomass_individual.svg)
"""
function trampling!(; container, LD, biomass)
    @unpack height, abp = container.traits
    @unpack β_TRM_H, β_TRM, α_TRM, α_lowB, β_lowB = container.p
    @unpack lowbiomass_correction, trampled_share, above_biomass, abp_scaled,
            defoliation, height_scaled, trampled = container.calc
    @unpack included = container.simp

    #################################### Total trampled biomass
    @. above_biomass = abp * biomass
    sum_biomass = sum(above_biomass)
    biomass_exp = sum_biomass * sum_biomass
    total_trampled = LD * β_TRM * biomass_exp / (α_TRM * α_TRM + biomass_exp)

    #################################### Share of trampled biomass per species
    if included.lowbiomass_avoidance
        @. lowbiomass_correction =  1.0 / (1.0 + exp(-β_lowB * (above_biomass - α_lowB)))
    else
        lowbiomass_correction .= 1.0
    end

    abp_scaled .= abp ./ mean(abp)
    @. height_scaled = height / 0.5u"m"
    for i in eachindex(trampled_share)
        trampled_share[i] = abp_scaled[i] * height_scaled[i] ^ β_TRM_H *
            lowbiomass_correction[i] * above_biomass[i] / sum_biomass
    end

    #################################### Add trampled biomass to defoliation
    @. trampled = trampled_share * total_trampled
    defoliation .+= trampled

    return nothing
end

function plot_trampling_biomass(; β_TRM = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; )

    if !isnothing(β_TRM)
        container.p.β_TRM = β_TRM * u"ha / kg"
    end

    nbiomass = 50
    biomass = fill(0.0, nspecies)u"kg / ha"
    biomass_vals = LinRange(0.0, 500.0, nbiomass)u"kg / ha"
    LD = 2.0u"ha^-1"

    trampling_mat_height = Array{Quantity{Float64}}(undef, nspecies, nbiomass)

    for (i, b) in enumerate(biomass_vals)
        biomass .= b
        container.calc.defoliation .= 0.0u"kg / ha"
        trampling!(; container, LD, biomass)
        trampling_mat_height[:, i] = container.calc.defoliation
    end
    trampling_mat_height = trampling_mat_height ./ biomass

    idx = sortperm(container.traits.height)
    height = ustrip.(container.traits.height)[idx]
    trampling_mat_height = trampling_mat_height[idx, :]

    colorrange = (minimum(height), maximum(height))
    colormap = :viridis

    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1],
        ylabel = "Proportion of biomass that is\nremoved by trampling [-]",
        xlabel = "Biomass of each species [kg ha⁻¹]",
        title = "constant livestock density: 2 [ha⁻¹]")
    for i in 1:nspecies
        lines!(ustrip.(biomass_vals), trampling_mat_height[i, :];
            linewidth = 3, label = "height=$(height[i])",
            colormap,
            colorrange,
            color = height[i])
    end

    Colorbar(fig[1, 2]; colormap, colorrange, label = "Plant height [m]")

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end
end


function plot_trampling_biomass_individual(; β_TRM = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; )
    container.traits.height .= 0.7u"m"

    if !isnothing(β_TRM)
        container.p.β_TRM = β_TRM * u"kg"
    end

    nbiomass = 30
    biomass = fill(100.0, nspecies)u"kg / ha"
    biomass_vals = LinRange(0.0, 200.0, nbiomass)u"kg / ha"
    LD = 2.0u"ha^-1"

    trampling_mat_height = Array{Quantity{Float64}}(undef, nspecies, nbiomass)

    for (i, b) in enumerate(biomass_vals)
        biomass[1] = b
        container.calc.defoliation .= 0.0u"kg / ha"
        trampling!(; container, LD, biomass)
        trampling_mat_height[:, i] = container.calc.defoliation
    end
    trampling_mat_height = ustrip.(trampling_mat_height)# ./ biomass .* u"d"

    idx = sortperm(container.traits.height)
    height = ustrip.(container.traits.height)[idx]
    trampling_mat_height = trampling_mat_height[idx, :]

    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1],
        ylabel = "Raw biomass that is removed\nby trampling [kg ha⁻¹]",
        xlabel = "Biomass of first species (red) [kg ha⁻¹]",
        title = """constant livestock density,
                   all species have the same traits
                   biomass of species 1 on x axis,
                   all other species with 100 [kg ha⁻¹]""")
    for i in 1:2
        lines!(ustrip.(biomass_vals), trampling_mat_height[i, :];
            linewidth = 3,
            color = i == 1 ? :red : :blue)
    end

    # Colorbar(fig[1, 2]; colormap, colorrange, label = "Plant height [m]")

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end

function plot_trampling_livestockdensity(; β_TRM = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; )
    if !isnothing(β_TRM)
        container.p.β_TRM = β_TRM * u"kg / ha"
    end

    nLD = 10
    biomass = fill(100.0, nspecies)u"kg / ha"
    LDs = LinRange(0.0, 4.0, nLD)u"ha^-1"

    trampling_mat_height = Array{Quantity{Float64}}(undef, nspecies, nLD)

    for (i, LD) in enumerate(LDs)
        container.calc.defoliation .= 0.0u"kg / ha"
        trampling!(; container, LD, biomass)
        trampling_mat_height[:, i] = container.calc.defoliation
    end
    trampling_mat_height = trampling_mat_height ./ biomass

    idx = sortperm(container.traits.height)
    height = ustrip.(container.traits.height)[idx]
    trampling_mat_height = trampling_mat_height[idx, :]

    colorrange = (minimum(height), maximum(height))
    colormap = :viridis

    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1],
        ylabel = "Proportion of biomass that is\nremoved by trampling [-]",
        xlabel = "Livestock density [ha⁻¹]",
        title = "constant biomass of each species: 100 [kg ha⁻¹]")
    for i in 1:nspecies
        lines!(ustrip.(LDs), trampling_mat_height[i, :];
            linewidth = 3, label = "height=$(height[i])",
            colormap,
            colorrange,
            color = height[i])
    end

    Colorbar(fig[1, 2]; colormap, colorrange, label = "Plant height [m]")

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
