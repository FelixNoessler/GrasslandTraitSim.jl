function calibrated_parameter(; input_obj = nothing)
    p = (;
        α_com_height = (truncated(Normal(0.0, 0.05); lower = 0.0, upper = 2.0),
                        as(Real, 0.0, 2.0),
            """The community height reduction should only apply to plant communities
            with a low community weighted mean plant height"""),

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

        δ_wrsa = (Beta(2, 3), as𝕀, "text"),
        δ_sla = (Beta(2, 3), as𝕀, "text"),
        δ_amc = (Beta(2, 3), as𝕀, "text"),
        δ_nrsa = (Beta(2, 3), as𝕀, "text"),

        η_μ_sla = (Uniform(0, 0.5), as(Real, 0, 0.5), "text"),
        η_μ_amc = (Uniform(0, 0.5), as(Real, 0, 0.5), "text"),
        η_μ_wrsa = (Uniform(0, 0.5), as(Real, 0, 0.5), "text"),
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
