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
of the plant species. The parameter `α_sen` is the intercept of the linear equation
and models the part of the senescense rate that is not related to the leaf life span.
The parameter `β_sen` is the slope of the linear equation and models the
influence of the leaf life span on the senescence rate.

```math
\begin{align}
\text{leaflifespan} &= 10^{(2.41 - log_{10}(\text{sla_conv})) / 0.38} \cdot \frac{365.25}{12} \\
\mu &= \text{α_sen} + \text{β_sen} \cdot \frac{1}{\text{leaflifespan}}
\end{align}
```

- `sla_conv` specific leaf area [cm²g⁻¹] $\rightarrow$ this includes a unit conversion
  of the sla values (in the model the unit of the specific leaf area is m² g⁻¹)
- `leaflifespan` leaf life span [d]
- `μ` senescence rate [d⁻¹]
- `α_sen` α value of a linear equation that models the influence
  of the leaf span on the senescence rate μ
- `β_sen` β value of a linear equation that models
  the influence of the leaf lifespan on the senescence rate μ

![](../img/leaflifespan.svg)
"""
function senescence_rate!(; input_obj, calc, p)
    @unpack included = input_obj.simp
    @unpack μ, leaflifespan, sla = calc.traits
    @unpack α_ll, β_ll = p
    @. leaflifespan = 10^((α_ll - log10(sla * 10000u"g/m^2")) / β_ll) *
    365.25 / 12 * u"d"

    if !included.senescence
        @. μ = 0.0u"d^-1"
        return nothing
    end

    @unpack α_sen, β_sen = p
    μ .= α_sen * u"d^-1" .+ β_sen ./ leaflifespan

    return nothing
end
