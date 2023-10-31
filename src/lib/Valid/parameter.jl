function model_parameters()
    names = [
        "moistureconv_alpha", "moistureconv_beta",
        "senescence_intercept", "senescence_rate",
        "sla_tr", "sla_tr_exponent",
        "nut_dens", "water_dens",
        "belowground_density_effect",
        "height_strength",
        "leafnitrogen_graz_exp",
        "trampling_factor", "grazing_half_factor",
        "mowing_mid_days",
        "max_rsa_above_water_reduction", "max_SLA_water_reduction",
        "max_AMC_nut_reduction", "max_rsa_above_nut_reduction",
        "b_biomass", "b_soilmoisture",
        "b_sla", "b_lncm", "b_amc", "b_height", "b_rsa_above",
        "b_var_sla", "b_var_lncm", "b_var_amc", "b_var_height", "b_var_rsa_above",
    ]
    best = [5.757897,
        1.642053,
        5.568529,
        2.131722,
        0.0209188,
        1.122322,
        1072.062,
        1207.795,
        2.054232,
        0.616476,
        2.618872,
        198.9975,
        102.4847,
        46.11971,
        0.4799059,
        0.6447272,
        0.7082366,
        0.4069509,
        886.0835,
        18.98049,
        0.003373073,
        6.496196,
        0.116174,
        0.292594,
        0.009747849,
        0.0005904804,
        2.097877,
        0.004311672,
        0.004995146,
        0.000266939]

    mean_tuple = (;
        moistureconv_alpha = 30.0,
        moistureconv_beta = 1.0,
        senescence_intercept = 5.0,
        senescence_rate = 5.0,
        sla_tr = 0.02,
        sla_tr_exponent = 1.0,
        nut_dens = 1000.0,
        water_dens = 1000.0,
        belowground_density_effect = 1.0,
        height_strength = 0.2,
        leafnitrogen_graz_exp = 1.0,
        trampling_factor = 200.0,
        grazing_half_factor = 150.0,
        mowing_mid_days = 10.0,
        max_rsa_above_water_reduction = 0.5,
        max_SLA_water_reduction = 0.5,
        max_AMC_nut_reduction = 0.5,
        max_rsa_above_nut_reduction = 0.5,

        #### lower bounds for the scale parameters
        b_biomass = 0.0,
        b_soilmoisture = 0.0, b_sla = 0.0,
        b_lncm = 0.0,
        b_amc = 0.0,
        b_height = 0.0,
        b_rsa_above = 0.0, b_var_sla = 0.0,
        b_var_lncm = 0.0,
        b_var_amc = 0.0,
        b_var_height = 0.0,
        b_var_rsa_above = 0.0)

    sd_tuple = (;
        moistureconv_alpha = 10.0,
        moistureconv_beta = 0.5,
        senescence_intercept = 5.0,
        senescence_rate = 5.0,
        sla_tr = 0.01,
        sla_tr_exponent = 1.0,
        nut_dens = 200.0,
        water_dens = 200.0,
        belowground_density_effect = 0.5,
        height_strength = 0.5,
        leafnitrogen_graz_exp = 1.0,
        trampling_factor = 200.0,
        grazing_half_factor = 50.0,
        mowing_mid_days = 10.0,
        max_rsa_above_water_reduction = 0.2,
        max_SLA_water_reduction = 0.2,
        max_AMC_nut_reduction = 0.2,
        max_rsa_above_nut_reduction = 0.2,

        #### lower bounds for the scale parameters
        b_biomass = 300.0,
        b_soilmoisture = 100.0, b_sla = 0.1,
        b_lncm = 5.0,
        b_amc = 0.2,
        b_height = 0.2,
        b_rsa_above = 0.005, b_var_sla = 0.0005,
        b_var_lncm = 5.0,
        b_var_amc = 0.005,
        b_var_height = 0.02,
        b_var_rsa_above = 0.0005)

    lb_tuple = (;
        moistureconv_alpha = 0.0,
        moistureconv_beta = 0.0,
        senescence_intercept = 0.0,
        senescence_rate = 0.0,
        sla_tr = 0.0,
        sla_tr_exponent = 0.0,
        nut_dens = 500.0,
        water_dens = 500.0,
        belowground_density_effect = 0.0,
        height_strength = 0.0,
        leafnitrogen_graz_exp = 0.0,
        trampling_factor = 0.0,
        grazing_half_factor = 0.0,
        mowing_mid_days = 0.0,
        max_rsa_above_water_reduction = 0.0,
        max_SLA_water_reduction = 0.0,
        max_AMC_nut_reduction = 0.0,
        max_rsa_above_nut_reduction = 0.0,

        #### lower bounds for the scale parameters
        b_biomass = 0.0,
        b_soilmoisture = 0.0, b_sla = 0.0,
        b_lncm = 0.0,
        b_amc = 0.0,
        b_height = 0.0,
        b_rsa_above = 0.0, b_var_sla = 0.0,
        b_var_lncm = 0.0,
        b_var_amc = 0.0,
        b_var_height = 0.0,
        b_var_rsa_above = 0.0)

    ub_tuple = (;
        moistureconv_alpha = 80.0,
        moistureconv_beta = 2.0,
        senescence_intercept = 10.0,
        senescence_rate = 10.0,
        sla_tr = 0.1,
        sla_tr_exponent = 5.0,
        nut_dens = 2500.0,
        water_dens = 2500.0,
        belowground_density_effect = 4.0,
        height_strength = 1.0,
        leafnitrogen_graz_exp = 5.0,
        trampling_factor = 300.0,
        grazing_half_factor = 200.0,
        mowing_mid_days = 50.0,
        max_rsa_above_water_reduction = 1.0,
        max_SLA_water_reduction = 1.0,
        max_AMC_nut_reduction = 1.0,
        max_rsa_above_nut_reduction = 1.0,

        #### upper bounds for the scale parameters
        b_biomass = 1000.0,
        b_soilmoisture = 200.0, b_sla = 0.2,
        b_lncm = 10.0,
        b_amc = 0.5,
        b_height = 0.5,
        b_rsa_above = 0.01, b_var_sla = 0.001,
        b_var_lncm = 10.0,
        b_var_amc = 0.01,
        b_var_height = 0.05,
        b_var_rsa_above = 0.001)

    order_correct = collect(keys(lb_tuple)) == collect(keys(ub_tuple)) == Symbol.(names)
    if !order_correct
        error("Order of parameters is not correct")
    end

    if any(collect(lb_tuple) .> collect(mean_tuple))
        error("Lower bounds are not smaller than mean")
    end

    if any(collect(mean_tuple) .> collect(ub_tuple))
        error("Upper bounds are not larger than mean")
    end

    if any(.!(collect(sd_tuple) .> 0.0))
        error("Standard deviations are not positive")
    end

    return (; names, best,
        lb = collect(lb_tuple), ub = collect(ub_tuple),
        mean = collect(mean_tuple), sd = collect(sd_tuple))
end
