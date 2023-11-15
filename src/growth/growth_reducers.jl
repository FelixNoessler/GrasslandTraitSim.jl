@doc raw"""
    radiation_reduction(; PAR, radiation_red)

Reduction of radiation use efficiency at light intensities higher
than 5 ``MJ\cdot m^{-2}\cdot d^{-1}``

```math
\text{Rred} = \text{min}(1, 1-\gamma_1(\text{PAR}(t) - \gamma_2))
```

The equations and the parameter values are taken from [Schapendonk1998](@cite).

- `γ₁` is the empirical parameter for a decrease in RUE for high PAR values,
  here set to 0.0445 [m² d MJ⁻¹]
- `γ₂` is the threshold value of PAR from which starts a linear decrease in RUE,
  here set to 5 [MJ m⁻² d⁻¹]

comment to the equation/figure: PAR values are usually between 0 and
15 ``MJ\cdot m^{-2}\cdot d^{-1}`` and therefore negative values of
Rred are very unlikely
![Image of the radiation reducer function](../img/radiation_reducer.svg)
"""
function radiation_reduction(; PAR, radiation_red)
    if !radiation_red
        @info "No radiation reduction!" maxlog=1
        return 1.0
    end

    γ1 = 0.0445u"m^2 * d / MJ"
    γ2 = 5.0u"MJ / (m^2 * d)"

    return min(1.0, 1.0 − γ1 * (PAR − γ2))
end

@doc raw"""
    temperature_reduction(; T, temperature_red)

Reduction of the potential growth if the temperature is low or too high
with a step function.

```math
\text{temperature_reduction}(T) =
    \begin{cases}
    0 & \text{if } T < T_0 \\
    \frac{T - T_0}{T_1 - T_0} & \text{if } T_0 < T < T_1 \\
    1 & \text{if } T_1 < T < T_2 \\
    \frac{T_3 - T}{T_3 - T_2} & \text{if } T_2 < T < T_3 \\
    0 & \text{if } T > T_3 \\
    \end{cases}
```

Equations are taken from [Moulin2021](@cite) and theses are based on
[Schapendonk1998](@cite). `T₁` is in [Moulin2021](@cite) a
species specific parameter, but here it is set to 12°C for all species.

- `T₀` is the lower temperature threshold for growth, here set to 3°C
- `T₁` is the lower bound for the optimal temperature for growth, here set to 12°C
- `T₂` is the upper bound for the optiomal temperature for growth, here set to 20°C
- `T₃` is the maximum temperature for growth, here set to 35°C

![Image of the temperature reducer function](../img/temperature_reducer.svg)
"""
function temperature_reduction(; T, temperature_red)
    if !temperature_red
        @info "No temperature reduction!" maxlog=1
        return 1.0
    end

    T = ustrip(T)

    T₀ = 3  #u"°C"
    T₁ = 12 #u"°C"
    T₂ = 20 #u"°C"
    T₃ = 35 #u"°C"

    if T < T₀
        return 0
    elseif T < T₁
        return (T - T₀) / (T₁ - T₀)
    elseif T < T₂
        return 1
    elseif T < T₃
        return (T₃ - T) / (T₃ - T₂)
    else
        return 0
    end
end

"""
    water_reduction!(; container, water, water_red, PET, PWP, WHC)

See for details: [Water stress](@ref water_stress)
"""
function water_reduction!(; container, water, water_red, PET, PWP, WHC)
    @unpack sla_water, rsa_above_water, Waterred = container.calc

    if !water_red
        @info "No water reduction!" maxlog=1
        @. Waterred = 1.0
        return nothing
    end

    plant_available_water!(; container, water, PWP, WHC, PET)

    ### ------------ species specific functional response
    sla_water_reduction!(; container)
    rsa_above_water_reduction!(; container)

    @. Waterred = sla_water * rsa_above_water

    return nothing
end

@doc raw"""
    plant_available_water!(; container, water, PWP, WHC, PET)

Derives the plant available water.

The plant availabe water is dependent on the soil water content,
the water holding capacity (`WHC`), the permanent
wilting point (`PWP`), the potential evaporation (`PET`) and a
belowground competition factor:

```math
\begin{align*}
W &= \frac{\text{water} - \text{PWP}}{\text{WHC} - \text{PWP}} \\
x₀ &= \frac{log(\frac{1}{1 - W} - 1)}{βₚₑₜ} + PETₘ \\
x &= 1 - \frac{1}{1 + e^{-βₚₑₜ (PET - x₀)}} \\
\text{water_splitted} &= x \cdot  \text{biomass_density_factor} \\
\end{align*}
```


![](../img/pet.svg)
"""
function plant_available_water!(; container, water, PWP, WHC, PET)
    @unpack water_splitted, sla_water, rsa_above_water, Waterred = container.calc
    @unpack biomass_density_factor = container.calc
    @unpack βₚₑₜ = container.p

    ## option 1: water reduction purely by water availability
    # x = water > WHC ? 1.0 : water > PWP ? (water - PWP) / (WHC - PWP) : 0.0

    ## option 2: water reduction by water availability and
    ##           potential evapotranspiration
    PETₘ = 2.0u"mm / d"
    W = water > WHC ? 1.0 : water > PWP ? (water - PWP) / (WHC - PWP) : 0.0
    x₀ = log(1/(1-W) - 1) / βₚₑₜ * u"mm /d" + PETₘ
    x = 1 - 1 / (1 + exp(-βₚₑₜ * (PET - x₀) * u"d/mm"))
    @. water_splitted = x * biomass_density_factor

    return nothing
end



"""
    sla_water_reduction!(; container)

Reduction of growth due to stronger water stress for higher specific leaf area (SLA).
"""
function sla_water_reduction!(; container)
    @unpack sla_water_midpoint = container.funresponse
    @unpack sla_water_lower = container.p
    @unpack sla_water, water_splitted = container.calc
    k_SLA = 5

    @. sla_water = sla_water_lower +
                   (1 - sla_water_lower) /
                   (1 + exp(-k_SLA * (water_splitted - sla_water_midpoint)))

    return nothing
end

"""
    rsa_above_water_reduction!(; calc, fun_response)

Reduction of growth due to stronger water stress for lower specific
root surface area per above ground biomass (`rsa_above`).
"""
function rsa_above_water_reduction!(; container)
    @unpack rsa_above_water_upper, rsa_above_midpoint = container.funresponse
    @unpack rsa_above_water_lower = container.p
    @unpack rsa_above_water, water_splitted = container.calc
    k_rsa_above = 7

    @. rsa_above_water = rsa_above_water_lower +
                         (rsa_above_water_upper - rsa_above_water_lower) /
                         (1 + exp(-k_rsa_above * (water_splitted - rsa_above_midpoint)))
    return nothing
end

"""
    nutrient_reduction!(;
        calc,
        fun_response,
        nutrient_red,
        nutrients)

See for details: [Nutrient stress](@ref nut_stress)
"""
function nutrient_reduction!(; container, nutrient_red, nutrients)
    @unpack Nutred, nutrients_splitted, biomass_density_factor = container.calc
    @unpack amc_nut, rsa_above_nut = container.calc

    if !nutrient_red
        @info "No nutrient reduction!" maxlog=1
        @. Nutred = 1.0
        return nothing
    end

    @. nutrients_splitted = nutrients * biomass_density_factor

    ### ------------ species specific functional response
    amc_nut_reduction!(; container)
    rsa_above_nut_reduction!(; container)

    @. Nutred = max(amc_nut, rsa_above_nut)

    return nothing
end

"""
    amc_nut_reduction!(; container)

Reduction of growth due to stronger nutrient stress for lower
arbuscular mycorrhizal colonization (`AMC`).
"""
function amc_nut_reduction!(; container)
    @unpack amc_nut_upper, amc_nut_midpoint = container.funresponse
    @unpack amc_nut_lower = container.p
    @unpack amc_nut, nutrients_splitted = container.calc

    k_AMC = 7
    @. amc_nut = amc_nut_lower +
                 (amc_nut_upper - amc_nut_lower) /
                 (1 + exp(-k_AMC * (nutrients_splitted - amc_nut_midpoint)))

    return nothing
end

"""
    rsa_above_nut_reduction!(;  calc, fun_response)

Reduction of growth due to stronger nutrient stress for lower specific
root surface area per above ground biomass (`rsa_above`).
"""
function rsa_above_nut_reduction!(; container)
    @unpack rsa_above_nut_upper, rsa_above_midpoint = container.funresponse
    @unpack rsa_above_nut_lower = container.p
    @unpack rsa_above_nut, nutrients_splitted = container.calc

    k_rsa_above = 7
    @. rsa_above_nut = rsa_above_nut_lower +
                       (rsa_above_nut_upper - rsa_above_nut_lower) /
                       (1 + exp(-k_rsa_above * (nutrients_splitted - rsa_above_midpoint)))

    return nothing
end

@doc raw"""
    seasonal_reduction(; ST, season_red)

Reduction of growth due to seasonal effects. The function is based on
the yearly cumulative sum of the daily mean temperatures (`ST`).

```math
\text{seasonal}(ST) =
    \begin{cases}
    SEA_{min} & \text{if } ST < 200 \\
    SEAₘᵢₙ + (SEAₘₐₓ - SEAₘᵢₙ) * \frac{ST - 200}{ST₁ - 400} &
        \text{if } 200 < ST < ST₁ - 200 \\
    SEA_{max} & \text{if } ST₁ - 200 < ST < ST₁ - 100 \\
    SEAₘᵢₙ + (SEAₘᵢₙ - SEAₘₐₓ) * \frac{ST - ST₂}{ST₂ - ST₁ - 100} &
        \text{if } ST₁ - 100 < ST < ST₂ \\
    SEA_{min} & \text{if } ST > ST₂ \\
    \end{cases}
```

This empirical function was developed by [Jouven2006](@cite). In contrast to
[Jouven2006](@cite) `SEAₘᵢₙ`, `SEAₘₐₓ`, `ST₁` and `ST₂` are not species specific
parameters, but are fixed for all species. The values of the parameters are based on
[Jouven2006](@cite) and were chosen to resemble the mean of all functional
groups that were described there.

A seasonal factor greater than one means that growth is increased by the
use of already stored resources. A seasonal factor below one means that
growth is reduced as the plant stores resources [Jouven2006](@cite).

- `ST` is the yearly cumulative sum of the daily mean temperatures
- `SEAₘᵢₙ` is the minimum value of the seasonal effect, here set to 0.67 [-]
- `SEAₘₐₓ` is the maximum value of the seasonal effect, here set to 1.33 [-]
-  `ST₁` and `ST₂` are parameters that describe the thresholds of the step function,
   here set to 625 and 1300 [°C d]

![Image of the seasonal effect function](../img/seasonal_reducer.svg)
"""
function seasonal_reduction(; ST, season_red)
    if !season_red
        @info "No seasonal reduction!" maxlog=1
        return 1.0
    end

    SEAₘᵢₙ = 0.7
    SEAₘₐₓ = 1.3
    ST₁ = 625
    ST₂ = 1300

    ST = ustrip(ST)

    if ST < 200
        return SEAₘᵢₙ
    elseif ST < ST₁ - 200
        return SEAₘᵢₙ + (SEAₘₐₓ - SEAₘᵢₙ) * (ST - 200) / (ST₁ - 400)
    elseif ST < ST₁ - 100
        return SEAₘₐₓ
    elseif ST < ST₂
        return SEAₘᵢₙ + (SEAₘᵢₙ - SEAₘₐₓ) * (ST - ST₂) / (ST₂ - (ST₁ - 100))
    else
        return SEAₘᵢₙ
    end
end
