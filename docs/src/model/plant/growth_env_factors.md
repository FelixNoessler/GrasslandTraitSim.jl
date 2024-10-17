```@meta
CurrentModule=GrasslandTraitSim
```

# Community growth adjustment by environmental and seasonal factors

```@raw html
<script setup>
    import { onMounted } from 'vue';
    import { radiationReducerPlot } from './d3_plots/RadiationReducer.js';
    import { temperatureReducerPlot } from './d3_plots/TemperatureReducer.js';
    import { seasonalAdjustmentPlot } from './d3_plots/SeasonalAdjustment.js';
    
    onMounted(() => { 
        radiationReducerPlot(); 
        temperatureReducerPlot();
        seasonalAdjustmentPlot();
    });
</script>
```


The functions limit the growth of all plant species without any species-specific reduction:
```mermaid
flowchart LR
    B[[community adjustment by environmental and seasonal factors]]
    L[↓ radiation] -.-> B
    M[↓ temperature] -.-> B
    N[⇅ seasonal factor] -.-> B
click L "growth_env_factors#Radiation-influence" "Go"
click M "growth_env_factors#Temperature-influence" "Go"
click N "growth_env_factors#Seasonal-effect" "Go"
```

## Radiation influence


The growth reducer due to too much radiation ``RAD_{txy}`` [-] is described by: 

```math
RAD_{txy} = \max\left(\min\left(1, 1 - \gamma_1 * \left(PAR_{txys} - \gamma_2\right)\right), 0\right)
```

:::tabs

== Parameter

- ``\gamma_1`` controls the steepness of the linear decrease in
  radiation use efficiency for high ``PAR_{txy}`` values [ha MJ⁻¹]
- ``\gamma_2`` threshold value of ``PAR_{txy}`` from which starts
  a linear decrease in radiation use efficiency [MJ ha⁻¹]
see also [`SimulationParameter`](@ref)

== Variables

inputs:
- ``PAR_{txy}`` photosynthetically active radiation [MJ ha⁻¹]

:::


### Visualization
```@raw html
<table>
    <colgroup>
        <col>
        <col width="120px">
        <col>
    </colgroup>
    <tbody>
    <tr>
        <td>γ₁</td>
        <td><span id="gamma1-value">4.45e-6</span></td>
        <td><input type="range" min="3e-6" max="6e-6" step="0.0000001" value="4.45e-6" id="gamma1" class="radiation_reducer_input"></td>
    </tr>
    <tr>
        <td>γ₂</td>
        <td><span id="gamma2-value">50000</span></td>
        <td><input type="range" min="30000.0" max="70000.0" step="10" value="50000.0" id="gamma2" class="radiation_reducer_input"></td>
    </tr>
    </tbody>
</table>
<svg id="radiation_reducer_graph"></svg>
```

### API
```@docs
radiation_reduction!
```

## Temperature influence

The growth reduction factor due to too low or too high temperature ``TEMP_{txy}`` [-] is described by:

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

:::tabs

== Parameter

- ``T_0`` minimum temperature for growth [°C]
- ``T_1`` lower limit of optimum temperature for growth [°C]
- ``T_2`` upper limit of optimum temperature for growth [°C]
- ``T_3`` maximum temperature for growth [°C]
see also [`SimulationParameter`](@ref)

== Variables

inputs:
- ``T_{txy}`` mean air temperature [°C]

:::

### Visualization
```@raw html
<table>
    <colgroup>
        <col>
        <col width="100px">
        <col>
    </colgroup>
    <tbody>
    <tr>
        <td>T₀</td>
        <td><span id="T0-value">4</span></td>
        <td><input type="range" min="0" max="5" step="0.1" value="4" id="T0" class="temperature_reducer_input"></td>
    </tr>
    <tr>
        <td>T₁</td>
        <td><span id="T1-value">10</span></td>
        <td><input type="range" min="5" max="15" step="0.1" value="10" id="T1" class="temperature_reducer_input"></td>
    </tr>
    <tr>
        <td>T₂</td>
        <td><span id="T2-value">20</span></td>
        <td><input type="range" min="15" max="25" step="0.1" value="20" id="T2" class="temperature_reducer_input"></td>
    </tr>
    <tr>
        <td>T₃</td>
        <td><span id="T3-value">35</span></td>
        <td><input type="range" min="30" max="40" step="0.1" value="35" id="T3" class="temperature_reducer_input"></td>
    </tr>
    </tbody>
</table>
<svg id="temperature_reducer_graph"></svg>
```

### API
```@docs
temperature_reduction!
```

## Seasonal effect

The seasonal growth adjustment factor ``SEA_{txy}`` [-] is desribed by: 

```math
\begin{align}
    SEA_{txy} &=
        \begin{cases}
        SEA_{\min} & \text{if}\;\; ST_{txy} < 200\,°C  \\
        SEA_{\min} + (SEA_{\max} - SEA_{\min}) \cdot \frac{ST_{txy} - 200\,°C}{ST_1 - 400\,°C} &
            \text{if}\;\; 200\,°C < ST_{txy} < ST_1 - 200\,°C \\
        SEA_{\max} & \text{if}\;\; ST_1 - 200\,°C < ST_{txy} < ST_1 - 100\,°C \\
        SEA_{\min} + (SEA_{\min} - SEA_{\max}) \cdot \frac{ST_{txy} - ST_2}{ST_2 - ST_1 - 100\,°C} &
            \text{if}\;\; ST_1 - 100\,°C < ST_{txy} < ST_2 \\
        SEA_{\min} & \text{if}\;\; ST_{txy} > ST_2
        \end{cases} \\
    ST_{txy} &= \sum_{i=t\bmod{365}}^{t} \max\left(0\,°C,\, T_{ixy} - 0\,°C\right)
\end{align}
```

This empirical function was developed by [Jouven2006](@cite).

:::tabs

== Parameter

- ``ST_1`` is a threshold of the yearly accumulated temperature,
  above which the seasonality factor decreases from ``SEA_{\max}``
  to ``SEA_{\min}`` [°C]
- ``ST_2`` is a threshold of the yearly accumulated temperature,
  above which the seasonality factor is set to ``SEA_{\min}`` [°C]
- ``SEA_{\min}`` is the minimum value of the seasonal effect [-]
- ``SEA_{\max}`` is the maximum value of the seasonal effect [-]
see also [`SimulationParameter`](@ref)

== Variables

inputs:
- ``ST_{txy}`` yearly cumulative mean air temperature [°C]
- ``T_{txy}`` mean air temperature [°C]

:::

### Visualization

```@raw html
<table>
    <colgroup>
        <col>
        <col width="50px">
        <col>
    </colgroup>
    <tbody>
    <tr>
        <td>ST₁</td>
        <td><span id="ST1-value">775</span></td>
        <td><input type="range" min="500" max="1000" step="1" value="775" id="ST1" class="seasonal_adj_input"></td>
    </tr>
    <tr>
        <td>ST₂</td>
        <td><span id="ST2-value">1450</span></td>
        <td><input type="range" min="1200" max="1800" step="1" value="1450" id="ST2" class="seasonal_adj_input"></td>
    </tr>
    <tr>
        <td>SEAₘᵢₙ</td>
        <td><span id="SEA_min-value">0.7</span></td>
        <td><input type="range" min="0.2" max="1" step="0.01" value="0.7" id="SEA_min" class="seasonal_adj_input"></td>
    </tr>
    <tr>
        <td>SEAₘₐₓ</td>
        <td><span id="SEA_max-value">1.3</span></td>
        <td><input type="range" min="1" max="3" step="0.01" value="1.3" id="SEA_max" class="seasonal_adj_input"></td>
    </tr>
    </tbody>
</table>
<svg id="seasonal_adjustment_graph"></svg>
```

### API

```@docs
seasonal_reduction!
```