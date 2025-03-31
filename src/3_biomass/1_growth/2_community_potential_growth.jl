"""
Calculate the total potential growth of the plant community.
"""
function potential_growth!(; container, above_biomass, actual_height, PAR)
    @unpack included = container.simp
    @unpack com = container.calc

    calculate_LAI!(; container, above_biomass)

    if !included.potential_growth || iszero(com.LAItot)
        @info "Zero potential growth!" maxlog=1
        com.growth_pot_total = 0.0u"kg / ha"
        return nothing
    end

    if !included.community_self_shading
        @info "No community height growth reduction!" maxlog=1
        com.RUE_community_height = 1.0
    else
        @unpack relative_height = container.calc
        @unpack α_RUE_cwmH = container.p

        ## community weighted mean height
        relative_height .= above_biomass ./ sum(above_biomass) .* actual_height
        cwm_height = sum(relative_height)

        # α_RUE_cwmH is the growth reduction factor ∈ [0, 1]
        # at a community weighted mean height of 0.2 m
        # 0.4 means that the growth is reduced by 60 % with a community weighted mean height of 0.2 m
        com.RUE_community_height = exp(log(α_RUE_cwmH)*0.2u"m" / cwm_height)
    end

    @unpack γ_RUEmax, γ_RUE_k = container.p
    com.growth_pot_total = PAR * γ_RUEmax * com.RUE_community_height * (1 - exp(-γ_RUE_k * com.LAItot))

    return nothing
end

"""
Calculate the leaf area index of all species.
"""
function calculate_LAI!(; container, above_biomass)
    @unpack LAIs, com = container.calc
    @unpack sla, lbp, abp = container.traits

    for s in eachindex(LAIs)
        LAIs[s] = uconvert(NoUnits, sla[s] * above_biomass[s] * lbp[s])
    end
    com.LAItot = sum(LAIs)

    return nothing
end
