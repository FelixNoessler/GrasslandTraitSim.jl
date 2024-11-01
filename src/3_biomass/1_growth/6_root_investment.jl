"""
Growth reducer due to cost of investment in roots and mycorriza.
"""
function root_investment!(; container)
    @unpack included = container.simp
    @unpack root_invest_amc, root_invest_srsa,
            ROOT, above_proportion = container.calc
    @unpack amc, rsa = container.traits
    @unpack κ_ROOT_amc, κ_ROOT_rsa, ϕ_TAMC, ϕ_TRSA = container.p

    if !included.root_invest
        @. root_invest_srsa = 1.0
        @. root_invest_amc = 1.0
    else
        @. root_invest_amc = 1 - κ_ROOT_amc + κ_ROOT_amc * exp(log(0.5) / ϕ_TAMC * (1 - above_proportion) * amc)
        @. root_invest_srsa = 1 - κ_ROOT_rsa + κ_ROOT_rsa * exp(log(0.5) / ϕ_TRSA * (1 - above_proportion) * rsa)
    end

    @. ROOT = root_invest_amc * root_invest_srsa

    return nothing
end
