function calibrated_parameter(; input_obj = nothing)
    p = (;
        α_com_height = (truncated(Beta(2.0, 4.0); upper = 0.5), as(Real, 0.0, 0.5),
            """The community height reduction should only apply to plant communities
            with a low community weighted mean plant height,
            so it is limited to 0.0 to 0.5 [m]."""),
        β_com_height = (InverseGamma(4.0, 20.0), asℝ₊,
            """high values of β_com_height lead to a step function, too low values
            lead to a community height reducer of around 0.5 independently of the
            community weighted mean plant height"""),
        α_sen = (Uniform(0, 0.01), as(Real, 0.0, 0.01),
                 """TODO"""),
        β_sen = (truncated(Beta(2, 1); lower = 0.3),  as(Real, 0.3, 1.0),
            """a value of 1 means that the leaf life span is equal to the senescence rate,
            lower values account for for a lower senescence rate for the stem and root
            biomass"""),
        Ψ₁ = (Uniform(700.0, 3000.0), as(Real, 700.0, 3000.0),
            """Jouven (2006) used 775 for this parameter; this parameter should be lower
            than Ψ₂ which is 3000 because otherwise the senescence rate would be
            decreased in autumn"""),
        SEN_max = (truncated(Normal(2.0, 2.0); lower = 1.0, upper = 4.0),
            as(Real, 1.0, 4.0),
            """Jouven (2006) used the value three for this parameter, this means that the
            senescence rate can be three time higher under certain conditions;
            we decided to use a prior from one to four, this means that the senescence rate
            is not increased in autumn (1) to it is strongly increased (4)"""),
        SEA_min = (Uniform(0.5, 1.0), as(Real, 0.5, 1.0), "text"),
        SEA_max = (Uniform(1.0, 2.0), as(Real, 1.0, 2.0), "text"),
        ST₂ = (Uniform(1200.0, 3000.0), as(Real, 1200.0, 3000.0), "text"),
        β_height = (Uniform(0.0, 5.0), as(Real, 0.0, 5.0), "text"),
        β_PAL_lnc = (Uniform(0.0, 5.0), as(Real, 0.0, 5.0), "text"),
        β_TRM = (truncated(Normal(0.0, 2.0); lower = 0.0), asℝ₊, "text"),
        β_TRM_H = (Uniform(0.0, 3.0), as(Real, 0.0, 3.0), "text"),
        α_TRM = (truncated(Normal(10000.0, 1000.0); lower = 0.0), asℝ₊, "text"),
        α_GRZ = (truncated(Normal(500.0, 1000.0); lower = 0.0, upper = 2000.0),
                               as(Real, 0.0, 2000.0), "text"),
        κ = (truncated(Normal(20.0, 2.0); lower = 12.5, upper = 22.5), as(Real, 12.0, 22.5),
            "text"),
        α_lowB = (Uniform(0.0, 500.0), as(Real, 0.0, 500.0), "text"),
        β_lowB = (Uniform(0.0, 1.0), as(Real, 0.0, 1.0), "text"),
        α_TSB = (truncated(Normal(1000.0, 1000.0); lower = 0.0), asℝ₊, "text"),
        β_TSB = (truncated(Normal(1.0, 0.5); lower = 0.0), asℝ₊, "text"),
        α_PET = (Uniform(0.0, 5.0), as(Real, 0.0, 5.0), "text"),
        β_PET = (truncated(Normal(1.0, 1.0); lower = 0.0), asℝ₊, "text"),
        α_TR_sla = (truncated(Normal(0.02, 0.01); lower = 0.0), asℝ₊, "text"),
        β_TR_sla = (truncated(Normal(1.0, 5.0); lower = 0.0), asℝ₊, "text"),
        ϕ_sla = (Uniform(0.01, 0.03), as(Real, 0.01, 0.03), "text"),
        η_min_sla = (Uniform(-1.0, 1.0), as(Real, -1.0, 1.0), "text"),
        η_max_sla = (Uniform(-1.0, 1.0), as(Real, -1.0, 1.0), "text"),
        β_η_sla = (Uniform(0.0, 500.0), as(Real, 0.0, 500.0), "text"),
        β_sla = (Uniform(0.0, 50.0), as(Real, 0.0, 50.0), "text"),
        δ_wrsa = (Uniform(0.0, 1.0), as𝕀, "text"),
        δ_sla = (Uniform(0.0, 1.0), as𝕀, "text"),
        ϕ_amc = (Beta(3.0, 10.0), as𝕀, "text"),
        η_min_amc = (Uniform(-1.0, 1.0), as(Real, -1.0, 1.0), "text"),
        η_max_amc = (Uniform(-1.0, 1.0), as(Real, -1.0, 1.0), "text"),
        κ_red_amc = (Uniform(0.0, 1.0), as𝕀, "text"),
        β_η_amc = (Uniform(0.0, 250.0), as(Real, 0.0, 250.0), "text"),
        β_amc = (Uniform(0.0, 50.0), as(Real, 0.0, 50.0), "text"),
        δ_amc = (Uniform(0.0, 1.0), as𝕀, "text"),
        δ_nrsa = (Uniform(0.0, 1.0), as𝕀, "text"),
        ϕ_rsa = (Uniform(0.1, 0.25), as(Real, 0.1, 0.25), "text"),
        η_min_wrsa = (Uniform(-1.0, 1.0), as(Real, -1.0, 1.0), "text"),
        η_min_nrsa = (Uniform(-1.0, 1.0), as(Real, -1.0, 1.0), "text"),
        η_max_wrsa =(Uniform(-1.0, 1.0), as(Real, -1.0, 1.0), "text"),
        η_max_nrsa =(Uniform(-1.0, 1.0), as(Real, -1.0, 1.0), "text"),
        β_η_wrsa = (Uniform(0.0, 250.0), as(Real, 0.0, 250.0), "text"),
        β_η_nrsa = (Uniform(0.0, 250.0), as(Real, 0.0, 250.0), "text"),
        β_wrsa = (Uniform(0.0, 50.0), as(Real, 0.0, 50.0), "text"),
        β_nrsa = (Uniform(0.0, 50.0), as(Real, 0.0, 50.0), "text"),
        b_biomass = (truncated(Cauchy(0, 300); lower = 0.0), asℝ₊, "text"),
        b_sla = (truncated(Cauchy(0, 0.05); lower = 0.0), asℝ₊, "text"),
        b_lnc = (truncated(Cauchy(0, 0.5); lower = 0.0), asℝ₊, "text"),
        b_amc = (truncated(Cauchy(0, 30); lower = 0.0), asℝ₊, "text"),
        b_height = (truncated(Cauchy(0, 1); lower = 0.0), asℝ₊, "text"),
        b_srsa = (truncated(Cauchy(0, 0.01); lower = 0.0), asℝ₊, "text")
    )

    if !isnothing(input_obj)
        exclude_parameters = exlude_parameter(; input_obj)
        f = collect(keys(p)) .∉ Ref(exclude_parameters)
        p = (; zip(keys(p)[f], collect(p)[f])...)
    end

    prior_vec = first.(collect(p))
    lb = quantile.(prior_vec, 0.0)
    ub = quantile.(prior_vec, 1.0)

    lb = (; zip(keys(p), lb)...)
    ub = (; zip(keys(p), ub)...)
    priordists = (; zip(keys(p), prior_vec)...)
    prior_text = getindex.(collect(p), 3)
    prior_text = replace.(prior_text, "\n" => " ")


    t = as((; zip(keys(p), getindex.(collect(p), 2))...))

    return (; priordists, lb, ub, t, prior_text)
end
