@doc raw"""
Influence of mowing for plant species with different heights ($height$):
![Image of mowing effect](../img/mowing.png)
"""
function mowing!(; t, container, mowing_height, biomass, mowing_all, x, y)
    @unpack height, abp = container.traits
    @unpack defoliation, mown, proportion_mown, lowbiomass_correction = container.calc
    # @unpack mown = container.output
    @unpack α_lowB, β_lowB = container.p
    @unpack nspecies = container.simp
    @unpack included = container.simp

    # --------- proportion of plant height that is mown
    proportion_mown .= abp .* max.(height .- mowing_height, 0.0u"m") ./ height

    # --------- if low species biomass, the plant height is low -> less biomass is mown
    if included.lowbiomass_avoidance
        @. lowbiomass_correction =  1.0 / (1.0 + exp(-β_lowB * (abp * biomass - α_lowB)))
    else
        lowbiomass_correction .= 1.0
    end

    # --------- add the removed biomass to the defoliation vector
    @. mown = lowbiomass_correction * proportion_mown * biomass
    defoliation .+= mown

    return nothing
end

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
function grazing!(; t, x, y, container, LD, biomass)
    @unpack lnc, abp = container.traits
    @unpack α_GRZ, β_PAL_lnc, κ, α_lowB, β_lowB = container.p
    @unpack defoliation, grazed_share, relative_lnc, ρ, grazed,
            lowbiomass_correction, low_ρ_biomass, above_biomass = container.calc
    @unpack included = container.simp

    #################################### total grazed biomass
    @. above_biomass = abp * biomass
    sum_biomass = sum(above_biomass)
    biomass_exp = sum_biomass * sum_biomass
    total_grazed = κ * LD * biomass_exp / (α_GRZ * α_GRZ + biomass_exp)

    #################################### share of grazed biomass per species
    ## Palatability ρ
    relative_lnc .= lnc .* above_biomass ./ sum_biomass
    cwm_lnc = sum(relative_lnc)
    ρ .= (lnc ./ cwm_lnc) .^ β_PAL_lnc

    ## species with low biomass are less grazed
    if included.lowbiomass_avoidance
        @. lowbiomass_correction = 1.0 / (1.0 + exp(-β_lowB * (above_biomass - α_lowB)))
    else
        lowbiomass_correction .= 1.0
    end
    @. low_ρ_biomass = lowbiomass_correction * ρ * above_biomass

    grazed_share .= low_ρ_biomass ./ sum(low_ρ_biomass)

    #################################### add grazed biomass to defoliation
    @. grazed = grazed_share * total_grazed
    defoliation .+= grazed

    return nothing
end

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
