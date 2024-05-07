@doc raw"""

Investment into root and mycorriza


```math
\begin{align}
invest &= \exp(\kappa\_{red, amc} \cdot acm) \cdot abp \\
\end{align}
```

![](../img/root_investment.svg)
"""
function root_investment!(; input_obj, prealloc, p)
    @unpack included = input_obj.simp
    @unpack root_invest = prealloc.calc
    @unpack amc, rsa, abp = prealloc.traits
    @unpack output = prealloc

    root_invest .= 1.0

    if included.nutrient_growth_reduction
        @. root_invest *= exp(-p.κ_red_amc * amc)
    end

    if included.water_growth_reduction || included.nutrient_growth_reduction
        @. root_invest *= exp(-p.κ_red_rsa * rsa)
    end

    root_invest .*= abp

    output.root_invest .= root_invest

    return nothing
end
