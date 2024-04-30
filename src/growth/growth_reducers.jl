@doc raw"""
Reduction of radiation use efficiency at high radiation levels.

```math
RAD_{txy} = \min\left(1,\, 1-\gamma_1\left(PAR_{txy} - \gamma_2\right)\right)
```

The equations and the parameter values are taken from [Schapendonk1998](@cite).

Parameter, see also [`SimulationParameter`](@ref):
- ``\gamma_1`` (`γ₁`) controls the steepness of the linear decrease in
  radiation use efficiency for high ``PAR_{txy}`` values [MJ⁻¹ ha]
- ``\gamma_2`` (`γ₂`) threshold value of ``PAR_{txy}`` from which starts
  a linear decrease in radiation use efficiency [MJ ha⁻¹]

Variables:
- ``PAR_{txy}`` (`PAR`) photosynthetic active radiation [MJ ha⁻¹]

Output:
- ``RAD_{txy}`` (`RAD`) growth reduction factor based on too high radiation [-]

![Image of the radiation reducer function](../img/radiation_reducer.svg)
"""
function radiation_reduction!(; container, PAR)
    @unpack included = container.simp
    @unpack com = container.calc

    if haskey(included, :radiation_red) && !included.radiation_red
        @info "No radiation reduction!" maxlog=1
        com.RAD = 1.0
        return nothing
    end

    @unpack γ₁, γ₂ = container.p
    com.RAD = min(1.0, 1.0 − γ₁ * (PAR − γ₂))

    return nothing
end

@doc raw"""
Reduction of the growth if the temperature is low or too high.

```math
TEMP_{txy} =
    \begin{cases}
    0 & \text{if } T_{txy} < T_0 \\
    \frac{T_{txy} - T_0}{T_1 - T_0} & \text{if } T_0 < T_{txy} < T_1 \\
    1 & \text{if } T_1 < T_{txy} < T_2 \\
    \frac{T_3 - T_{txy}}{T_3 - T_2} & \text{if } T_2 < T_{txy} < T_3 \\
    0 & \text{if } T_{txy} > T_3 \\
    \end{cases}
```

Equation are from [Jouven2006](@cite) and theses are based on
[Schapendonk1998](@cite).

Parameter, see also [`SimulationParameter`](@ref):
- ``T_0`` (`T₀`) minimum temperature for growth [°C]
- ``T_1`` (`T₁`) lower limit of optimum temperature for growth [°C]
- ``T_2`` (`T₂`) upper limit of optimum temperature for growth [°C]
- ``T_3`` (`T₃`) maximum temperature for growth [°C]

Variables:
- ``T_{txy}`` (`temperature`) mean air temperature [°C]

Output:
- ``TEMP_{txy}`` (`TEMP`) temperature growth factor [-]

![Image of the temperature reducer function](../img/temperature_reducer.svg)
"""
function temperature_reduction!(; container, T)
    @unpack included = container.simp
    @unpack com = container.calc

    if haskey(included, :temperature_growth_reduction) &&
       !included.temperature_growth_reduction
        @info "No temperature reduction!" maxlog=1
        com.TEMP = 1.0
        return nothing
    end

    @unpack T₀, T₁, T₂, T₃ = container.p

    if T < T₀
        com.TEMP = 0.0
    elseif T < T₁
        com.TEMP = (T - T₀) / (T₁ - T₀)
    elseif T < T₂
        com.TEMP = 1.0
    elseif T < T₃
        com.TEMP = (T₃ - T) / (T₃ - T₂)
    else
        com.TEMP = 0.0
    end

    return nothing
end

@doc raw"""
Reduction of growth due to seasonal effects. The function is based on
the yearly cumulative sum of the daily mean temperatures.

```math
\begin{align*}
    SEA_{txy} &=
        \begin{cases}
        SEA_{\text{min}} & \text{if}\;\; ST_{txy} < 200\,\mathrm{K}  \\
        SEA_{\text{min}} + (SEA_{\text{max}} - SEA_{\text{min}}) \cdot \frac{ST_{txy} - 200\,\mathrm{K}}{ST_1 - 400\,\mathrm{K}} &
            \text{if}\;\; 200\,\mathrm{K} < ST_{txy} < ST_1 - 200\,\mathrm{K} \\
        SEA_{\text{max}} & \text{if}\;\; ST_1 - 200\,\mathrm{K} < ST_{txy} < ST_1 - 100\,\mathrm{K} \\
        SEA_{\text{min}} + (SEA_{\text{min}} - SEA_{\text{max}}) \cdot \frac{ST_{txy} - ST_2}{ST_2 - ST_1 - 100\,\mathrm{K}} &
            \text{if}\;\; ST_1 - 100\,\mathrm{K} < ST_{txy} < ST_2 \\
        SEA_{\text{min}} & \text{if}\;\; ST_{txy} > ST_2
        \end{cases} \\
    ST_{txy} &= \sum_{i=t\bmod{365}}^{t} \max\left(0\,\mathrm{K},\, T_{ixy} - 0\,\mathrm{°C}\right)
\end{align*}
```

This empirical function was developed by [Jouven2006](@cite).
A seasonal factor greater than one means that growth is increased
by the use of already stored resources. A seasonal factor below one means that
growth is reduced as the plant stores resources [Jouven2006](@cite).

Parameter, see also [`SimulationParameter`](@ref):
- ``ST_1`` (`ST₁`) is a threshold of the yearly accumulated temperature,
  above which the seasonality factor decreases from ``SEA_{\text{max}}``
  to ``SEA_{\text{min}}`` [K]
- ``ST_2`` (`ST₂`) is a threshold of the yearly accumulated temperature,
  above which the seasonality factor is set to ``SEA_{\text{min}}`` [K]
- ``SEA_{\text{min}}`` (`SEA_min`) is the minimum value of the seasonal effect [-]
- ``SEA_{\text{max}}`` (`SEA_max`) is the maximum value of the seasonal effect [-]

Variables:
- ``ST_{txy}`` (`ST`) yearly cumulative mean air temperature [K]
- ``T_{txy}`` (`temperature`) mean air temperature [°C]

Output:
- ``SEA_{txy}`` (`SEA`) seasonal growth factor [-]

![Image of the seasonal effect function](../img/seasonal_reducer.svg)
"""
function seasonal_reduction!(; container, ST)
    @unpack included = container.simp
    @unpack com = container.calc

    if haskey(included, :season_red) && !included.season_red
        @info "No seasonal reduction!" maxlog=1
        com.SEA = 1.0
        return nothing
    end

    @unpack SEA_min, SEA_max, ST₁, ST₂ = container.p

    if ST < 200.0u"K"
        com.SEA = SEA_min
    elseif ST < ST₁ - 200.0u"K"
        com.SEA = SEA_min + (SEA_max - SEA_min) * (ST - 200.0u"K") / (ST₁ - 400.0u"K")
    elseif ST < ST₁ - 100.0u"K"
        com.SEA = SEA_max
    elseif ST < ST₂
        com.SEA = SEA_min + (SEA_min - SEA_max) * (ST - ST₂) / (ST₂ - (ST₁ - 100.0u"K"))
    else
        com.SEA = SEA_min
    end

    return nothing
end
