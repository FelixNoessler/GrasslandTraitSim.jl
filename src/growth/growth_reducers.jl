@doc raw"""
Reduction of radiation use efficiency at light intensities higher
than 5 ``MJ\cdot m^{-2}\cdot d^{-1}``

```math
\text{Rred} = \text{min}(1, 1- \gamma_1(\text{PAR}(t) - \gamma_2))
```

The equations and the parameter values are taken from [Schapendonk1998](@cite).

- `γ₁` is the empirical parameter for a decrease in RUE for high PAR values,
  here set to 0.0445 [m² d MJ⁻¹]
- `γ₂` is the threshold value of PAR from which starts a linear decrease in RUE,
  here set to 5 [MJ m⁻²]

comment to the equation/figure: PAR values are usually between 0 and
15 ``MJ\cdot m^{-2}\cdot d^{-1}`` and therefore negative values of
Rred are very unlikely
![Image of the radiation reducer function](../img/radiation_reducer.svg)
"""
function radiation_reduction(; container, PAR)
    @unpack included = container.simp

    if !included.radiation_red
        @info "No radiation reduction!" maxlog=1
        return 1.0
    end

    @unpack γ1, γ2 = container.p
    return min(1.0, 1.0 − uconvert(NoUnits, γ1 * (PAR − γ2)))
end

@doc raw"""
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
function temperature_reduction(; container, T)
    @unpack included = container.simp

    if !included.temperature_growth_reduction
        @info "No temperature reduction!" maxlog=1
        return 1.0
    end

    @unpack T₀, T₁, T₂, T₃ = container.p

    if T < T₀
        return 0.0
    elseif T < T₁
        return (T - T₀) / (T₁ - T₀)
    elseif T < T₂
        return 1.0
    elseif T < T₃
        return (T₃ - T) / (T₃ - T₂)
    else
        return 0.0
    end
end

@doc raw"""
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
function seasonal_reduction(; container, ST)
    @unpack included = container.simp

    if !included.season_red
        @info "No seasonal reduction!" maxlog=1
        return 1.0
    end

    @unpack SEAₘᵢₙ, SEAₘₐₓ, ST₁, ST₂ = container.p

    ## unit conversion from celcius to kelvin
    # 100 °C = 373.15 K
    # 200 °C = 473.15 K
    # 400 °C = 673.15 K

    if ST < 473.15u"K"
        return SEAₘᵢₙ
    elseif ST < ST₁ - 473.15u"K"
        return SEAₘᵢₙ + (SEAₘₐₓ - SEAₘᵢₙ) * (ST - 473.15u"K") / (ST₁ - 673.15u"K")
    elseif ST < ST₁ - 373.15u"K"
        return SEAₘₐₓ
    elseif ST < ST₂
        return SEAₘᵢₙ + (SEAₘᵢₙ - SEAₘₐₓ) * (ST - ST₂) / (ST₂ - (ST₁ - 373.15u"K"))
    else
        return SEAₘᵢₙ
    end
end


@doc raw"""
```math
r = \frac{1}{1 + \exp(-\beta_{\text{community height}} \cdot
                      (h_{\text{cwm}} - \alpha_{\text{community height}}))}
```

Only one species is used for the simulation:
![Height reducer fucntion](../img/community_height.svg)
![Effect of the community height reduction](../img/community_height_influence.svg)
"""
function community_height_reduction(; container, biomass)
    @unpack included = container.simp
    if !included.community_height_red
        @info "No community height growth reduction!" maxlog=1
        return 1.0
    end

    @unpack relative_height = container.calc
    @unpack height = container.traits
    @unpack α_community_height, β_community_height = container.p
    relative_height .= height .* biomass ./ sum(biomass)
    height_cwm = sum(relative_height)

    return 1 / (1 + exp(β_community_height * (α_community_height - height_cwm)))
end
