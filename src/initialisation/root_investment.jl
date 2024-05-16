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
    @unpack root_invest_amc, root_invest_rsa, root_invest = prealloc.calc
    @unpack amc, rsa = prealloc.traits
    @unpack output = prealloc

    if !included.root_invest
        @. root_invest_rsa = 1.0
        @. root_invest_amc = 1.0
        @. root_invest = 1.0
        return nothing
    end

    if included.nutrient_growth_reduction
        @. root_invest_amc = 1 - p.κ_red_amc * (amc - 0.2)
        for i in eachindex(root_invest_amc)
            if root_invest_amc[i] < 0.0
                root_invest_amc[i] = 0.0
            elseif root_invest_amc[i] > 1.0
                root_invest_amc[i] = 1.0
            end
        end
    end

    if included.water_growth_reduction || included.nutrient_growth_reduction
        @. root_invest_rsa = 1 - p.κ_red_rsa * (rsa - 0.15u"m^2/g")
        for i in eachindex(root_invest_rsa)
            if root_invest_rsa[i] < 0.0
                root_invest_rsa[i] = 0.0
            elseif root_invest_rsa[i] > 1.0
                root_invest_rsa[i] = 1.0
            end
        end
    end

    @. root_invest = root_invest_amc * root_invest_rsa

    return nothing
end
