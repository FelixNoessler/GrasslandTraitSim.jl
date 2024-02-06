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
        "β_sen",
        "sla_tr", "sla_tr_exponent",
        "β_pet",
        "biomass_dens",
        "belowground_density_effect",
        "height_strength",
        "leafnitrogen_graz_exp",
        "trampling_factor", "grazing_half_factor",
        "mowing_mid_days",
        # "δ_wrsa", "δ_sla",
        "δ_amc", "δ_nrsa",
        "b_biomass",
        # "b_soilmoisture",
        "b_sla", "b_lncm", "b_amc", "b_height", "b_rsa_above"
        ]

    best = [
        0.03, # β_sen
        0.03, 0.4, # sla_tr, sla_tr_exponent
        1.2, # β_pet
        1200.0, # biomass_dens
        2.0, # belowground_density_effect
        0.5, # height_strength
        1.5, # leafnitrogen_graz_exp
        0.01, # trampling_factor
        1000.0, # grazing_half_factor
        15.0, # mowing_mid_days
        # 0.8, 0.5, # δ_wrsa, δ_sla
        0.8, 0.5, # δ_amc, δ_nrsa
        100.0, # b_biomass,
        # 0.01, #b_soilmoisture
        0.0005, 0.5, 0.001, 0.01, 0.004 # b_sla, b_lncm, b_amc, b_height, b_rsa_above
    ]

    prior_dists = (;
        β_sen = Uniform(0.0, 1.0),
        sla_tr = truncated(Normal(0.02, 0.01); lower = 1e-10),
        sla_tr_exponent = truncated(Normal(1.0, 5.0); lower = 1e-10),
        β_pet = truncated(Normal(1.0, 1.0); lower = 1e-10),
        biomass_dens = truncated(Normal(1000.0, 1000.0); lower = 1e-10),
        belowground_density_effect = truncated(Normal(1.0, 0.5); lower = 1e-10),
        height_strength = Uniform(0.0, 1.0),
        leafnitrogen_graz_exp = truncated(Normal(1.0, 10.0); lower = 1e-10),
        trampling_factor = truncated(Normal(0.0, 0.01); lower = 1e-10),
        grazing_half_factor = truncated(Normal(500.0, 500.0); lower = 1e-10),
        mowing_mid_days = truncated(Normal(10.0, 30.0); lower = 1e-10),
        # δ_wrsa = Uniform(0.0, 1.0),
        # δ_sla = Uniform(0.0, 1.0),
        δ_amc = Uniform(0.0, 1.0),
        δ_nrsa = Uniform(0.0, 1.0),
        b_biomass = truncated(Cauchy(0, 300); lower = 1e-10),
        # b_soilmoisture = truncated(Cauchy(0.0, 400.0); lower = 1e-10),
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

    if !included.senescence
        senescence_names = ["β_sen"]
        append!(exclude_parameters, senescence_names)
    end

    if !included.height_competition
        height_names = ["height_strength"]
        append!(exclude_parameters, height_names)
    end

    f = names .∉ Ref(exclude_parameters)


    # ------------------------ transform to unconstrained space with TransformVariables.jl
    t_prep = (;
        β_sen = as𝕀,
        sla_tr = asℝ₊,
        sla_tr_exponent = asℝ₊,
        β_pet = asℝ₊,
        biomass_dens = asℝ₊,
        belowground_density_effect = asℝ₊,
        height_strength = asℝ₊,
        leafnitrogen_graz_exp = asℝ₊,
        trampling_factor = asℝ₊,
        grazing_half_factor = asℝ₊,
        mowing_mid_days = asℝ₊,
        # δ_wrsa = as𝕀,
        # δ_sla = as𝕀,
        δ_amc = as𝕀,
        δ_nrsa = as𝕀,
        b_biomass = asℝ₊,
        b_sla = asℝ₊,
        b_lncm = asℝ₊,
        b_amc = asℝ₊,
        b_height = asℝ₊,
        b_rsa_above = asℝ₊
    )

    t = as((; zip(keys(t_prep)[f], collect(t_prep)[f])...))

    # ------------------------ final parameter tuple
    return (; names = names[f], best = best[f], prior_dists = collect(prior_dists)[f],
            t, t_vec = collect(t_prep)[f], lb = lb[f], ub = ub[f])
end
