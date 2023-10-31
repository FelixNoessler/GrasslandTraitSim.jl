@doc raw"""
    potential_growth!(; calc, SLA, biomass, PAR, potgrowth_included)

Calculates the potential growth of all plant species
in a specific patch.

This function is called each time step (day) for each patch.
The `PAR` value is the photosynthetically
active radiation of the day.

First, the leaf area indices of all species are calculated
(see [`Growth.calculate_LAI`](@ref)). Then, the total leaf area is
computed. An inverse exponential function is used to calculate
the total primary production:

```math
\text{totalgrowth} =
    PAR \cdot RUE_{max} \cdot (1 -  \text{exp}(-\alpha \cdot \text{LAItot}))
```

This primary production is then multiplied with the share of the
leaf area index of the individual species

![Influence of the specific leaf area on the potential growth](../img/sla_potential_growth.svg)
"""
function potential_growth!(; container, sla, biomass, PAR, potgrowth_included)
    @unpack LAIs, pot_growth = container.calc

    LAItot = calculate_LAI(; LAIs, sla, biomass)
    if LAItot < 0
        @error "LAItot below zero: $LAItot" maxlog=10
    end

    if LAItot == 0 || !potgrowth_included
        @info "Zero potential growth!" maxlog=1
        pot_growth .= 0.0u"kg / (ha * d)"
        return LAItot
    end

    RUE_max = 3 // 1000 * u"kg / MJ" # Maximum radiation use efficiency 3 g DM MJ-1
    α = 0.6   # Extinction coefficient, unitless
    pot_growth_tot = PAR * RUE_max * (1 - exp(-α * LAItot))
    @. pot_growth = pot_growth_tot * LAIs / LAItot

    return LAItot
end

@doc raw"""
    calculate_LAI(; SLA, biomass, LAIs)

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
function calculate_LAI(; sla, biomass, LAIs)
    LAM = 0.62 # Proportion of laminae in green biomass
    LAIs .= uconvert.(NoUnits, sla .* biomass .* LAM)
    return sum(LAIs)
end
