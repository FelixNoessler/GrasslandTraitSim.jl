@doc raw"""

Investment into root and mycorriza


```math
\begin{align}
invest &= \exp(\kappa\_{red, amc} \cdot acm) \cdot abp \\
\end{align}
```

![](../img/root_investment.png)
"""
function root_investment!(; input_obj, prealloc, p)
    @unpack included = input_obj.simp
    @unpack root_invest_amc, root_invest_srsa, root_invest = prealloc.calc
    @unpack amc, srsa = prealloc.traits
    @unpack output = prealloc

    if !included.root_invest
        @. root_invest_srsa = 1.0
        @. root_invest_amc = 1.0
    else
        @. root_invest_amc = 1 - p.κ_maxred_amc / (1 + exp(-p.β_red_amc * (amc - p.ϕ_amc)))
        @. root_invest_srsa = 1 - p.κ_maxred_srsa / (1 + exp(-p.β_red_rsa * (srsa - p.ϕ_rsa)))
    end

    @. root_invest = root_invest_amc * root_invest_srsa

    return nothing
end
