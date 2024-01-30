@doc raw"""
    senescence!(; container, ST, biomass)

Calculate the biomass that dies due to senescence.

```math
S_{txys} = μ_s \cdot \text{SEN}_t \cdot B_{txys}
```

The senescence process is based on the senescence rate μ and a
seasonal component of the senescence.

- `μ` basic senescence rate [d⁻¹], see [`senescence_rate!`](@ref)
- `SEN` seasonal component of the senescence (between 1 and 3),
  see [`seasonal_component_senescence`](@ref)
- `B` biomass dry weight [kg ha⁻¹]
"""
function senescence!(; container, ST, biomass)
    @unpack sen = container.calc
    @unpack μ = container.traits

    # include a seasonal effect
    # less senescence in spring,
    # high senescens rate in autumn
    SEN = seasonal_component_senescence(; container, ST)
    @. sen = μ * SEN * biomass

    return nothing
end

@doc raw"""
    seasonal_component_senescence(; container, ST)

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

![Seasonal component death rate](../img/seasonal_factor_senescence.svg)
"""
function seasonal_component_senescence(; container, ST,)
    @unpack Ψ₁, Ψ₂, SENₘₐₓ = container.p

    ST = ustrip(ST)
    lin_increase(ST) = 1 + (SENₘₐₓ - 1) * (ST - Ψ₁) / (Ψ₂ - Ψ₁)
    SEN = ST < Ψ₁ ? 1 : ST < Ψ₂ ? lin_increase(ST) : SENₘₐₓ

    return SEN
end
