"""
Calculates nutrient index based on total soil nitrogen and fertilization.
"""
function input_nutrients!(; container)
    @unpack nutrients = container.soil_variables
    @unpack totalN, fertilization = container.input
    @unpack included = container.simp
    @unpack ω_NUT_totalN, ω_NUT_fertilization = container.p

    @. nutrients = 1 - exp(-ω_NUT_totalN * totalN -ω_NUT_fertilization * fertilization)

    return nothing
end

"""
Calculates the similarity between plants concerning their investment
in fine roots and collaboration with mycorrhiza.
"""
function similarity_matrix!(; container)
    @unpack nspecies = container.simp
    @unpack amc, rsa = container.traits
    @unpack amc_resid, rsa_resid, TS = container.calc
    @unpack β_TS = container.p

    if isone(nspecies)
        TS .= [1.0;;]
        return nothing
    end

    amc_resid .= (amc .- mean(amc)) ./ std(amc)
    rsa_resid .= (rsa .- mean(rsa)) ./ std(rsa)

    #### if there is (almost) no variation in traits, set residuals to zero
    if (std(amc) < 0.0001)
        amc_resid .= 0.0
    end
    if (std(rsa) < 0.000001u"m^2/g")
        rsa_resid .= 0.0
    end

    for i in Base.OneTo(nspecies)
        for u in Base.OneTo(nspecies)
            TS[i, u] = sqrt((amc_resid[i] - amc_resid[u]) ^ 2 +
                            (rsa_resid[i] - rsa_resid[u]) ^ 2)
        end
    end

    # β_TS scales the trait similiarity matrix, ∈ [0, 2]
    # β_TS close to zero -> no influence of trait similarity
    # with increasing β_TS the influence of trait similarity becomes stronger
    # be careful: if the mean trait similarity changes,
    # the mean plant vailable nutrients (nutrient index) also change
    TS .= (1 .- TS ./ maximum(TS)) .^ β_TS

    return nothing
end

"""
Models the density-dependent competiton for nutrients between plants.
"""
function nutrient_competition!(; container, total_biomass)
    @unpack nutrients_adj_factor, TS_biomass, TS = container.calc
    @unpack included, nspecies = container.simp

    if !included.belowground_competition
        @info "No below ground competition for resources!" maxlog=1
        @. nutrients_adj_factor = 1.0
        return nothing
    end

    @unpack α_NUT_TSB, α_NUT_maxadj = container.p

    TS_biomass .= 0.0u"kg/ha"
    for s in 1:nspecies
        for i in 1:nspecies
            TS_biomass[s] += TS[s, i] * total_biomass[i]
        end
    end

    for i in eachindex(nutrients_adj_factor)
        nutrients_adj_factor[i] = α_NUT_maxadj * exp(log(1/α_NUT_maxadj) / α_NUT_TSB * TS_biomass[i])
    end

    return nothing
end

"""
Reduction of growth based on plant available nutrients and
the traits arbuscular mycorrhizal colonisation and
root surface area per belowground biomass.
"""
function nutrient_reduction!(; container, nutrients, total_biomass)
    @unpack included, nspecies = container.simp
    @unpack NUT = container.calc

    nutrient_competition!(; container, total_biomass)

    if !included.nutrient_growth_reduction
        @info "No nutrient reduction!" maxlog=1
        @. NUT = 1.0
        return nothing
    end

    @unpack R_05, x0 = container.transfer_function
    @unpack nutrients_splitted, nutrients_adj_factor,
            N_amc, N_rsa, above_proportion = container.calc
    @unpack ϕ_TRSA, ϕ_TAMC, α_NUT_amc05, α_NUT_rsa05,
            β_NUT_rsa, β_NUT_amc, δ_NUT_rsa, δ_NUT_amc = container.p
    @unpack amc, rsa = container.traits

    @. nutrients_splitted = nutrients * nutrients_adj_factor

    ###### 1 relate the root surface area per total biomass
    ###### to growth reduction at 0.5 of Np = R_05
    ## inflection of logistic function ∈ [0, 1]
    x0_R_05 = ϕ_TRSA + 1 / δ_NUT_rsa * log((1 - α_NUT_rsa05) / α_NUT_rsa05)

    ## growth reduction at 0.5 of Np ∈ [0, 1]
    # above_proportion = aboveground biomass / total biomass
    # 1 - above_proportion = belowground biomass / total biomass
    # rsa/belowground biomass  * belowground biomass/total biomass = rsa/total biomass
    @. R_05 = 1 / (1 + exp(-δ_NUT_rsa * ((1 - above_proportion) * rsa - x0_R_05)))

    ###### growth reduction due to nutrient stress for different Np
    ## inflection point of logistic function ∈ [0, ∞]
    @. x0 = log((1 - R_05)/ R_05) / β_NUT_rsa + 0.5

    ## growth reduction
    @. N_rsa = 1 / (1 + exp(-β_NUT_rsa * (nutrients_splitted - x0)))


    ###### 2 relate the arbuscular mycorrhizal colonisation
    ###### to growth reduction at 0.5 of Np = R_05
    ## inflection of logistic function ∈ [0, 1]
    x0_R_05 = ϕ_TAMC + 1 / δ_NUT_amc * log((1 - α_NUT_amc05) / α_NUT_amc05)

    ## growth reduction at 0.5 of Np ∈ [0, 1]
    # above_proportion = aboveground biomass / total biomass
    # 1 - above_proportion = belowground biomass / total biomass
    # amc * belowground biomass/total biomass = amc/total biomass
    @. R_05 = 1 / (1 + exp(-δ_NUT_amc * ((1 - above_proportion) * amc - x0_R_05)))

    ###### growth reduction due to nutrient stress for different Np
    ## inflection point of logistic function ∈ [0, ∞]
    @. x0 = log((1 - R_05)/ R_05) / β_NUT_amc + 0.5

    ## growth reduction
    @. N_amc = 1 / (1 + exp(-β_NUT_amc * (nutrients_splitted - x0)))


    ###### 3 calculate the nutrient reduction factor
    @. NUT = max(N_amc, N_rsa)

    for s in 1:nspecies
        if nutrients_splitted[s] <= 0.0
            NUT[s] = 0.0
        elseif nutrients_splitted[s] >= 1.0
            NUT[s] = 1.0
        end
    end

    return nothing
end
