@doc raw"""
Models the change of the water reserve in the soil within one day.

Precipitation fills the water reserve (`precipitation`).

The water reserve cannot exceed the water holding capacity (`WHC`).
If the water reserve is higher than the `WHC` the water
will drain from the soil (`drain`).

The actual evapotranspiration (`AET`) consists of the evaporation and the
transpiration. Which of the two processes is more important depends on the
plant cover that is simulated by the total leaf area index (`LAItot`).

The transpiration (`ATr`) is limited by the plant available water
(`W`) and the potential evapotranspiration (`PET`) whereas
the evaporation (`AEv`) is only limited by the potential
evapotranspiration (`PET`).

The change of the water reserve is calculated as follows:
```math
\begin{align}
    \text{AET} &=
        \min\left(\text{water} \cdot \frac{1}{d}, \text{ATr} + \text{AEv} \right) \\
    \text{drain} &=
        \max\left(
            \text{water} \cdot \frac{1}{d} +
            \text{precipitation} -
            \text{WHC} \cdot \frac{1}{d} -
            \text{AET}, 0 \right) \\
    \text{du_water} &= \text{precipitation} - \text{drain} - \text{AET}
\end{align}
```

Note the unit change of the soil water content `water` and the water holding capacity
`WHC` from [mm] to [mm] to compare these values to water reserve changes
per day.

- `water` is the soil water content [mm]
- `du_water` is the change of the water reserve in the soil [mm]
- `precipitation` is the precipitation [mm]
- `drain` is the drainage of water from the soil [mm]
- `AET` is the actual evapotranspiration [mm]
- `ATr` is the actual transpiration of water from the soil [mm]
- `AEv` is the actual evaporation of water from the soil [mm]
- `WHC` is the water holding capacity of the soil [mm]
- `PWP` is the permanent wilting point of the soil [mm]
- `PET` is the potential evapotranspiration [mm]
- `LAItot` is the total leaf area index of all plants [-]
"""
function change_water_reserve(; container, patch_above_biomass, water, precipitation,
                              PET, WHC, PWP)
    @unpack LAItot = container.calc.com

    # -------- Evapotranspiration
    AEv = evaporation(; water, WHC, PET, LAItot)
    ATr = transpiration(; container, patch_above_biomass, water, PWP, WHC, PET, LAItot)
    AET = min(water, ATr + AEv)

    # -------- Drainage
    excess_water = water - WHC
    drain = max(excess_water + precipitation -AET, zero(excess_water))

    # -------- Total change in the water reserve
    du_water = precipitation - drain - AET

    return du_water
end

@doc raw"""
Transpiration of water from the plants.

The transpiration is dependent on the plant available water (`W`),
potential evapotranspiration (`PET`) and a effect of the community
weighted mean specific leaf area (`sla_effect`).

If the community weighted mean specific leaf area is high
(many plant individuals with thin leaves), a higher transpiration is assumed.

```math
\begin{align}
    \text{W} &= \frac{\text{water} - \text{PWP}}{\text{WHC} - \text{PWP}} \\
    \text{sla_effect} &=
        \left(\frac{\text{cwm_sla}}{\text{ϕ_sla}} \right)^{\text{β_TR_sla}} \\
    \text{ATr} &=
        \text{W} \cdot \text{PET} \cdot \text{sla_effect} \cdot
        \min\left(1; \frac{\text{LAItot}}{3} \right)
\end{align}
```

- `ATr` is the actual transpiration of water from the soil [mm]
- `W` is the plant available water [-]
- `water` is the soil water content [mm]
- `WHC` is the water holding capacity of the soil [mm]
- `PWP` is the permanent wilting point of the soil [mm]
- `PET` is the potential evapotranspiration [mm]
- `LAItot` is the total leaf area index of all plants [-]
- `sla_effect` is the effect of the community weighted
  specific leaf area on the transpiration, can range from
  0 (no transpiraiton at all) to ∞ (very strong transpiration) [-]
- `cwm_sla` is the community weighted mean specific leaf area [m² kg⁻¹]
- `ϕ_sla` is a specific leaf area, if the `cwm_sla` equals `ϕ_sla`
  the `sla_effect` is 1 [m² kg⁻¹]
- `β_TR_sla` is the exponent in the `sla_effect` function and influences
  how strong a `cwm_sla` that deviates from `ϕ_sla`
  changes the `sla_effect` [-]
"""
function transpiration(; container, patch_above_biomass, water, PWP, WHC, PET, LAItot)
    @unpack included = container.simp

    ###### SLA effect
    sla_effect = 1.0
    if included.sla_transpiration
        @unpack sla = container.traits
        @unpack ϕ_sla, β_TR_sla = container.p
        @unpack relative_sla = container.calc

        # community weighted mean specific leaf area
        relative_sla .= sla .* patch_above_biomass ./ sum(patch_above_biomass)
        cwm_sla = sum(relative_sla)
        sla_effect = min(2.0, max(0.5, (cwm_sla / ϕ_sla) ^ β_TR_sla))  # TODO change in documentation and manusctipt
    end

    ####### plant available water:
    W = max(0.0, (water - PWP) / (WHC - PWP))

    return W * PET * sla_effect * LAItot / 3 # TODO
end

@doc raw"""
Evaporation of water from the soil.

```math
\text{AEv} =
    \frac{\text{water}}{\text{WHC}} \cdot \text{PET} \cdot
    \left[1 - \min\left(1; \frac{\text{LAItot}}{3} \right) \right]
```

- `AEv` is the actual evaporation of water from the soil [mm]
- `water` is the soil water content [mm]
- `WHC` is the water holding capacity of the soil [mm]
- `PET` is the potential evapotranspiration [mm]
- `LAItot` is the total leaf area index of all plants [-]
"""
function evaporation(; water, WHC, PET, LAItot)
    return water / WHC * PET * (1 - min(1, LAItot / 3))
end

@doc raw"""
Derive walter holding capacity (WHC) and
permanent wilting point (PWP) from soil properties.

```math
\begin{align}
    θ₁ &= a₁ ⋅ \text{sand} + b₁ ⋅ \text{silt} + c₁ ⋅ \text{clay} +
            d₁ ⋅ \text{organic} + e₁ ⋅ \text{bulk} \\
    \text{WHC} &= θ₁ ⋅ \text{rootdepth} \\
    θ₂ &= a₂ ⋅ \text{sand} + b₂ ⋅ \text{silt} + c₂ ⋅ \text{clay} +
            d₂ ⋅ \text{organic} + e₂ ⋅ \text{bulk} \\
    \text{PWP} &= θ₂ ⋅ \text{rootdepth}
\end{align}
```

Equation and coefficients are taken from [Gupta1979](@cite).
The coefficients a, b, c, d and e differ for the water holding
capacity (matrix potential Ψ = -0.07 bar) and
the permanent wilting point (matrix potential Ψ = -15 bar).
The empirical coefficients that were estimated by [Gupta1979](@cite)
can be seen in the folling table:

| Ψ [bar] | a        | b        | c        | d        | e       |
| ------- | -------- | -------- | -------- | -------- | ------- |
| -0.07   | 0.005678 | 0.009228 | 0.009135 | 0.006103 | -0.2696 |
| -15     | -5.9e-5  | 0.001142 | 0.005766 | 0.002228 | 0.02671 |

- `sand`: sand content [%]
- `silt`: silt content [%]
- `clay`: clay content [%]
- `bulk`: bulk density [g cm⁻³]
- `organic`: organic matter content [%]
- `rootdepth`: rooting depth [mm]
- `θ`: water content [cm³ cm⁻³]
- `WHC`: water holding capacity [mm]
- `PWP`: permanent wilting point [mm]
"""
function input_WHC_PWP!(; container)
    @unpack WHC, PWP = container.patch_variables
    @unpack sand, silt, clay, organic, bulk, rootdepth = container.site

    @. WHC = (0.5678 * sand +
        0.9228 * silt +
        0.9135 * clay +
        0.6103 * organic -
        0.2696u"cm^3/g" * bulk) * rootdepth
    @. PWP = (-0.0059 * sand +
        0.1142 * silt +
        0.5766 * clay +
        0.2228 * organic +
        0.02671u"cm^3/g" * bulk) * rootdepth

    return nothing
end
