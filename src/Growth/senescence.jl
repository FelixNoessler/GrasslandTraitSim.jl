@doc raw"""
    senescence!(; sen, ST, biomass, μ)

Calculate the biomass that dies due to senescence.

```math
\text{senescence} = μ \cdot \text{SEN} \cdot \text{biomass}
```

The senescence process is based on the senescence rate μ and a
seasonal component of the senescence.

- `μ` leaf senescence rate [d⁻¹], see [`senescence_rate!`](@ref)
- `SEN` seasonal component of the senescence (between 1 and 3),
  see [`seasonal_component_senescence`](@ref)
- `biomass` biomass dry weight [kg ha⁻¹]
"""
function senescence!(; container, ST, biomass)
    @unpack sen = container.calc
    @unpack μ = container.traits

    # include a seasonal effect
    # less senescence in spring,
    # high senescens rate in autumn
    SEN = seasonal_component_senescence(; ST)
    @. sen = μ * SEN * biomass

    return nothing
end

@doc raw"""
    seasonal_component_senescence(;
        ST,
        Ψ₁ = 775,
        Ψ₂ = 3000,
        SENₘᵢₙ = 1,
        SENₘₐₓ = 3)

Seasonal factor for the senescence rate.

```math
\begin{align*}
SEN &=
\begin{cases}
SEN_{min}  & \text{if} \;\; ST < Ψ_1 \\
SEN_{min}+(SEN_{max} - SEN_{min}) \frac{ST - Ψ_1}{Ψ_2 - Ψ_1} & \text{if}\;\; Ψ_1 < ST < Ψ_2 \\
SEN_{max}  & \text{if}\;\; ST > Ψ_2
\end{cases} \\ \\
\end{align*}
```

- ST yearly accumulated degree days [$°C$]
- ``Ψ₁=775``  [$°C\cdot d$]
- ``Ψ₂=3000`` [$°C\cdot d$]
- ``SEN_{min}=1``
- ``SEN_{max}=3``

![Seasonal component death rate](../img/seasonal_factor_senescence.svg)
"""
function seasonal_component_senescence(;
        ST,
        Ψ₁ = 775, #u"°C * d"
        Ψ₂ = 3000, #u"°C * d"
        SENₘᵢₙ = 1,
        SENₘₐₓ = 3)
    ST = ustrip(ST)
    lin_increase(ST) = SENₘᵢₙ + (SENₘₐₓ - SENₘᵢₙ) * (ST - Ψ₁) / (Ψ₂ - Ψ₁)
    SEN = ST < Ψ₁ ? SENₘᵢₙ : ST < Ψ₂ ? lin_increase(ST) : SENₘₐₓ

    return SEN
end

@doc raw"""
    senescence_rate!(; calc, inf_p)

Intialize the senescence rate based on the specific leaf area


```math
\begin{align}
\text{leaflifespan} &= 10^{(2.41 - log_{10}(\text{sla_conv})) / 0.38} \cdot \frac{365.25}{12} \\
\mu &= \frac{\text{sen_α}}{1000} + \frac{\text{sen_leaflifespan}}{1000}
    \cdot \frac{1}{\text{leaflifespan}}
\end{align}
```

First, the leaf life span is calculated based on the specific leaf area. The
equation is taken from [Reich1992](@cite) and was fitted to the the
broad-leaved subset of the LEAVES data set (LEAVES/BROAD in Table 1
of [Reich1992](@cite)). The original equation calculates the leaf life span in months.
The equation was converted to days.

Then, a linear equations is used to relate the leaf life span to the senescence rate
of the plant species. The parameter `sen_α` is the intercept of the linear equation
and models the part of the senescense rate that is not related to the leaf life span.
The parameter `sen_leaflifespan` is the slope of the linear equation and models the
influence of the leaf life span on the senescence rate.

- `sla_conv` specific leaf area [cm²g⁻¹] $\rightarrow$ this includes a unit conversion
  of the sla values (in the model the unit of the specific leaf area is m² g⁻¹)
- `leaflifespan` leaf life span [d]
- `μ` senescence rate [d⁻¹]
- `sen_α` α value of a linear equation that models the influence
  of the leaf span on the senescence rate μ
- `sen_leaflifespan` β value of a linear equation that models
  the influence of the leaf lifespan on the senescence rate μ
"""
function senescence_rate!(; calc, inf_p)
    @unpack sen_α, sen_leaflifespan = inf_p
    @unpack μ, leaflifespan, sla = calc.traits

    @. leaflifespan = 10^( (2.41 - log10(sla * 10000u"g/m^2")) / 0.38) *
        365.25 / 12 * u"d"
    μ .= sen_α / 1000 * u"d^-1" .+ sen_leaflifespan / 1000 ./ leaflifespan

    return nothing
end
