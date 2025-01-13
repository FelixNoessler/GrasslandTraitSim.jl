"""
Simulates the removal of biomass by grazing and trampling for each species.
"""
function grazing!(; container, LD, above_biomass, actual_height)
    @unpack lnc = container.traits
    @unpack η_GRZ, β_GRZ_lnc, β_GRZ_H, κ_GRZ, ϵ_GRZ_minH,
            β_TRM_height, α_TRM_LD = container.p
    @unpack defoliation, grazed_share, relative_lnc, lncinfluence, relative_height, grazed,
            trampled, heightinfluence, biomass_scaled, feedible_biomass = container.calc
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
    @. grazed = grazed_share * total_grazed

    #################################### Trampling
    for s in 1:nspecies
        height_effect_trampling = min((actual_height[s] / 2.0u"m") ^ β_TRM_height, 1.0)
        proportion_trampled = min(height_effect_trampling * LD * α_TRM_LD, 0.5)
        trampled[s] = feedible_biomass[s] * proportion_trampled
    end

    #################################### Add grazed and trampled biomass to defoliation
    defoliation .+= grazed .+ trampled

    return nothing
end
