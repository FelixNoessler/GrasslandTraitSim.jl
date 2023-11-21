function model_parameters(; use_likelihood_biomass = true,
                            use_likelihood_traits = true,
                            use_likelihood_soilwater = true,
                            use_likelihood_trait_var = true)
    names = [
        "moistureconv_alpha", "moistureconv_beta",
        "sen_α", "sen_leaflifespan",
        "sla_tr", "sla_tr_exponent",
        "βₚₑₜ",
        "biomass_dens",
        "belowground_density_effect",
        "height_strength",
        "leafnitrogen_graz_exp",
        "trampling_factor", "grazing_half_factor",
        "mowing_mid_days",
        "totalN_β", "CN_β",
        "max_rsa_above_water_reduction", "max_sla_water_reduction",
        "max_amc_nut_reduction", "max_rsa_above_nut_reduction",
        "b_biomass", "b_soilmoisture",
        "b_sla", "b_lncm", "b_amc", "b_height", "b_rsa_above",
        "b_var_sla", "b_var_lncm", "b_var_amc", "b_var_height", "b_var_rsa_above",]

    best = [0.21651602851309687, 0.009080524259062913, 0.0022507510254258373, 0.4182589039462492, 0.029649325167562544, 3.082555885130148, 0.02049211588764277, 854.4614603568936, 1.100089893534349, 0.17993881467364325, 9.341204546398654, 124.78994460980397, 158.78495903196819, 22.08006294455497, 0.18650959184142935, 0.07936480911148232, 0.9707610587585661, 0.7121330159290473, 0.3877113437861343, 0.42223360948269534, 1046.5984727631396, 4.936100774508173, 0.013943348787610315, 4.3167910984713105, 0.20720690473608316, 0.6404617014196398, 0.014366500360505423, 0.0, 0.0, 0.0, 0.0, 0.0]

    prior_dists = (;
        moistureconv_alpha = Normal(0.0, 1.0),# TODO
        moistureconv_beta = Normal(0.0, 1.0),# TODO
        sen_α = truncated(Normal(0.0, 1.0); lower=0),
        sen_leaflifespan = truncated(Normal(0.0, 1.0); lower=0),
        sla_tr = truncated(Normal(0.02, 0.01); lower=0),
        sla_tr_exponent = truncated(Normal(1.0, 5.0); lower=0),
        βₚₑₜ = truncated(Normal(1.0, 1.0); lower=0),
        biomass_dens = truncated(Normal(1000.0, 1000.0); lower=0),
        belowground_density_effect = truncated(Normal(1.0, 0.5); lower=0),
        height_strength = Uniform(0.0, 1.0),
        leafnitrogen_graz_exp = truncated(Normal(1.0, 5.0); lower=0),
        trampling_factor = truncated(Normal(200.0, 100.0); lower=0),
        grazing_half_factor = truncated(Normal(150.0, 50.0); lower=0),
        mowing_mid_days = truncated(Normal(10.0, 10.0); lower=0),
        totalN_β = truncated(Normal(0.1, 0.1); lower=0),
        CN_β = truncated(Normal(0.1, 0.1); lower=0),
        max_rsa_above_water_reduction = Uniform(0.0, 1.0),
        max_sla_water_reduction = Uniform(0.0, 1.0),
        max_amc_nut_reduction = Uniform(0.0, 1.0),
        max_rsa_above_nut_reduction = Uniform(0.0, 1.0),
        b_biomass = InverseGamma(5.0, 2000.0),
        b_soilmoisture = truncated(Normal(0.0, 15.0); lower = 0),# TODO
        b_sla = InverseGamma(10.0, 0.1),
        b_lncm = InverseGamma(2.0, 5.0),
        b_amc = InverseGamma(10.0, 3.0),
        b_height = InverseGamma(10.0, 3.0),
        b_rsa_above = InverseGamma(20.0, 0.2),
        b_var_sla = truncated(Normal(0.0, 0.0005); lower = 0), # TODO
        b_var_lncm = truncated(Normal(0.0, 10.0); lower = 0),# TODO
        b_var_amc = truncated(Normal(0.0, 0.005); lower = 0),# TODO
        b_var_height = truncated(Normal(0.0, 0.02); lower = 0),# TODO
        b_var_rsa_above = truncated(Normal(0.0, 0.0005); lower = 0)# TODO
    )


    lb = quantile.(collect(prior_dists), 0.001)
    ub = quantile.(collect(prior_dists), 0.999)

    # ------------------------ check order
    order_correct = collect(keys(prior_dists)) == Symbol.(names)
    if !order_correct
        error("Order of parameters is not correct")
    end

    # ------------------------ exclude parameters
    exclude_parameters = String[]
    if !use_likelihood_biomass
        trait_names = ["b_biomass"]
        append!(exclude_parameters, trait_names)
    end

    if !use_likelihood_traits
        trait_names = ["b_sla", "b_lncm", "b_amc", "b_height", "b_rsa_above"]
        append!(exclude_parameters, trait_names)
    end

    if !use_likelihood_soilwater
        soilwater_names = ["moistureconv_alpha", "moistureconv_beta", "b_soilmoisture"]
        append!(exclude_parameters, soilwater_names)
    end

    if !use_likelihood_trait_var
        trait_var_names = ["b_var_sla", "b_var_lncm", "b_var_amc",
                           "b_var_height", "b_var_rsa_above"]
        append!(exclude_parameters, trait_var_names)
    end
    f = names .∉ Ref(exclude_parameters)


    # ------------------------ final parameter tuple
    return (;
            names = names[f], best = best[f],
            prior_dists = collect(prior_dists)[f],
            lb = lb[f], ub = ub[f])
end
