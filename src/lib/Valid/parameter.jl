function model_parameters()
    names = [
        "moistureconv_alpha", "moistureconv_beta",
        "sen_α", "sen_leaflifespan",
        "sla_tr", "sla_tr_exponent",
        "biomass_dens",
        "belowground_density_effect",
        "height_strength",
        "leafnitrogen_graz_exp",
        "trampling_factor", "grazing_half_factor",
        "mowing_mid_days",
        "totalN_β", "CN_β",
        "max_rsa_above_water_reduction", "max_SLA_water_reduction",
        "max_AMC_nut_reduction", "max_rsa_above_nut_reduction",
        "b_biomass", "b_soilmoisture",
        "b_sla", "b_lncm", "b_amc", "b_height", "b_rsa_above",
        "b_var_sla", "b_var_lncm", "b_var_amc", "b_var_height", "b_var_rsa_above",]

    best = [
        0.02037577320704022, 1.3344031835366224, 9.594548519615396, 11.793866321332152,
        0.009908918158486471, 2.4959875375040887, 905.1894196309725, 1.243431419474298,
        0.11624675015957471, 2.9221819460701206, 65.13587711112287, 157.3045262441305,
        6.106174292354222, 0.1, 0.1, 0.2530927775106053, 0.8961798337437242, 0.5200095484139818,
        0.7063511868742249, 1295.2142567548983, 19.01215359412841, 0.003958791090577544,
        3.626705514150837, 0.16342654224714848, 0.06186955140054361, 0.014533309346240423,
        6.613912654470809e-5, 20.544957165043726, 0.007630530303688995, 0.0406815972546423,
        0.0011803171892367265]

    prior_dists = (;
        moistureconv_alpha = truncated(Normal(1.0, 10.0); lower=0),# TODO
        moistureconv_beta = truncated(Normal(1.0, 0.5); lower=0),# TODO
        sen_α = truncated(Normal(5.0, 10.0); lower=0),
        sen_leaflifespan = truncated(Normal(5.0, 10.0); lower=0),
        sla_tr = truncated(Normal(0.02, 0.01); lower=0),
        sla_tr_exponent = truncated(Normal(1.0, 5.0); lower=0),
        biomass_dens = truncated(Normal(1000.0, 1000.0); lower=0),
        belowground_density_effect = truncated(Normal(1.0, 0.5); lower=0),
        height_strength = truncated(Normal(0.2, 0.5); lower=0),
        leafnitrogen_graz_exp = truncated(Normal(1.0, 5.0); lower=0),
        trampling_factor = truncated(Normal(200.0, 100.0); lower=0),
        grazing_half_factor = truncated(Normal(150.0, 50.0); lower=0),
        mowing_mid_days = truncated(Normal(10.0, 10.0); lower=0),
        totalN_β = truncated(Normal(0.1, 0.1); lower=0),
        CN_β = truncated(Normal(0.1, 0.1); lower=0),
        max_rsa_above_water_reduction = Uniform(0.0, 1.0),
        max_SLA_water_reduction = Uniform(0.0, 1.0),
        max_AMC_nut_reduction = Uniform(0.0, 1.0),
        max_rsa_above_nut_reduction = Uniform(0.0, 1.0),
        b_biomass = InverseGamma(0.5, 1000.0),
        b_soilmoisture = Normal(0.0, 15.0),# TODO
        b_sla = InverseGamma(10.0, 0.1),
        b_lncm = InverseGamma(2.0, 5.0),
        b_amc = InverseGamma(10.0, 3.0),
        b_height = InverseGamma(10.0, 3.0),
        b_rsa_above = InverseGamma(20.0, 0.2),
        b_var_sla = Normal(0.0, 0.0005), # TODO
        b_var_lncm = Normal(0.0, 10.0),# TODO
        b_var_amc = Normal(0.0, 0.005),# TODO
        b_var_height = Normal(0.0, 0.02),# TODO
        b_var_rsa_above = Normal(0.0, 0.0005)# TODO
    )


    lb = zeros(length(names))
    ub = quantile.(collect(prior_dists), 0.9999)

    mean_tuple = (;
        moistureconv_alpha = 1.0,
        moistureconv_beta = 1.0,
        sen_α = 5.0,
        sen_leaflifespan = 5.0,
        sla_tr = 0.02,
        sla_tr_exponent = 1.0,
        biomass_dens = 1000.0,
        belowground_density_effect = 1.0,
        height_strength = 0.2,
        leafnitrogen_graz_exp = 1.0,
        trampling_factor = 200.0,
        grazing_half_factor = 150.0,
        mowing_mid_days = 10.0,
        totalN_β = 0.1,
        CN_β = 0.1,
        max_rsa_above_water_reduction = 0.5,
        max_SLA_water_reduction = 0.5,
        max_AMC_nut_reduction = 0.5,
        max_rsa_above_nut_reduction = 0.5,

        #### lower bounds for the scale parameters
        b_biomass = 0.0,
        b_soilmoisture = 0.0,
        b_sla = 0.0,
        b_lncm = 0.0,
        b_amc = 0.0,
        b_height = 0.0,
        b_rsa_above = 0.0,
        b_var_sla = 0.0,
        b_var_lncm = 0.0,
        b_var_amc = 0.0,
        b_var_height = 0.0,
        b_var_rsa_above = 0.0)

    sd_tuple = (;
        moistureconv_alpha = 10.0,
        moistureconv_beta = 0.5,
        sen_α = 5.0,
        sen_leaflifespan = 5.0,
        sla_tr = 0.01,
        sla_tr_exponent = 1.0,
        biomass_dens = 200.0,
        belowground_density_effect = 0.5,
        height_strength = 0.5,
        leafnitrogen_graz_exp = 1.0,
        trampling_factor = 200.0,
        grazing_half_factor = 50.0,
        mowing_mid_days = 10.0,
        totalN_β = 0.1,
        CN_β = 0.1,
        max_rsa_above_water_reduction = 5.0,
        max_SLA_water_reduction = 5.0,
        max_AMC_nut_reduction = 5.0,
        max_rsa_above_nut_reduction = 5.0,

        #### sd for the scale parameters
        b_biomass = 1000.0,
        b_soilmoisture = 15.0,
        b_sla = 0.01,
        b_lncm = 5.0,
        b_amc = 0.2,
        b_height = 0.2,
        b_rsa_above = 0.005,
        b_var_sla = 0.0005,
        b_var_lncm = 10.0,
        b_var_amc = 0.005,
        b_var_height = 0.02,
        b_var_rsa_above = 0.0005)

    order_correct = collect(keys(prior_dists)) == Symbol.(names)
    if !order_correct
        error("Order of parameters is not correct")
    end

    exclude_parameters = [
        "moistureconv_alpha", "moistureconv_beta",
        "b_soilmoisture",
        "b_var_sla", "b_var_lncm", "b_var_amc", "b_var_height", "b_var_rsa_above",
    ]
    f = names .∉ Ref(exclude_parameters)

    return (;
            names = names[f], best = best[f],
            prior_dists = collect(prior_dists)[f],
            lb = lb[f], ub = ub[f],
            mean = collect(mean_tuple)[f], sd = collect(sd_tuple)[f])
end
