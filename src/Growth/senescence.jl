@doc raw"""
    senescence!(; sen, ST, biomass, μ)

```math
\begin{align}
    LL &= 10 ^ { \left(log10(SLA)  - 2.41\right) / -0.38} \cdot\frac{365.25}{12} \\
    μ &= \frac{\text{sen_intercept}}{1000} + \frac{\text{sen_rate}}{1000} \cdot \frac{1}{LL} \\
    \text{senescence} &= μ \cdot \text{SEN} \cdot \text{biomass}
\end{align}
```

- LL leaf life span [$d$]
- SLA specific leaf area [$\frac{cm^2}{g}$] $\rightarrow$ this includes a unit conversion of the SLA values (in the model the unit of SLA is $\frac{m^2}{g}$)
- μ leaf senescence rate [$\frac{1}{d}$]
- SEN seasonal component of the senescence (between 1 and 3)
- sen_intercept α value of a linear equation that models the influence of the leaf senescence rate μ on the total senescence rate
- sen_rate β value of a linear equation that models the influence of the leaf senescence rate μ on the total senescence rate

The parameters $\text{sen_intercept}$ and $\text{sen_rate}$ were divided by 1000 to avoid very low numbers.

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

"""
    senescence_rate!(; calc, inf_p)

TBW
"""
function senescence_rate!(; calc, inf_p)
    @. calc.traits.leaflifespan = 10^((log10(calc.traits.sla .* 10000u"g/m^2") - 2.41) /
                                      -0.38) *
                                  365.25 / 12 * u"d"
    sen_α = inf_p.senescence_intercept / 1000
    sen_β = inf_p.senescence_rate / 1000
    calc.traits.μ .= sen_α * u"d^-1" .+ sen_β ./ calc.traits.leaflifespan

    return nothing
end
