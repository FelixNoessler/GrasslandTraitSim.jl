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
