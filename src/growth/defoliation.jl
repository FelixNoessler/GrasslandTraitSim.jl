@doc raw"""
```math
\begin{align}
    \lambda &= \frac{\text{mown_height}}{\text{height}}\\
    \text{mow_factor} &= \frac{1}{1+exp(-0.1*(\text{days_since_last_mowing}
        - \text{mowing_mid_days})}\\
    \text{mow} &= \lambda \cdot \text{biomass}
\end{align}
```

The mow_factor has been included to account for the fact that less biomass is mown
when the last mowing event was not long ago.
Influence of mowing for plant species with different heights ($height$):
![Image of mowing effect](../img/mowing.svg)

Visualisation of the `mow_factor`:
![](../img/mow_factor.svg)
"""
function mowing!(; t, container, mowing_height, biomass, mowing_all, x, y)
    @unpack height = container.traits
    @unpack defoliation, proportion_mown, lowbiomass_correction = container.calc
    @unpack mown = container.output
    @unpack mowing_mid_days, mowfactor_β, lowbiomass, lowbiomass_k = container.p
    @unpack nspecies = container.simp

    days_since_last_mowing = 200

    tstart = t - 200 < 1 ? 1 : t - 200
    mowing_last200 = @view mowing_all[t-1:-1:tstart]

    for i in eachindex(mowing_last200)
        if i == 1
            continue
        end

        if !isnan(mowing_last200[i]) && !iszero(mowing_last200[i])
            days_since_last_mowing = i
            break
        end
    end

    # --------- proportion of plant height that is mown
    proportion_mown .= max.(height .- mowing_height, 0.0u"m") ./ height

    # --------- if meadow is too often mown, less biomass is removed
    ## the 'mowing_mid_days' is the day where the plants are grown
    ## back to their normal size/2
    mow_factor = 1.0 / (1.0 + exp(-mowfactor_β * (days_since_last_mowing - mowing_mid_days)))
    @. lowbiomass_correction =  1.0 / (1.0 + exp(-lowbiomass_k * (biomass - lowbiomass)))

    # --------- add the removed biomass to the defoliation vector
    for s in 1:nspecies
        mown[t, x, y, s] = lowbiomass_correction[s] * mow_factor *
                           proportion_mown[s] * biomass[s]
        defoliation[s] += mown[t, x, y, s]
    end

    return nothing
end

@doc raw"""
```math
\begin{align}
\rho &= \left(\frac{LNCM}{LNCM_{cwm]}}\right) ^ {\text{leafnitrogen_graz_exp}} \\
μₘₐₓ &= κ \cdot \text{LD} \\
h &= \frac{1}{μₘₐₓ} \\
a &= \frac{1}{\text{grazing_half_factor}^2 \cdot h} \\
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
- `grazing_half_factor` is the half-saturation constant [kg ha⁻¹]
- equation partly based on [Moulin2021](@cite)

Influence of grazing (livestock density = 2), all plant species have
an equal amount of biomass (total biomass / 3)
and a leaf nitrogen content of 15, 30 and 40 mg/g:

- `leafnitrogen_graz_exp` = 1.5
![](../img/grazing_1_5.svg)

- `leafnitrogen_graz_exp` = 5
![](../img/grazing_5.svg)

Influence of `grazing_half_factor`:
![](../img/grazing_half_factor.svg)
"""
function grazing!(; t, x, y, container, LD, biomass)
    @unpack lncm = container.traits
    @unpack grazing_half_factor, leafnitrogen_graz_exp, κ,
            lowbiomass, lowbiomass_k = container.p
    @unpack defoliation, grazed_share, relative_lncm, ρ,
            lowbiomass_correction, low_ρ_biomass = container.calc
    @unpack grazed = container.output

    ## Palatability ρ
    relative_lncm .= lncm .* biomass ./ sum(biomass)
    ρ .= (lncm ./ sum(relative_lncm)) .^ leafnitrogen_graz_exp

    ## Grazing
    μₘₐₓ = κ * LD
    h = 1 / μₘₐₓ
    a = 1 / (grazing_half_factor*grazing_half_factor * h)

    ## Exponentiation of Quantity with a variable is type unstable
    ## therefore this is a workaround, k_exp = 2
    # https://painterqubits.github.io/Unitful.jl/stable/trouble/#Exponentiation
    sum_biomass = sum(biomass)
    biomass_exp = sum_biomass * sum_biomass
    total_grazed = a * biomass_exp / (1u"kg^2 * ha^-2" + a * h * biomass_exp)

    @. lowbiomass_correction =  1.0 / (1.0 + exp(-lowbiomass_k * (biomass - lowbiomass)))
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
    \text{height} \cdot \text{LD} \cdot \text{trampling_factor}  \\
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
- `trampling_factor` [ha m⁻¹]
- height canopy height [$m$]

![Image of effect of biomass of plants on the trampling](../img/trampling_biomass.svg)
![Image of effect of livestock density on trampling](../img/trampling_LD.svg)
![](../img/trampling_biomass_individual.svg)
"""
function trampling!(; container, LD, biomass)
    @unpack height = container.traits
    @unpack trampling_height_exp, trampling_factor, trampling_half_factor = container.p
    @unpack trampling_proportion, trampled_biomass, defoliation = container.calc

    h = 1 / LD
    a = 1 / (trampling_half_factor*trampling_half_factor * h)

    sum_biomass = sum(biomass)
    biomass_exp = sum_biomass * sum_biomass
    total_grazed = a * biomass_exp / (1u"kg^2 * ha^-2" + a * h * biomass_exp)
    @. trampling_proportion =
        min.((height / 0.5u"m") ^ trampling_height_exp * total_grazed * trampling_factor, 1.0)
    @. trampled_biomass = biomass * trampling_proportion
    defoliation .+= trampled_biomass

    return nothing
end

@doc raw"""
Relative biomass of the patches in relation to the mean biomass of the overall grassland.

```math
\text{relbiomass} = \frac{\text{patch_biomass}}{\text{mpatch_biomass}}
```

- `relbiomass` relative biomass of each patch [-]
- `patch_biomass` sum of the biomass of all species in one patch [kg ha⁻¹]
- `mpatch_biomass` mean of the sum of the biomass of all species in all patches [kg ha⁻¹]
"""
function calculate_relbiomass!(; container)
    @unpack biomass_per_patch, relbiomass = container.calc
    @unpack u_biomass = container.u
    @unpack patch_xdim, patch_ydim = container.simp

    for x in Base.OneTo(patch_xdim)
        for y in Base.OneTo(patch_ydim)
            biomass_per_patch[x, y] = mean(@view u_biomass[x, y, :])
        end
    end
    relbiomass .= biomass_per_patch ./ mean(biomass_per_patch)

    return nothing
end
