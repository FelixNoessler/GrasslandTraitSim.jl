function model_parameters(;
        likelihood_included = (;
            biomass = true,
            trait = true,
            soilmoisture = true),
        included = (;
            water_growth_reduction = true, nutrient_growth_reduction = true,
            belowground_competition = true, grazing = true, mowing = true,
            defoliation = true, senescence = true, height_competition = true))
    names = [
        "moistureconv_alpha", "moistureconv_beta",
        "β_sen",
        "sla_tr", "sla_tr_exponent",
        "β_pet",
        "biomass_dens",
        "belowground_density_effect",
        "height_strength",
        "leafnitrogen_graz_exp",
        "trampling_factor", "grazing_half_factor",
        "mowing_mid_days",
        "δ_wrsa", "δ_sla",
        "δ_amc", "δ_nrsa",
        "b_biomass", "b_soilmoisture",
        "b_sla", "b_lncm", "b_amc", "b_height", "b_rsa_above"
        ]

    best = [
        -0.8396916069440019, 0.40575461296117304,
         0.16718393481337973,
        0.028051942122749175,
        0.3856413257304432,
        1.16267383992498,
        1349.5087435157145,
        1.575060909640071,
        0.10138624694334897,
        1.6803748450844105,
        0.02,
        118.80750087317014,
        12.494938708379609,
        0.8383157020917221, 0.7691300352241937,
        0.908661756379690, 0.8539014804567874,
        500.0, 500.0,
        0.0005, 0.5, 30.0, 0.05, 0.004
    ]

    prior_dists = (;
        moistureconv_alpha = Normal(0.0, 1.0),
        moistureconv_beta = Normal(0.0, 1.0),
        β_sen = truncated(Normal(0.0, 0.1); lower = 1e-10),
        sla_tr = truncated(Normal(0.02, 0.01); lower = 1e-10),
        sla_tr_exponent = truncated(Normal(1.0, 5.0); lower = 1e-10),
        β_pet = truncated(Normal(1.0, 1.0); lower = 1e-10),
        biomass_dens = truncated(Normal(1000.0, 1000.0); lower = 1e-10),
        belowground_density_effect = truncated(Normal(1.0, 0.5); lower = 1e-10),
        height_strength = Uniform(0.0, 1.0),
        leafnitrogen_graz_exp = truncated(Normal(1.0, 10.0); lower = 1e-10),
        trampling_factor = truncated(Normal(0.0, 0.01); lower = 1e-10),
        grazing_half_factor = truncated(Normal(150.0, 200.0); lower = 1e-10),
        mowing_mid_days = truncated(Normal(10.0, 30.0); lower = 1e-10),
        δ_wrsa = Uniform(0.0, 1.0),
        δ_sla = Uniform(0.0, 1.0),
        δ_amc = Uniform(0.0, 1.0),
        δ_nrsa = Uniform(0.0, 1.0),
        b_biomass = truncated(Cauchy(0, 400); lower = 1e-10),
        b_soilmoisture = truncated(Cauchy(0.0, 400.0); lower = 1e-10),
        b_sla = truncated(Cauchy(0, 0.05); lower = 1e-10),
        b_lncm = truncated(Cauchy(0, 0.5); lower = 1e-10),
        b_amc = truncated(Cauchy(0, 30); lower = 1e-10),
        b_height = truncated(Cauchy(0, 1); lower = 1e-10),
        b_rsa_above = truncated(Cauchy(0, 0.01); lower = 1e-10),
    )

    lb = quantile.(collect(prior_dists), 0.001)
    ub = quantile.(collect(prior_dists), 0.999)

    # ------------------------ check order
    order_correct = collect(keys(prior_dists)) == Symbol.(names)
    if !order_correct
        error("Order of parameters is not correct")
    end

    # ------------------------ exclude parameters if likelihood is not included
    exclude_parameters = String[]
    if ! likelihood_included.biomass
        trait_names = ["b_biomass"]
        append!(exclude_parameters, trait_names)
    end

    if ! likelihood_included.trait
        trait_names = ["b_sla", "b_lncm", "b_amc", "b_height", "b_rsa_above"]
        append!(exclude_parameters, trait_names)
    end

    if ! likelihood_included.soilmoisture
        soilwater_names = ["moistureconv_alpha", "moistureconv_beta", "b_soilmoisture"]
        append!(exclude_parameters, soilwater_names)
    end

    # ------------------------ exclude parameters if process is not included

    if !included.water_growth_reduction
        water_names = ["sla_tr", "sla_tr_exponent", "β_pet", "δ_wrsa", "δ_sla"]
        append!(exclude_parameters, water_names)
    end

    if !included.nutrient_growth_reduction
        nutrient_names = ["δ_amc", "δ_nrsa"]
        append!(exclude_parameters, nutrient_names)
    end

    if !included.belowground_competition
        belowground_names = ["biomass_dens", "belowground_density_effect"]
        append!(exclude_parameters, belowground_names)
    end

    if !included.grazing
        grazing_names = ["grazing_half_factor", "leafnitrogen_graz_exp",
                         "trampling_factor"]
        append!(exclude_parameters, grazing_names)
    end

    if !included.mowing
        mowing_names = ["mowing_mid_days"]
        append!(exclude_parameters, mowing_names)
    end

    if !included.defoliation
        defoliation_names = ["grazing_half_factor", "leafnitrogen_graz_exp",
                             "trampling_factor", "mowing_mid_days"]
        append!(exclude_parameters, defoliation_names)
    end

    if !included.senescence
        senescence_names = ["α_sen", "β_sen"]
        append!(exclude_parameters, senescence_names)
    end

    if !included.height_competition
        height_names = ["height_strength"]
        append!(exclude_parameters, height_names)
    end

    f = names .∉ Ref(exclude_parameters)

    # ------------------------ final parameter tuple
    return (;
            names = names[f], best = best[f],
            prior_dists = collect(prior_dists)[f],
            lb = lb[f], ub = ub[f])
end
