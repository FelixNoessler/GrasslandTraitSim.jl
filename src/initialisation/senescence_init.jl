@doc raw"""
    senescence_rate!(; calc, inf_p)

Intialize the senescence rate based on the specific leaf area

In order to derive the senescence rate, the leaf life span is calculated first.
The equation on how to derive the leaf life span based on the specific leaf area is
taken from [Reich1992](@cite) and was fitted to the
broad-leaved subset of the LEAVES data set (LEAVES/BROAD in Table 1
of [Reich1992](@cite)). The original equation calculates the leaf life span in months.
The equation was converted to days.

Then, a linear equations is used to relate the leaf life span to the senescence rate
of the plant species. The parameter `sen_α` is the intercept of the linear equation
and models the part of the senescense rate that is not related to the leaf life span.
The parameter `sen_leaflifespan` is the slope of the linear equation and models the
influence of the leaf life span on the senescence rate.

```math
\begin{align}
\text{leaflifespan} &= 10^{(2.41 - log_{10}(\text{sla_conv})) / 0.38} \cdot \frac{365.25}{12} \\
\mu &= \text{sen_α} + \text{sen_leaflifespan} \cdot \frac{1}{\text{leaflifespan}}
\end{align}
```

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

    μ .= sen_α * u"d^-1" .+ sen_leaflifespan ./ leaflifespan

    return nothing
end
