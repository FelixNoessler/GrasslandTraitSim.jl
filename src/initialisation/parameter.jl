function calibrated_parameter(; input_obj)
    @unpack likelihood_included, included = input_obj.simp

    p = (;
        # α_sen = (Uniform(0, 0.1), as(Real, 0.0, 0.1), u"d^-1"),
        β_sen = (Uniform(0.0, 1.0), as𝕀, NoUnits),
        height_strength = (Uniform(0.0, 1.0), asℝ₊, NoUnits),
        mowing_mid_days = (truncated(Normal(10.0, 30.0); lower = 0.0, upper = 60.0),
                           as(Real, 0.0, 60.0), NoUnits),
        leafnitrogen_graz_exp = (truncated(Normal(1.0, 10.0); lower = 1e-10),
                                 asℝ₊, NoUnits),
        trampling_factor = (truncated(Normal(0.0, 0.05); lower = 0.0), asℝ₊, u"ha/m"),
        grazing_half_factor = (truncated(Normal(500.0, 500.0); lower = 0.0, upper = 1000.0),
                               as(Real, 0.0, 1000.0), NoUnits),
        biomass_dens = (truncated(Normal(1000.0, 1000.0); lower = 1e-10), asℝ₊, u"kg/ha"),
        belowground_density_effect = (truncated(Normal(1.0, 0.5); lower = 1e-10),
                                      asℝ₊, NoUnits),
        # α_pet = (Uniform(0.0, 5.0), as(Real, 0.0, 5.0), u"mm/d")
        β_pet = (truncated(Normal(1.0, 1.0); lower = 1e-10), asℝ₊, u"d/mm"),
        sla_tr = (truncated(Normal(0.02, 0.01); lower = 1e-10), asℝ₊, u"m^2/g"),
        sla_tr_exponent = (truncated(Normal(1.0, 5.0); lower = 1e-10), asℝ₊, NoUnits),
        # ϕ_sla = 0.025u"m^2 / g",
        # η_min_sla = -0.8,
        # η_max_sla = 0.8,
        # β_η_sla = 75u"g / m^2",
        # β_sla = 5.0,
        δ_wrsa = (Uniform(0.0, 1.0), as𝕀, NoUnits),
        δ_sla = (Uniform(0.0, 1.0), as𝕀, NoUnits),
        # ϕ_amc = 0.35,
        # η_min_amc = 0.05,
        # η_max_amc = 0.6,
        # κ_min_amc = 0.2,
        # β_κη_amc = 10,
        # β_amc = 7.0,
        δ_amc = (Uniform(0.0, 1.0), as𝕀, NoUnits),
        δ_nrsa = (Uniform(0.0, 1.0), as𝕀, NoUnits),
        # ϕ_rsa = 0.12u"m^2 / g",
        # η_min_rsa = 0.05,
        # η_max_rsa = 0.6,
        # κ_min_rsa = 0.4,
        # β_κη_rsa = 40u"g / m^2",
        # β_rsa = 7.0,
        b_biomass = (truncated(Cauchy(0, 300); lower = 1e-10), asℝ₊, NoUnits),
        b_sla = (truncated(Cauchy(0, 0.05); lower = 1e-10), asℝ₊, NoUnits),
        b_lncm = (truncated(Cauchy(0, 0.5); lower = 1e-10), asℝ₊, NoUnits),
        b_amc = (truncated(Cauchy(0, 30); lower = 1e-10), asℝ₊, NoUnits),
        b_height = (truncated(Cauchy(0, 1); lower = 1e-10), asℝ₊, NoUnits),
        b_rsa_above = (truncated(Cauchy(0, 0.01); lower = 1e-10), asℝ₊, NoUnits)
    )

    # ------------------------ exclude parameters if likelihood is not included
    exclude_parameters = Symbol[]
    if ! likelihood_included.biomass
        trait_names = [:b_biomass]
        append!(exclude_parameters, trait_names)
    end

    if ! likelihood_included.trait
        trait_names = [:b_sla, :b_lncm, :b_amc, :b_height, :b_rsa_above]
        append!(exclude_parameters, trait_names)
    end

    # ------------------------ exclude parameters if process is not included
    if !included.water_growth_reduction
        water_names = [:sla_tr, :sla_tr_exponent, :β_pet, :δ_wrsa, :δ_sla]
        append!(exclude_parameters, water_names)
    end

    if !included.nutrient_growth_reduction
        nutrient_names = [:δ_amc, :δ_nrsa]
        append!(exclude_parameters, nutrient_names)
    end

    if !included.belowground_competition
        belowground_names = [:biomass_dens, :belowground_density_effect]
        append!(exclude_parameters, belowground_names)
    end

    if !included.grazing
        grazing_names = [:grazing_half_factor, :leafnitrogen_graz_exp,
                         :trampling_factor]
        append!(exclude_parameters, grazing_names)
    end

    if !included.mowing
        mowing_names = [:mowing_mid_days]
        append!(exclude_parameters, mowing_names)
    end

    if !included.senescence
        senescence_names = [:β_sen]
        append!(exclude_parameters, senescence_names)
    end

    if !included.height_competition
        height_names = [:height_strength]
        append!(exclude_parameters, height_names)
    end

    f = collect(keys(p)) .∉ Ref(exclude_parameters)
    p = (; zip(keys(p)[f], collect(p)[f])...)

    prior_vec = first.(collect(p))
    lb = quantile.(prior_vec, 0.001)
    ub = quantile.(prior_vec, 0.95)


    lb = (; zip(keys(p), lb)...)
    ub = (; zip(keys(p), ub)...)
    priordists = (; zip(keys(p), prior_vec)...)
    units = (; zip(keys(p), last.(collect(p)))...)
    t = as((; zip(keys(p), getindex.(collect(p), 2))...))

    return (; priordists, lb, ub, t, units)
end


function fixed_parameter(; input_obj)
    @unpack included, likelihood_included, npatches = input_obj.simp

    # TODO add all parameters with a fixed value
    p = NamedTuple()

    if included.potential_growth
        p = merge(p, (
            RUE_max = 3 / 1000 * u"kg / MJ", # Maximum radiation use efficiency
            k = 0.6    # Extinction coefficientw)
        ))
    end

    if included.senescence
        p = merge(p, (
            α_sen = 0.0002u"d^-1",
            β_sen = 0.03, # senescence rate
            α_ll = 2.41,  # specific leaf area --> leaf lifespan
            β_ll = 0.38,  # specific leaf area --> leaf lifespan
            Ψ₁ = 775.0,     # temperature threshold: senescence starts to increase
            Ψ₂ = 3000.0,    # temperature threshold: senescence reaches maximum
            SENₘₐₓ = 3.0  # maximal seasonality factor for the senescence rate
        ))
    end

    if npatches > 1 && included.clonalgrowth
        p = merge(p, (
            clonalgrowth_factor = 0.05,
        ))
    end

    if included.radiation_red
        p = merge(p, (
            γ1 = 0.0445u"m^2 * d / MJ",
            γ2 = 5.0u"MJ / (m^2 * d)"
        ))
    end


    if included.temperature_growth_reduction
        p = merge(p, (
            T₀ = 3,  #u"°C"
            T₁ = 12, #u"°C"
            T₂ = 20, #u"°C"
            T₃ = 35 #u"°C"
        ))
    end

    if included.season_red
        p = merge(p, (
            SEAₘᵢₙ = 0.7,
            SEAₘₐₓ = 1.3,
            ST₁ = 625,
            ST₂ = 1300,
        ))
    end

    if included.height_competition
        p = merge(p, (
            height_strength = 0.5, # strength of height competition
        ))
    end

    if included.mowing
        p = merge(p, (
            mowing_mid_days = 15.0, # day where the plants are grown back to their normal size/2
        ))
    end

    if included.grazing
        p = merge(p, (
            leafnitrogen_graz_exp = 1.5, # exponent of the leaf nitrogen grazing effect
            trampling_factor = 0.01u"ha / m", # trampling factor
            grazing_half_factor = 1000.0, # half saturation constant for grazing
            κ = 22.0u"kg / d" # maximum grazing rate
        ))
    end

    if included.belowground_competition
        p = merge(p, (
            biomass_dens = 1200.0u"kg / ha", # biomass density
            belowground_density_effect = 2.0 # effect of belowground competition
        ))
    end

    if included.pet_growth_reduction
        p = merge(p, (
            α_pet = 2.0u"mm / d",
            β_pet = 1.2u"d / mm",
        ))
    end

    if included.sla_transpiration
        p = merge(p, (
            sla_tr = 0.03u"m^2 / g",
            sla_tr_exponent = 0.4,
        ))
    end

    if included.water_growth_reduction
        p = merge(p, (
            ϕ_sla = 0.025u"m^2 / g",
            η_min_sla = -0.8,
            η_max_sla = 0.8,
            β_η_sla = 75u"g / m^2",
            β_sla = 5.0,
            δ_wrsa = 0.8,
            δ_sla = 0.5
        ))
    end

    if included.nutrient_growth_reduction
        p = merge(p, (
            maxtotalN = 35.0,
            ϕ_amc = 0.35,
            η_min_amc = 0.05,
            η_max_amc = 0.6,
            κ_min_amc = 0.2,
            β_κη_amc = 10,
            β_amc = 7.0,
            δ_amc = 0.8,
            δ_nrsa = 0.5
        ))
    end

    if included.nutrient_growth_reduction || included.water_growth_reduction
        p = merge(p, (
            ϕ_rsa = 0.12u"m^2 / g",
            η_min_rsa = 0.05,
            η_max_rsa = 0.6,
            κ_min_rsa = 0.4,
            β_κη_rsa = 40u"g / m^2",
            β_rsa = 7.0,
        ))
    end

    if likelihood_included.biomass
        p = merge(p, (
            b_biomass = 1000.0,
        ))
    end

    if likelihood_included.trait
        p = merge(p, (
            b_sla = 0.0005,
            b_lncm = 0.5,
            b_amc = 0.001,
            b_height = 0.01,
            b_rsa_above = 0.004
        ))
    end

    return p
end


function parameter(; input_obj, variable_p = ())
    fixed_p = fixed_parameter(; input_obj)

    # ------------------------ check if some parameters are already in variable_p
    if any(keys(fixed_p) .∈ Ref(keys(variable_p)))
        f = collect(keys(fixed_p) .∉ Ref(keys(variable_p)))
        fixed_p = (; zip(collect(keys(fixed_p))[f], collect(fixed_p)[f])...)
    end

    return tuplejoin(fixed_p, variable_p)
end

function add_units(x; inference_obj)
    for p in keys(x)
        x = @set x[p] = x[p] * inference_obj.units[p]
    end

    return x
end

function init_parameter(; input_obj, inference_obj)
    fixed_p = fixed_parameter(; input_obj)
    f = collect(keys(fixed_p)) .∈ Ref(keys(inference_obj.units))
    return (; zip(collect(keys(fixed_p))[f], ustrip.(collect(fixed_p)[f]))...)
end
