"""
Simulates the removal of biomass by grazing for each species.
"""
function grazing!(; container, LD, above_biomass, actual_height)
    @unpack lnc = container.traits
    @unpack η_GRZ, β_GRZ_lnc, β_GRZ_H, κ_GRZ, ϵ_GRZ_minH = container.p
    @unpack defoliation, grazed_share, relative_lnc, lncinfluence, relative_height, grazed,
            heightinfluence, biomass_scaled, feedible_biomass = container.calc
    @unpack nspecies = container.simp

    for s in 1:nspecies
        height_proportion_feedible = max(1 - ϵ_GRZ_minH / actual_height[s], 0.0)
        feedible_biomass[s] = height_proportion_feedible * above_biomass[s]
    end

    sum_feedible_biomass = sum(feedible_biomass)

    if iszero(sum_feedible_biomass)
        container.calc.com.fodder_supply = κ_GRZ * LD
        @. grazed = 0.0u"kg/ha"
        defoliation .+= grazed
        return nothing
    end

    #################################### Total grazed biomass
    feedible_biomass_squarred = sum_feedible_biomass * sum_feedible_biomass
    α_GRZ = κ_GRZ * LD * η_GRZ
    total_grazed = κ_GRZ * LD * feedible_biomass_squarred /
                  (α_GRZ * α_GRZ + feedible_biomass_squarred)

    container.calc.com.fodder_supply = κ_GRZ * LD - total_grazed

    #################################### Share of grazed biomass per species
    ## Grazers feed more on plants with high leaf nitrogen content
    relative_lnc .= lnc .* feedible_biomass ./ sum_feedible_biomass
    cwm_lnc = sum(relative_lnc)
    @. lncinfluence = (lnc / cwm_lnc) ^ β_GRZ_lnc

    ## Grazers feed more on tall plants
    relative_height .= actual_height .* feedible_biomass ./ sum_feedible_biomass
    cwm_height = sum(relative_height)
    @. heightinfluence = (actual_height / cwm_height) ^ β_GRZ_H

    @. biomass_scaled = heightinfluence * lncinfluence * feedible_biomass
    grazed_share .= biomass_scaled ./ sum(biomass_scaled)

    #################################### Add grazed biomass to defoliation
    @. grazed = grazed_share * total_grazed
    defoliation .+= grazed

    return nothing
end
