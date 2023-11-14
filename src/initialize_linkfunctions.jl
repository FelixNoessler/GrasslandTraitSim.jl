"""
    amc_nut_response(;
        mycorrhizal_colon,
        max_right_upper_bound = 1,
        min_right_upper_bound = 0.7,
        max_AMC_half_response = 0.6,
        min_AMC_half_response = 0.05,
        mid_AMC = 0.35,
        slope = 10,
        maximal_reduction)

Transforms the mycorrhizal colonisation into parameters
of the response curve of growth in relation to nutrient
availability.
"""
function amc_nut_response(; calc, inf_p,
        max_right_upper_bound = 1,
        min_right_upper_bound = 0.7,
        max_AMC_half_response = 0.6,
        min_AMC_half_response = 0.05,
        mid_AMC = 0.35,
        slope = 10)
    @unpack amc = calc.traits
    @unpack max_AMC_nut_reduction = inf_p
    @unpack amc_nut_upper, amc_nut_midpoint = calc.funresponse
    @unpack K_prep, denominator = calc.calc

    #### check parameter
    for amc_val in amc
        if !(0.0 .<= amc_val .<= 1.0)
            error("$amc (mycorrhizal_colonisation) not between 0 and 1")
        end
    end

    #### Denominator for two logistic functions that
    #### transforms the mycorrizal colonisation to parameters
    #### of the reponse curve of the growth to water availability
    @. denominator = (1 + exp(-slope * (amc - mid_AMC)))

    #### right upper bound of repsonse curve
    bounds_diff = (min_right_upper_bound - max_right_upper_bound)
    @. K_prep = max_right_upper_bound + bounds_diff / denominator

    #### x vlaue of the midpoint of the response curve
    bounds_diff = (min_AMC_half_response - max_AMC_half_response)
    A = 1 - max_AMC_nut_reduction

    @. amc_nut_upper = K_prep + (1 - K_prep) * A
    @. amc_nut_midpoint = max_AMC_half_response + bounds_diff / denominator

    return A
end

"""
    rsa_above_nut_response!(; calc, inf_p,
                                   mid_rsa_above = 0.12u"m^2 / g",
                                   slope_func_parameters = 40u"g / m^2 ",
                                   min_right_upper_bound = 0.7,
                                   max_right_upper_bound = 1,
                                   min_rsa_above_half_response = 0.05,
                                   max_rsa_above_half_response = 0.6)

TBW
"""
function rsa_above_nut_response!(; calc, inf_p,
        mid_rsa_above = 0.12u"m^2 / g",
        slope_func_parameters = 40u"g / m^2 ",
        min_right_upper_bound = 0.7,
        max_right_upper_bound = 1,
        min_rsa_above_half_response = 0.05,
        max_rsa_above_half_response = 0.6)
    @unpack max_rsa_above_nut_reduction = inf_p
    @unpack rsa_above = calc.traits
    @unpack rsa_above_nut_upper, rsa_above_midpoint = calc.funresponse
    @unpack denominator, K_prep = calc.calc

    @. denominator = (1 + exp(-slope_func_parameters * (rsa_above - mid_rsa_above)))

    @. K_prep = max_right_upper_bound +
                (min_right_upper_bound - max_right_upper_bound) / denominator
    @. rsa_above_midpoint = max_rsa_above_half_response +
                            (min_rsa_above_half_response - max_rsa_above_half_response) /
                            denominator

    A = 1 - max_rsa_above_nut_reduction
    @. rsa_above_nut_upper = K_prep + (1 - K_prep) * A

    return A
end

"""
    rsa_above_water_response!(;
    calc, inf_p,
    mid_rsa_above = 0.12u"m^2 / g",
    slope_func_parameters = 40u"g / m^2 ",
    min_right_upper_bound = 0.7,
    max_right_upper_bound = 1,
    min_rsa_above_half_response = 0.05,
    max_rsa_above_half_response = 0.6)

TBW
"""
function rsa_above_water_response!(;
        calc, inf_p,
        mid_rsa_above = 0.12u"m^2 / g",
        slope_func_parameters = 40u"g / m^2 ",
        min_right_upper_bound = 0.7,
        max_right_upper_bound = 1,
        min_rsa_above_half_response = 0.05,
        max_rsa_above_half_response = 0.6)
    @unpack max_rsa_above_water_reduction = inf_p
    @unpack rsa_above = calc.traits
    @unpack rsa_above_water_upper, rsa_above_midpoint = calc.funresponse
    @unpack denominator, K_prep = calc.calc

    @. denominator = @. (1 + exp(-slope_func_parameters * (rsa_above - mid_rsa_above)))

    @. K_prep = @. max_right_upper_bound +
                   (min_right_upper_bound - max_right_upper_bound) / denominator
    @. rsa_above_midpoint = max_rsa_above_half_response +
                            (min_rsa_above_half_response - max_rsa_above_half_response) /
                            denominator

    A = 1 - max_rsa_above_water_reduction

    @. rsa_above_water_upper = K_prep + (1 - K_prep) * A

    return A
end

"""
    sla_water_response!(;
    calc, inf_p,
    mid_SLA = 0.025u"m^2 / g",
    slope_func_parameter = 75u"g / m^2",
    min_SLA_half_response = -0.8,
    max_SLA_half_response = 0.8)

TBW
"""
function sla_water_response!(;
        calc, inf_p,
        mid_SLA = 0.025u"m^2 / g",
        slope_func_parameter = 75u"g / m^2",
        min_SLA_half_response = -0.8,
        max_SLA_half_response = 0.8)
    @unpack sla = calc.traits
    @unpack max_SLA_water_reduction = inf_p
    @unpack sla_water_midpoint = calc.funresponse

    @. sla_water_midpoint = min_SLA_half_response +
                            (max_SLA_half_response - min_SLA_half_response) /
                            (1 + exp(-slope_func_parameter * (sla - mid_SLA)))

    A = 1 - max_SLA_water_reduction

    return A
end
