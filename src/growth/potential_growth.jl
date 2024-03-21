@doc raw"""
Calculates the potential growth of all plant species
in a specific patch.

This function is called each time step (day) for each patch.
The `PAR` value is the photosynthetically
active radiation of the day.

First, the leaf area indices of all species are calculated
(see [`calculate_LAI`](@ref)). Then, the total leaf area is
computed. An inverse exponential function is used to calculate
the total primary production:

This primary production is then multiplied with the share of the
leaf area index of the individual species

```math
\begin{align*}
\text{potgrowth_total} &=
    PAR \cdot RUE_{max} \cdot (1 -  \text{exp}(-k \cdot \text{LAItot})) \\
\text{potgrowth} &= \text{potgrowth_total} \cdot \frac{\text{LAI}}{\text{LAItot}}
\end{align*}
```

- `PAR` photosynthetically active radiation [MJ ha⁻¹]
- `RUE_max` maximum radiation use efficiency [kg MJ⁻¹]
- `k` extinction coefficient [-]
- `LAItot` total leaf area index [m² m⁻²]
- `LAIs` leaf area index of each species [m² m⁻²]
- `potgrowth_total` total potential growth [kg ha⁻¹]
- `potgrowth` potential growth of each species [kg ha⁻¹]

![Influence of the specific leaf area on the potential growth](../img/sla_potential_growth.svg)
"""
function potential_growth!(; container, biomass, PAR)
    @unpack included = container.simp
    @unpack LAIs, potgrowth = container.calc

    LAItot = calculate_LAI(; container, biomass, LAIs)
    # if LAItot < 0
    #     @error "LAItot below zero: $LAItot" maxlog=10
    # end

    if LAItot == 0 || !included.potential_growth
        @info "Zero potential growth!" maxlog=1
        potgrowth .= 0.0u"kg / ha"
        return LAItot
    end

    @unpack RUE_max, k = container.p
    potgrowth_total = PAR * RUE_max * (1 - exp(-k * LAItot))
    @. potgrowth = potgrowth_total * LAIs / LAItot

    return LAItot
end

@doc raw"""
Calculate the leaf area index of all species of one habitat patch.

```math
\begin{align}
\text{LAI} &= \text{SLA} \cdot \text{biomass} \cdot \text{LAM} \\
\text{LAI}_{\text{tot}} &= \sum \text{LAI}
\end{align}
```

- `SLA` specific leaf area [m² g⁻¹]
- `LAM` Proportion of laminae in green biomass [unitless], the value 0.62 is derived by [Jouven2006](@cite)
- `biomass` [kg ha⁻¹]

There is a unit conversion from the `SLA` and the `biomass`
to the unitless `LAI` involved.

The array `LAIs` is mutated inplace.
"""
function calculate_LAI(; container, biomass, LAIs)
    @unpack sla, lmpm, ampm = container.traits
    @unpack nspecies = container.simp

    for s in Base.OneTo(nspecies)
        LAIs[s] = uconvert(NoUnits, sla[s] * biomass[s] * lmpm[s] / ampm[s])
    end

    return sum(LAIs)
end
