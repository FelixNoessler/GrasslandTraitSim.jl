function model_parameters(; use_likelihood_biomass = true,
                            use_likelihood_traits = true,
                            use_likelihood_soilwater = true)
    names = [
        "moistureconv_alpha", "moistureconv_beta",
        "α_sen", "β_sen",
        "sla_tr", "sla_tr_exponent",
        "β_pet",
        "biomass_dens",
        "belowground_density_effect",
        "height_strength",
        "leafnitrogen_graz_exp",
        "trampling_factor", "grazing_half_factor",
        "mowing_mid_days",
        "totalN_β", "CN_β",
        "δ_wrsa", "δ_sla",
        "δ_amc", "δ_nrsa",
        "b_biomass", "b_soilmoisture",
        "b_sla", "b_lncm", "b_amc", "b_height", "b_rsa_above"]

    best = [-0.8396916069440019, 0.40575461296117304, 0.004206956275356788, 0.16718393481337973, 0.028051942122749175, 0.3856413257304432, 1.16267383992498, 1349.5087435157145, 1.575060909640071, 0.10138624694334897, 1.6803748450844105, 274.5659308341029, 118.80750087317014, 12.494938708379609, 0.10891372711876313, 0.06029036662014756, 0.8383157020917221, 0.7691300352241937, 0.9086617563796902, 0.8539014804567874, 1175.5314864290444, 7.945037263262286, 0.009931369689262101, 4.548582758895961, 0.28530045557465133, 0.3200877099078715, 0.009312561114905884]

    prior_dists = (;
        moistureconv_alpha = Normal(0.0, 1.0),
        moistureconv_beta = Normal(0.0, 1.0),
        α_sen = truncated(Normal(0.0, 0.1); lower=0),
        β_sen = truncated(Normal(0.0, 0.1); lower=0),
        sla_tr = truncated(Normal(0.02, 0.01); lower=0),
        sla_tr_exponent = truncated(Normal(1.0, 5.0); lower=0),
        β_pet = truncated(Normal(1.0, 1.0); lower=0),
        biomass_dens = truncated(Normal(1000.0, 1000.0); lower=0),
        belowground_density_effect = truncated(Normal(1.0, 0.5); lower=0),
        height_strength = Uniform(0.0, 1.0),
        leafnitrogen_graz_exp = truncated(Normal(1.0, 5.0); lower=0),
        trampling_factor = truncated(Normal(200.0, 100.0); lower=0),
        grazing_half_factor = truncated(Normal(150.0, 50.0); lower=0),
        mowing_mid_days = truncated(Normal(10.0, 10.0); lower=0),
        totalN_β = truncated(Normal(0.1, 0.1); lower=0),
        CN_β = truncated(Normal(0.1, 0.1); lower=0),
        δ_wrsa = Uniform(0.0, 1.0),
        δ_sla = Uniform(0.0, 1.0),
        δ_amc = Uniform(0.0, 1.0),
        δ_nrsa = Uniform(0.0, 1.0),
        b_biomass = InverseGamma(5.0, 2000.0),
        b_soilmoisture = truncated(Normal(0.0, 15.0); lower = 0),
        b_sla = InverseGamma(10.0, 0.1),
        b_lncm = InverseGamma(2.0, 5.0),
        b_amc = InverseGamma(10.0, 3.0),
        b_height = InverseGamma(10.0, 3.0),
        b_rsa_above = InverseGamma(20.0, 0.2),
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

    f = names .∉ Ref(exclude_parameters)

    # ------------------------ final parameter tuple
    return (;
            names = names[f], best = best[f],
            prior_dists = collect(prior_dists)[f],
            lb = lb[f], ub = ub[f])
end
