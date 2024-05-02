"""
Initialisation of the transfer functions that link the traits to
the response to water and nutrient stress.
"""
function init_transfer_functions!(; input_obj, prealloc, p)
    @unpack included = input_obj.simp

    if !haskey(included, :water_growth_reduction) || included.water_growth_reduction
        @unpack δ_sla, δ_wrsa, ϕ_rsa, ϕ_sla, η_min_sla, η_max_sla,
                β_η_wrsa, β_η_sla, η_max_wrsa, η_min_wrsa = p
        @unpack rsa, sla = prealloc.traits
        @unpack A_sla, A_wrsa = prealloc.transfer_function

        ##### Specific leaf area
        @. A_sla = η_min_sla + (η_max_sla - η_min_sla) / (1 + exp(-β_η_sla * (sla - ϕ_sla)))

        #### Root surface area per above ground biomass
        @. A_wrsa = η_max_wrsa + (η_min_wrsa - η_max_wrsa) /
            (1 + exp(-β_η_wrsa * (rsa - ϕ_rsa)))
    end

    if !haskey(included, :nutrient_growth_reduction) || included.nutrient_growth_reduction
        @unpack δ_amc, δ_nrsa, ϕ_amc, ϕ_rsa, η_min_amc, η_max_amc,
                β_η_amc, β_η_nrsa,
                η_min_nrsa, η_max_nrsa = p
        @unpack amc, rsa = prealloc.traits
        @unpack A_amc, A_nrsa = prealloc.transfer_function

        #### Arbuscular mycorrhizal colonisation
        for amc_val in amc
            if !(0.0 .<= amc_val .<= 1.0)
                error("$amc (mycorrhizal_colonisation) not between 0 and 1")
            end
        end

        @. A_amc = η_max_amc - (η_max_amc - η_min_amc) /
            (1 + exp(-β_η_amc * (amc - ϕ_amc)))


        #### Root surface area per above ground biomass
        @. A_nrsa = η_max_nrsa + (η_min_nrsa - η_max_nrsa) /
            (1 + exp(-β_η_nrsa * (rsa - ϕ_rsa)))
    end

    return nothing
end


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
    @unpack amc, abp = prealloc.traits
    @unpack output = prealloc

    if !haskey(included, :nutrient_growth_reduction) || included.nutrient_growth_reduction
        @. root_invest = exp(-p.κ_red_amc * amc) * abp
    else
        @. root_invest = 1.0 * abp
    end

    @. output.root_invest = root_invest

    return nothing
end
