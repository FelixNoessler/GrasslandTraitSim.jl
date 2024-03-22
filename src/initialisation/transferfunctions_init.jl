"""
Initialisation of the transfer functions that link the traits to
the response to water and nutrient stress.
"""
function init_transfer_functions!(; input_obj, prealloc, p)
    @unpack included = input_obj.simp

    if included.water_growth_reduction
        @unpack δ_sla, δ_wrsa, ϕ_rsa, ϕ_sla, η_min_sla, η_max_sla,
                κ_min_rsa, β_κη_rsa, β_η_sla = p
        @unpack rsa_above, sla = prealloc.traits
        @unpack K_wrsa, H_sla = prealloc.transfer_function

        ##### Specific leaf area
        @. H_sla = η_min_sla + (η_max_sla - η_min_sla) / (1 + exp(-β_η_sla * (sla - ϕ_sla)))

        #### Root surface area per above ground biomass
        @. K_wrsa = 1 - (1 - κ_min_rsa) / (1 + exp(-β_κη_rsa * (rsa_above - ϕ_rsa))) * δ_wrsa
    end

    if included.nutrient_growth_reduction
        @unpack δ_amc, δ_nrsa, ϕ_amc, ϕ_rsa, η_min_amc, η_max_amc,
                κ_min_amc, κ_min_rsa, β_κη_amc, β_κη_rsa = p
        @unpack amc, rsa_above = prealloc.traits
        @unpack K_amc, H_amc, K_nrsa = prealloc.transfer_function

        #### Arbuscular mycorrhizal colonisation
        for amc_val in amc
            if !(0.0 .<= amc_val .<= 1.0)
                error("$amc (mycorrhizal_colonisation) not between 0 and 1")
            end
        end

        @. H_amc = η_max_amc + (η_min_amc - η_max_amc) / (1 + exp(-β_κη_amc * (amc - ϕ_amc)))
        @. K_amc = 1 - (1 - κ_min_amc) / (1 + exp(-β_κη_amc * (amc - ϕ_amc))) * δ_amc

        #### Root surface area per above ground biomass
        @. K_nrsa = 1 - (1 - κ_min_rsa) / (1 + exp(-β_κη_rsa * (rsa_above - ϕ_rsa))) * δ_nrsa
    end

    if included.water_growth_reduction || included.nutrient_growth_reduction
        @unpack ϕ_rsa, η_min_rsa, η_max_rsa, β_κη_rsa = p
        @unpack rsa_above = prealloc.traits
        @unpack H_rsa = prealloc.transfer_function

        #### Root surface area per above ground biomass
        @. H_rsa = η_max_rsa + (η_min_rsa - η_max_rsa) /
        (1 + exp(-β_κη_rsa * (rsa_above - ϕ_rsa)))
    end

    return nothing
end
