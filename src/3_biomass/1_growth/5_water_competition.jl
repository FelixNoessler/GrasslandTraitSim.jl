"""
Reduction of growth based on the plant available water
and the root surface area per belowground biomass.
"""
function water_reduction!(; container, W, PWP, WHC)
    @unpack included = container.simp
    @unpack WAT, above_proportion = container.calc
    @unpack R_05, x0 = container.transfer_function
    @unpack rsa = container.traits
    @unpack ϕ_TRSA, α_WAT_rsa05, β_WAT_rsa, δ_WAT_rsa = container.p

    if !included.water_growth_reduction
        @info "No water reduction!" maxlog=1
        @. WAT = 1.0
        return nothing
    end

    Wsc = W > WHC ? 1.0 : W > PWP ? (W - PWP) / (WHC - PWP) : 0.0

    if iszero(Wsc)
        @. WAT = 0.0
    elseif isone(Wsc)
        @. WAT = 1.0
    else
        ###### relate the root surface area per total biomass
        ###### to growth reduction at 0.5 of Wsc = R_05
        ## inflection of logistic function ∈ [0, 1]
        x0_R_05 = ϕ_TRSA + 1.0 / δ_WAT_rsa * log((1.0 - α_WAT_rsa05) / α_WAT_rsa05)

        ## growth reduction at 0.5 of Wsc ∈ [0, 1]
        # above_proportion = aboveground biomass / total biomass
        # 1 - above_proportion = belowground biomass / total biomass
        # rsa/belowground biomass  * belowground biomass/total biomass = rsa/total biomass
        @. R_05 = 1.0 / (1.0 + exp(-δ_WAT_rsa * ((1.0 - above_proportion) * rsa - x0_R_05)))

        ###### growth reduction due to water stress for different Wsc
        ## inflection point of logistic function ∈ [0, ∞]
        @. x0 = log((1.0 - R_05)/ R_05) / β_WAT_rsa + 0.5

        ## growth reduction
        @. WAT = 1.0 / (1.0 + exp(-β_WAT_rsa * (Wsc - x0)))
    end

    return nothing
end
