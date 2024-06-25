function sample_prior(priordists)
    p_names = keys(priordists)
    vals = Float64[]
    for p in p_names
        push!(vals, rand(priordists[p]))
    end
    return (; zip(p_names, vals)...)
end

function add_to_p(θ)
    p = SimulationParameter()
    for k in keys(θ)
        p[k] = θ[k] * unit(p[k])
    end
    return p
end

get_priors(p) = (; zip(keys(p), first.(collect(p)))...)
get_transformation(p) = as((; zip(keys(p), getindex.(collect(p), 2))...))
get_priortext(p) = replace.(getindex.(collect(p), 3), "\n" => " ")
get_lowerbound(p) = (; zip(keys(p), quantile.(first.(collect(p)), 0.0))...)
get_upperbound(p) = (; zip(keys(p), quantile.(first.(collect(p)), 1.0))...)s


function calibrated_parameter_fao_irrigated()
    p = (;
        ################ Stronger self-shading for smaller plants => less potential growth
        α_height_per_lai = (truncated(Normal(0, 0.02); lower = 0), asℝ₊,
            """self-shading for community with 0.2 m height with LAI 4
            -> 0.2 / 4 = 0.05  -> growth at this value is half of
            the maximal growth; the parameter is similar to a half-saturation constant
            of a Michaelis-Menten equation"""),

        ################ Radiation growth reducer
        γ₁ = (truncated(Normal(0, 0.000005); lower = 0), asℝ₊,
            """value of original parameter value encoded as prior
            sim.plot_radiation_reducer(;
                θ = sim.add_units(sim.sample_prior(;
                inference_obj = sim.calibrated_parameter_fao_irrigated(;))))"""),
        γ₂ = (truncated(Normal(50000, 10000); lower = 0), asℝ₊,
            """value of original parameter value encoded as prior"""),

        ################ Temperature growth reducer
        T₀ = (truncated(Normal(4, 1); lower = 0, upper = 5), as(Real, 0, 5),
            """lowest value of temperature for growth between 0 and 5,
            original value was 4"""),
        T_opt = (truncated(Normal(15, 2); lower = 13, upper = 22), as(Real, 13, 22),
            """optimal growth around 15 °C, original value encoded as prior"""),
        T_opt_width = (truncated(Normal(5, 2); lower = 3, upper = 8), as(Real, 3, 8),
            """an optimium width of 5 means that if the T_opt is 15, the growth
            is optimal between 15 - 5 = 10 °C and 15 + 5 = 20 °C"""),
        T₃ = (truncated(Normal(35, 2); lower = 32, upper = 42), as(Real, 32, 42),
              """maximal temperature for growth between 32 and 42"""),

        ################ Seasonal growth adjustment
        ST₁ = (truncated(Normal(775, 100); lower = 0, upper = 1000), as(Real, 0, 1000),
            """TODO"""),
        ST₂ = (truncated(Normal(1450, 1000); lower = 1000, upper = 5000),
               as(Real, 1000, 5000),
            """TODO"""),
        SEA_min = (truncated(Normal(1, 0.2); lower = 0, upper = 1), as(Real, 0, 1),
            """TODO"""),
        SEA_max = (truncated(Normal(1, 0.2); lower = 1, upper = 3), as(Real, 1, 3),
            """TODO"""),

        ################ Senescence rate
        α_sen = (truncated(Normal(0.0, 0.0005); lower = 0.0), asℝ₊,
            """TODO"""),

        ################ Seasonal senescence adjustment
        Ψ₁ = (truncated(Normal(775, 200); lower = 0, upper = 1500.0),
              as(Real, 0.0, 1500.0),
              """TODO"""),
        Ψ₂ = (truncated(Normal(3000, 500); lower = 1500, upper = 5000),
              as(Real, 1500, 5000),
              """TODO"""),
        SEN_max = (truncated(Normal(1, 0.5); lower = 1, upper = 4), as(Real, 1, 4),
                   """Senescence in autumn can only increase"""),

        ################ Sepecific for calibration
        b_cumbiomass_fao = (truncated(Normal(0, 500); lower = 0), asℝ₊,
            """TODO"""),
        total_biomass_init_fao = (truncated(Normal(20, 20); lower = 5, upper = 500),
                                  as(Real, 5, 500),
            """TODO"""),)
end

function calibrated_parameter_fao_water_limited()
    p = (;
        R_wrsa_04_Lolium = (Beta(15, 5), as𝕀, "text"),
    )
end


function calibrated_parameter_BE(;)
    p = (;
        β_sen_sla = (truncated(Uniform(0, 1.5); lower = 0.0), as(Real, 0.0, 1.5),
            """TODO"""),

        β_height = (Uniform(0.0, 1.5), as(Real, 0.0, 1.5), "text"),

        β_PAL_lnc = (Uniform(0.0, 1.5), as(Real, 0.0, 1.5), "text"),

        η_GRZ = (truncated(Normal(10.0, 10.0); lower = 0.0, upper = 30.0),
                               as(Real, 0.0, 30.0), "text"),

        α_TSB = (truncated(Normal(18000.0, 1500.0); lower = 0.0), asℝ₊, "text"),
        β_TSB = (truncated(Normal(3, 0.5); lower = 0.0), asℝ₊, "text"),

        α_TR_sla = (truncated(Normal(0.02, 0.01); lower = 0.0), asℝ₊, "text"),
        β_TR_sla = (truncated(Normal(1.0, 5.0); lower = 0.0), asℝ₊, "text"),


        δ_amc = (Beta(2, 3), as𝕀, "text"),
        δ_nrsa = (Beta(2, 3), as𝕀, "text"),

        η_μ_amc = (Uniform(0, 0.5), as(Real, 0, 0.5), "text"),
        η_μ_nrsa =(Uniform(0, 0.5), as(Real, 0, 0.5), "text"),
        η_σ_sla = (Beta(1.0, 5.0), as𝕀, "text"),
        η_σ_amc = (Beta(1.0, 5.0), as𝕀, "text"),
        η_σ_wrsa = (Beta(1.0, 5.0), as𝕀, "text"),
        η_σ_nrsa =(Beta(1.0, 5.0), as𝕀, "text"),

        κ_maxred_amc = (Beta(1.0, 30.0), as𝕀, "text"),
        κ_maxred_srsa = (Beta(1.0, 30.0), as𝕀, "text"),

        b_biomass = (truncated(Cauchy(0, 300); lower = 0.0), asℝ₊, "text"),
        b_sla = (truncated(Cauchy(0, 0.05); lower = 0.0), asℝ₊, "text"),
        b_lnc = (truncated(Cauchy(0, 0.5); lower = 0.0), asℝ₊, "text"),
        b_amc = (truncated(Cauchy(0, 30); lower = 0.0), asℝ₊, "text"),
        b_abp = (truncated(Cauchy(0, 30); lower = 0.0), asℝ₊, "text"),
        b_height = (truncated(Cauchy(0, 1); lower = 0.0), asℝ₊, "text"),
        b_srsa = (truncated(Cauchy(0, 0.01); lower = 0.0), asℝ₊, "text"),
        b_simheight = (truncated(Cauchy(0, 1); lower = 0.0), asℝ₊, "text"),
        b_fdis = (truncated(Cauchy(0, 1); lower = 0.0), asℝ₊, "text"),
    )
end
