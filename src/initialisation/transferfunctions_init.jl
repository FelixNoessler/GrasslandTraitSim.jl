"""
Initialisation of the transfer functions that link the traits to
the response to water and nutrient stress.
"""
function init_transfer_functions!(; input_obj, prealloc, p)
    @unpack included = input_obj.simp

    if !haskey(included, :water_growth_reduction) || included.water_growth_reduction
        @unpack δ_sla, δ_wrsa, ϕ_rsa, ϕ_sla, η_min_sla, η_max_sla,
                κ_red_wrsa, β_κη_wrsa, β_η_sla, η_max_wrsa, η_min_wrsa = p
        @unpack rsa, sla = prealloc.traits
        @unpack K_wrsa, A_sla, A_wrsa = prealloc.transfer_function

        ##### Specific leaf area
        @. A_sla = η_min_sla + (η_max_sla - η_min_sla) / (1 + exp(-β_η_sla * (sla - ϕ_sla)))

        #### Root surface area per above ground biomass
        @. K_wrsa = 1 - κ_red_wrsa*δ_wrsa / (1 + exp(-β_κη_wrsa * (rsa - ϕ_rsa)))
        @. A_wrsa = η_max_wrsa + (η_min_wrsa - η_max_wrsa) /
            (1 + exp(-β_κη_wrsa * (rsa - ϕ_rsa)))
    end

    if !haskey(included, :nutrient_growth_reduction) || included.nutrient_growth_reduction
        @unpack δ_amc, δ_nrsa, ϕ_amc, ϕ_rsa, η_min_amc, η_max_amc,
                κ_red_amc, κ_red_nrsa, β_κη_amc, β_κη_nrsa,
                η_min_nrsa, η_max_nrsa = p
        @unpack amc, rsa = prealloc.traits
        @unpack K_amc, A_amc, K_nrsa, A_nrsa = prealloc.transfer_function

        #### Arbuscular mycorrhizal colonisation
        for amc_val in amc
            if !(0.0 .<= amc_val .<= 1.0)
                error("$amc (mycorrhizal_colonisation) not between 0 and 1")
            end
        end

        @. A_amc = η_max_amc - (η_max_amc - η_min_amc) /
            (1 + exp(-β_κη_amc * (amc - ϕ_amc)))
        @. K_amc = 1 - κ_red_amc*δ_amc / (1 + exp(-β_κη_amc * (amc - ϕ_amc)))

        #### Root surface area per above ground biomass
        @. K_nrsa = 1 - κ_red_nrsa*δ_nrsa / (1 + exp(-β_κη_nrsa * (rsa - ϕ_rsa)))
        @. A_nrsa = η_max_nrsa + (η_min_nrsa - η_max_nrsa) /
            (1 + exp(-β_κη_nrsa * (rsa - ϕ_rsa)))
    end

    return nothing
end
