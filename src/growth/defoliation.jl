@doc raw"""
Influence of mowing for plant species with different heights ($height$):
![Image of mowing effect](../img/mowing.svg)
"""
function mowing!(; t, container, mowing_height, biomass, mowing_all, x, y)
    @unpack height = container.traits
    @unpack defoliation, proportion_mown, lowbiomass_correction = container.calc
    @unpack mown = container.output
    @unpack α_lowB, β_lowB = container.p
    @unpack nspecies = container.simp

    # --------- proportion of plant height that is mown
    proportion_mown .= max.(height .- mowing_height, 0.0u"m") ./ height

    # --------- if low species biomass, the plant height is low -> less biomass is mown
    @. lowbiomass_correction =  1.0 / (1.0 + exp(-β_lowB * (biomass - α_lowB)))

    # --------- add the removed biomass to the defoliation vector
    for s in 1:nspecies
        mown[t, x, y, s] = lowbiomass_correction[s] *
                           proportion_mown[s] * biomass[s]
        defoliation[s] += mown[t, x, y, s]
    end

    return nothing
end

@doc raw"""
```math
\begin{align}
\rho &= \left(\frac{LNCM}{LNCM_{cwm]}}\right) ^ {\text{β_ρ_lnc}} \\
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

- `β_ρ_lnc` = 1.5
![](../img/grazing_1_5.svg)

- `β_ρ_lnc` = 5
![](../img/grazing_5.svg)

Influence of `α_GRZ`:
![](../img/α_GRZ.svg)
"""
function grazing!(; t, x, y, container, LD, biomass)
    @unpack lncm = container.traits
    @unpack α_GRZ, β_ρ_lnc, κ,
            α_lowB, β_lowB = container.p
    @unpack defoliation, grazed_share, relative_lncm, ρ,
            lowbiomass_correction, low_ρ_biomass = container.calc
    @unpack grazed = container.output

    ## Palatability ρ
    relative_lncm .= lncm .* biomass ./ sum(biomass)
    ρ .= (lncm ./ sum(relative_lncm)) .^ β_ρ_lnc

    ## Grazing
    μₘₐₓ = κ * LD
    h = 1 / μₘₐₓ
    a = 1 / (α_GRZ*α_GRZ * h)

    ## Exponentiation of Quantity with a variable is type unstable
    ## therefore this is a workaround, k_exp = 2
    # https://painterqubits.github.io/Unitful.jl/stable/trouble/#Exponentiation
    sum_biomass = sum(biomass)
    biomass_exp = sum_biomass * sum_biomass
    total_grazed = a * biomass_exp / (1u"kg^2 * ha^-2" + a * h * biomass_exp)

    @. lowbiomass_correction =  1.0 / (1.0 + exp(-β_lowB * (biomass - α_lowB)))
    @. low_ρ_biomass = lowbiomass_correction * ρ * biomass
    grazed_share .= low_ρ_biomass ./ sum(low_ρ_biomass)

    #### add grazed biomass to defoliation
    @. grazed[t, x, y, :] = grazed_share * total_grazed
    @. defoliation += grazed_share * total_grazed

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

![Image of effect of biomass of plants on the trampling](../img/trampling_biomass.svg)
![Image of effect of livestock density on trampling](../img/trampling_LD.svg)
![](../img/trampling_biomass_individual.svg)
"""
function trampling!(; container, LD, biomass)
    @unpack height = container.traits
    @unpack β_TRM_height, β_TRM, α_TRM = container.p
    @unpack trampling_proportion, trampled_biomass, defoliation = container.calc

    h = 1 / LD
    a = 1 / (α_TRM*α_TRM * h)

    sum_biomass = sum(biomass)
    biomass_exp = sum_biomass * sum_biomass
    total_grazed = a * biomass_exp / (1u"kg^2 * ha^-2" + a * h * biomass_exp)
    @. trampling_proportion =
        min.((height / 0.5u"m") ^ β_TRM_height * total_grazed * β_TRM, 1.0)
    @. trampled_biomass = biomass * trampling_proportion
    defoliation .+= trampled_biomass

    return nothing
end
