function calibrated_parameter_fao_irrigated()
    p = (;
        α_height_per_lai = (truncated(Normal(0, 0.02); lower = 0), asℝ₊,
            """self-shading for community with 0.2 m height with LAI 4
            -> 0.2 / 4 = 0.05  -> growth at this value is half of
            the maximal growth; the parameter is similar to a half-saturation constant
            of a Michaelis-Menten equation"""),

        γ₁ = (truncated(Normal(0, 0.000005); lower = 0), asℝ₊,
            """value of original parameter value encoded as prior
            sim.plot_radiation_reducer(;
                θ = sim.add_units(sim.sample_prior(;
                inference_obj = sim.calibrated_parameter_fao_irrigated(;))))"""),
        γ₂ = (truncated(Normal(50000, 10000); lower = 0), asℝ₊,
            """value of original parameter value encoded as prior"""),

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
        # T₁ = (truncated(Normal(0, 0.05); lower = 0, upper = 2),
        #       as(Real, 0, 2),
        #       """TODO"""),
        # T₂ = (truncated(Normal(0, 0.05); lower = 0, upper = 2),
        #       as(Real, 0, 2),
        #       """TODO"""),

        ST₁ = (truncated(Normal(775, 100); lower = 0, upper = 1000), as(Real, 0, 1000),
            """TODO"""),
        ST₂ = (truncated(Normal(1450, 1000); lower = 1000), as(Real, 1000, Inf),
            """TODO"""),
        SEA_min = (truncated(Normal(1, 0.2); lower = 0, upper = 1), as(Real, 0, 1),
            """TODO"""),
        SEA_max = (truncated(Normal(1, 0.2); lower = 1, upper = 2), as(Real, 1, 2),
            """TODO"""),

        α_sen = (truncated(Normal(0.0, 0.0005); lower = 0.0), asℝ₊,
            """TODO"""),

        Ψ₁ = (truncated(Normal(775, 200); lower = 0, upper = 1500.0),
              as(Real, 0.0, 2.0),
              """TODO"""),
        Ψ₂ = (truncated(Normal(3000, 500); lower = 1500), as(Real, 1500.0, Inf),
              """TODO"""),
        SEN_max = (truncated(Normal(1, 0.5); lower = 1), as(Real, 1, Inf),
                   """Senescence in autumn can only increase"""),)

    prepare_calibration_obj(; p)
end
