include("2_senescence_init.jl")

@doc raw"""
Calculate the biomass that dies due to senescence.

The basic senescence rate is linked to the specific leaf area via the leaf lifespan. The equation by [Reich1992](@cite) is used for calculating the leaf lifespan based on the specific leaf area (see estimates for LEAVES/BROAD in Table 1 of [Reich1992](@cite)). The original equation calculates the leaf lifespan in months and the specific leaf area in ``cm^2 \cdot g^{-1}``. The specific leaf area was converted to the equation's unit, and the equation was converted to days:
```math
\begin{align*}
    LL_s &= 10^{\left(\alpha_{ll} - \text{log}_{10}(10^4 \cdot SLA_s)\right) /
                    \beta_{ll}} \cdot \frac{365.25}{12} \\
    SEN_{base, s} &= \alpha_{SEN} + \beta_{SEN} \cdot LL_s^{-1}
\end{align*}
```

Parameter, see also [`SimulationParameter`](@ref):
- ``\alpha_{ll}`` (`α_ll`) intercept of the equation that relates the specific leaf area to the leaf lifespan [-]
- ``\beta_{ll}`` (`β_ll`) slope of the equation that relates the specific leaf area to the leaf lifespan [-]
- ``\alpha_{SEN}`` (`α_sen`) intercept of the equation that relates the leaf lifespan to the senescence rate [-]
- ``\beta_{SEN}`` (`β_sen`) slope of the equation that relates the leaf lifespan to the senescence rate [d]

Variables:
- ``SLA_s`` (`sla`) specific leaf area [m² g⁻¹]
- ``LL_s`` (`leaflifespan`) leaf lifespan [d]

Output:
- ``SEN_{base, s}`` (`μ`) basic senescence rate [-]

![](../img/leaflifespan.png)


```math
S_{txys} = μ_s \cdot \text{SEN}_t \cdot B_{txys}
```

The senescence process is based on the senescence rate μ and a
seasonal component of the senescence.

- `μ` basic senescence rate, see [`senescence_rate!`](@ref)
- `SEN` seasonal component of the senescence (between 1 and 3),
  see [`seasonal_component_senescence`](@ref)
- `B` biomass dry weight [kg ha⁻¹]
"""
function senescence!(; container, ST, biomass)
    @unpack senescence, μ, com = container.calc
    @unpack included, time_step_days = container.simp

    com.SEN_season = if included.senescence_season
        seasonal_component_senescence(; container, ST)
    else
        1.0
    end

    @. senescence = (1 - (1 - μ * com.SEN_season) ^ time_step_days.value) * biomass

    return nothing
end

@doc raw"""
Seasonal factor for the senescence rate.

```math
\begin{align*}
SEN &=
\begin{cases}
1  & \text{if} \;\; ST < Ψ_1 \\
1+(SEN_{max} - 1) \frac{ST - Ψ_1}{Ψ_2 - Ψ_1} & \text{if}\;\; Ψ_1 < ST < Ψ_2 \\
SEN_{max}  & \text{if}\;\; ST > Ψ_2
\end{cases} \\ \\
\end{align*}
```

- ``ST`` annual cumulative temperature [$°C$]
- ``Ψ₁=775``  [$°C$]
- ``Ψ₂=3000`` [$°C$]
- ``SEN_{max}=3``

![Seasonal component death rate](../img/seasonal_factor_senescence.png)
"""
function seasonal_component_senescence(; container, ST,)
    @unpack Ψ₁, Ψ₂, SEN_max = container.p

    ST = ustrip(ST)
    lin_increase(ST) = 1 + (SEN_max - 1) * (ST - Ψ₁) / (Ψ₂ - Ψ₁)
    SEN = ST < Ψ₁ ? 1 : ST < Ψ₂ ? lin_increase(ST) : SEN_max

    return SEN
end

function plot_seasonal_component_senescence(;
    STs = LinRange(0, 4000, 500),
    path = nothing)

    nspecies, container = create_container_for_plotting(; nspecies = 1)
    STs = sort(STs)

    y = Float64[]
    for ST in STs
        g = seasonal_component_senescence(; container, ST)
        push!(y, g)
    end

    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1];
        ylabel = "Seasonal factor for senescence (SEN)",
        xlabel = "Annual cumulative temperature (ST) [°C]",
        title = "")

    if length(y) > 1000
        scatter!(STs, y;
            markersize = 3,
            color = (:navajowhite4, 0.1))
    else
        lines!(STs, y;
            linewidth = 3,
            color = :navajowhite4)
    end
    ylims!(-0.05, 3.5)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
