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

![Image of the radiation reducer function](../img/radiation_reducer.png)
"""
function radiation_reduction!(; container, PAR)
    @unpack included = container.simp
    @unpack com = container.calc

    if !included.radiation_growth_reduction
        @info "No radiation reduction!" maxlog=1
        com.RAD = 1.0
        return nothing
    end

    @unpack γ₁, γ₂ = container.p
    com.RAD = max(min(1.0, 1.0 − γ₁ * (PAR − γ₂)), 0.0)

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

![Image of the temperature reducer function](../img/temperature_reducer.png)
"""
function temperature_reduction!(; container, T)
    @unpack included = container.simp
    @unpack com = container.calc

    if !included.temperature_growth_reduction
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

![Image of the seasonal effect function](../img/seasonal_reducer.png)
"""
function seasonal_reduction!(; container, ST)
    @unpack included = container.simp
    @unpack com = container.calc

    if !included.seasonal_growth_adjustment
        @info "No seasonal reduction!" maxlog=1
        com.SEA = 1.0
        return nothing
    end

    @unpack SEA_min, SEA_max, ST₁, ST₂ = container.p

    if ST < 200.0u"°C"
        com.SEA = SEA_min
    elseif ST < ST₁ - 200.0u"°C"
        com.SEA = SEA_min + (SEA_max - SEA_min) * (ST - 200.0u"°C") / (ST₁ - 400.0u"°C")
    elseif ST < ST₁ - 100.0u"°C"
        com.SEA = SEA_max
    elseif ST < ST₂
        com.SEA = SEA_min + (SEA_min - SEA_max) * (ST - ST₂) / (ST₂ - (ST₁ - 100.0u"°C"))
    else
        com.SEA = SEA_min
    end

    return nothing
end

function plot_radiation_reducer(; PARs = LinRange(0.0, 15.0 * 100^2, 1000)u"MJ / ha",
                           θ = nothing, path = nothing)

    nspecies, container = create_container_for_plotting(; nspecies = 1, θ)
    PARs = sort(ustrip.(PARs)) .* unit(PARs[1])

    y = Float64[]

    for PAR in PARs
        radiation_reduction!(; PAR, container)
        push!(y, container.calc.com.RAD)
    end

    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1];
        ylabel = "Growth reduction (RAD)",
        xlabel = "Photosynthetically active radiation (PAR) [MJ ha⁻¹]",
        title = "Radiation reducer function")

    PARs = ustrip.(PARs)

    if length(y) > 1000
        scatter!(PARs, y,
            markersize = 5,
            color = (:magenta, 0.05))
    else
        lines!(PARs, y,
            linewidth = 3,
            color = :magenta)
    end
    ylims!(-0.05, 1.05)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end

function plot_temperature_reducer(; Ts = collect(LinRange(0.0, 40.0, 500)) .* u"°C",
                            θ = nothing, path = nothing)

    nspecies, container = create_container_for_plotting(; nspecies = 1, θ)

    y = Float64[]
    for T in Ts
        temperature_reduction!(; T, container)
        push!(y, container.calc.com.TEMP)
    end

    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1];
        ylabel = "Growth reduction (TEMP)",
        xlabel = "Air temperature [°C]",
        title = "Temperature reducer function")

    if length(y) > 500
        scatter!(ustrip.(Ts), y,
            markersize = 5,
            color = (:coral3, 0.5))
    else
        lines!(ustrip.(Ts), y,
            linewidth = 3,
            color = :coral3)
    end

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end

function plot_seasonal_effect(; θ = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; nspecies = 1, θ)
    STs = LinRange(0, 3500, 1000)
    y = Float64[]
    for ST in STs
        seasonal_reduction!(; ST = ST * u"°C", container)
        push!(y, container.calc.com.SEA)
    end

    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1];
        ylabel = "Seasonal factor (SEA)",
        xlabel = "Yearly accumulated temperature (ST) [K]",
        title = "Seasonal effect")

    if length(y) > 1000
        scatter!(STs, y;
            markersize = 3,
            color = (:navajowhite4, 0.1))
    else
        lines!(ustrip.(STs), y;
            linewidth = 3,
            color = :navajowhite4)
    end

    ylims!(-0.05, 2.5)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
