module Water

using Unitful
using UnPack

@doc raw"""
    change_water_reserve(; container, patch_biomass, WR, precipitation,
                           LAItot, PET, WHC, PWP)

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
        \min\left(\text{WR} \cdot \frac{1}{d}, \text{ATr} + \text{AEv} \right) \\
    \text{drain} &=
        \max\left(
            \text{WR} \cdot \frac{1}{d} +
            \text{precipitation} -
            \text{WHC} \cdot \frac{1}{d} -
            \text{AET}, 0 \right) \\
    \text{WR_change} &= \text{precipitation} - \text{drain} - \text{AET}
\end{align}
```

Note the unit change of the water reserve `WR` and the water holding capacity
`WHC` from [mm] to [mm d⁻¹] to compare these values to water reserve changes
per day.

- `WR` is the water reserve in the soil [mm]
- `WR_change` is the change of the water reserve in the soil [mm d⁻¹]
- `precipitation` is the precipitation [mm d⁻¹]
- `drain` is the drainage of water from the soil [mm d⁻¹]
- `AET` is the actual evapotranspiration [mm d⁻¹]
- `ATr` is the actual transpiration of water from the soil [mm d⁻¹]
- `AEv` is the actual evaporation of water from the soil [mm d⁻¹]
- `WHC` is the water holding capacity of the soil [mm]
- `PWP` is the permanent wilting point of the soil [mm]
- `PET` is the potential evapotranspiration [mm d⁻¹]
- `LAItot` is the total leaf area index of all plants [-]
"""
function change_water_reserve(; container, patch_biomass, WR, precipitation,
        LAItot, PET, WHC, PWP)
    # -------- Evapotranspiration
    AEv = evaporation(; WR, WHC, PET, LAItot)
    ATr = transpiration(; container, patch_biomass, WR, PWP, WHC, PET, LAItot)
    AET = min(WR / u"d", ATr + AEv)

    # -------- Drainage
    drain = max(WR / u"d" + precipitation - WHC / u"d" - AET, 0u"mm / d")

    # -------- Total change in the water reserve
    WR_change = precipitation - drain - AET

    return WR_change
end

@doc raw"""
    transpiration(; container, patch_biomass, WR, PWP, WHC, PET, LAItot)

Transpiration of water from the soil.

The transpiration is dependent on the plant available water (`W`),
potential evapotranspiration (`PET`) and a effect of the community
weighted mean specific leaf area (`sla_effect`).

If the community weighted mean specific leaf area is high
(many plant individuals with thin leaves), a higher transpiration is assumed.

```math
\begin{align}
    \text{W} &= \frac{\text{WR} - \text{PWP}}{\text{WHC} - \text{PWP}} \\
    \text{sla_effect} &=
        \left(\frac{\text{cwm_sla}}{\text{sla_tr}} \right)^{\text{sla_tr_exponent}} \\
    \text{ATr} &=
        \text{W} \cdot \text{PET} \cdot \text{sla_effect} \cdot
        \min\left(1; \frac{\text{LAItot}}{3} \right)
\end{align}
```

- `ATr` is the actual transpiration of water from the soil [mm d⁻¹]
- `W` is the plant available water [-]
- `WR` is the water reserve in the soil [mm]
- `WHC` is the water holding capacity of the soil [mm]
- `PWP` is the permanent wilting point of the soil [mm]
- `PET` is the potential evapotranspiration [mm d⁻¹]
- `LAItot` is the total leaf area index of all plants [-]
- `sla_effect` is the effect of the community weighted
  specific leaf area on the transpiration, can range from
  0 (no transpiraiton at all) to ∞ (very strong transpiration) [-]
- `cwm_sla` is the community weighted mean specific leaf area [m² kg⁻¹]
- `sla_tr` is a specific leaf area, if the `cwm_sla` equals `sla_tr`
  the `sla_effect` is 1 [m² kg⁻¹]
- `sla_tr_exponent` is the exponent in the `sla_effect` function and influences
  how strong a `cwm_sla` that deviates from `sla_tr`
  changes the `sla_effect` [-]
"""
function transpiration(; container, patch_biomass, WR, PWP, WHC, PET, LAItot)
    @unpack sla = container.traits
    @unpack sla_tr, sla_tr_exponent = container.p
    @unpack relative_sla = container.calc

    ###### SLA effect
    # community weighted mean specific leaf area
    relative_sla .= sla .* patch_biomass ./ sum(patch_biomass)
    cwm_sla = sum(relative_sla)
    sla_effect = (cwm_sla / (sla_tr * u"m^2 / g"))^sla_tr_exponent

    ####### plant available water:
    W = max(0.0, (WR - PWP) / (WHC - PWP))

    return W * PET * sla_effect * LAItot / 3
end

@doc raw"""
    evaporation(; WR, WHC, PET, LAItot)

Evaporation of water from the soil.

```math
\text{AEv} =
    \frac{\text{WR}}{\text{WHC}} \cdot \text{PET} \cdot
    \left[1 - \min\left(1; \frac{\text{LAItot}}{3} \right) \right]
```

- `AEv` is the actual evaporation of water from the soil [mm d⁻¹]
- `WR` is the water reserve in the soil [mm]
- `WHC` is the water holding capacity of the soil [mm]
- `PET` is the potential evapotranspiration [mm d⁻¹]
- `LAItot` is the total leaf area index of all plants [-]
"""
function evaporation(; WR, WHC, PET, LAItot)
    W = WR / WHC
    return W * PET * (1 - min(1, LAItot / 3))
end

end # of module
