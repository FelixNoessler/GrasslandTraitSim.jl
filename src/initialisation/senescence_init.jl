@doc raw"""
    senescence_rate!(; calc, inf_p)

Intialize the senescence rate based on the specific leaf area

In order to derive the senescence rate, the leaf life span is calculated first.
The equation on how to derive the leaf life span based on the specific leaf area is
taken from [Reich1992](@cite) and was fitted to the
broad-leaved subset of the LEAVES data set (LEAVES/BROAD in Table 1
of [Reich1992](@cite)). The original equation calculates the leaf life span in months.
The equation was converted to days.

Then, the parameter $\beta_{\text{sen}}$ is used to downscale the inverse of the leaf life span because the overall senescence rate of the aboveground biomass is lower than the inverse of the leaf life span:

```math
\begin{align}
\text{leaflifespan} &= 10^{(2.41 - log_{10}(\text{sla_conv})) / 0.38} \cdot \frac{365.25}{12} \\
\mu &= \text{β_sen} \cdot \frac{1}{\text{leaflifespan}}
\end{align}
```

- `sla_conv` specific leaf area [cm²g⁻¹] $\rightarrow$ this includes a unit conversion
  of the sla values (in the model the unit of the specific leaf area is m² g⁻¹)
- `leaflifespan` leaf life span [d]
- `μ` senescence rate [d⁻¹]
  of the leaf span on the senescence rate μ
- `β_sen` β value of a linear equation that models
  the influence of the leaf lifespan on the senescence rate μ

![](../img/leaflifespan.svg)
"""
function senescence_rate!(; input_obj, prealloc, p)
    @unpack included = input_obj.simp
    @unpack sla = prealloc.traits
    @unpack μ, leaflifespan =  prealloc.calc

    if !included.senescence
        @. μ = 0.0u"d^-1"
        @. leaflifespan = 0.0u"d"
        return nothing
    end

    @unpack α_ll, β_ll, α_sen, β_sen = p
    @. leaflifespan = 10^((α_ll - log10(sla * 10000u"g/m^2")) / β_ll) *
    365.25 / 12 * u"d"
    μ .= α_sen .+ β_sen ./ leaflifespan

    return nothing
end
