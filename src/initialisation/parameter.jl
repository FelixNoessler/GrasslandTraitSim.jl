function exlude_parameter(; input_obj)
    @unpack likelihood_included, included, npatches = input_obj.simp

    excl_p = Symbol[]
    if !likelihood_included.biomass
        append!(excl_p, [:b_biomass])
    end

    if !likelihood_included.trait
        append!(excl_p, [:b_sla, :b_lncm, :b_amc, :b_height, :b_rsa_above])
    end

    if !included.potential_growth
        append!(excl_p, [:RUE_max, :k])
    end

    if isone(npatches) || !included.clonalgrowth
        append!(excl_p, [:clonalgrowth_factor])
    end

    if !included.radiation_red
        append!(excl_p, [:γ1, :γ2])
    end

    if !included.temperature_growth_reduction
        append!(excl_p, [:T₀, :T₁, :T₂, :T₃])
    end

    if !included.season_red
        append!(excl_p, [:SEAₘᵢₙ, :SEAₘₐₓ, :ST₁, :ST₂])
    end

    if !included.water_growth_reduction
        water_names = [:ϕ_sla, :η_min_sla, :η_max_sla, :β_η_sla, :β_sla, :δ_wrsa, :δ_sla]
        append!(excl_p, water_names)
    end

    if !included.nutrient_growth_reduction
        nutrient_names = [:maxtotalN, :ϕ_amc, :η_min_amc, :η_max_amc, :κ_min_amc, :β_κη_amc, :β_amc, :δ_amc, :δ_nrsa]
        append!(excl_p, nutrient_names)
    end

    if !included.nutrient_growth_reduction && !included.water_growth_reduction
        append!(excl_p, [:ϕ_rsa, :η_min_rsa, :η_max_rsa, :κ_min_rsa, :β_κη_rsa, :β_rsa])
    end

    if !included.pet_growth_reduction
        append!(excl_p, [:α_pet, :β_pet])
    end

    if !included.sla_transpiration
        append!(excl_p, [:sla_tr, :sla_tr_exponent])
    end

    if !included.belowground_competition
        append!(excl_p, [:biomass_dens, :belowground_density_effect])
    end

    if !included.grazing
        append!(excl_p, [:leafnitrogen_graz_exp, :κ])
    end

    if !included.trampling
        append!(excl_p, [:trampling_factor, :trampling_height_exp])
    end

    if !included.trampling && !included.grazing
        append!(excl_p, [:grazing_half_factor])
    end

    if !included.mowing
        mowing_names = [:mowing_mid_days, :mowfactor_β]
        append!(excl_p, mowing_names)
    end

    if !included.grazing && !included.mowing
        append!(excl_p, [:lowbiomass, :lowbiomass_k])
    end

    if !included.senescence
        senescence_names = [:α_sen, :β_sen, :α_ll, :β_ll]
        append!(excl_p, senescence_names)
    end

    if !included.senescence || !included.senescence_season
        append!(excl_p, [:Ψ₁, :Ψ₂, :SENₘₐₓ])
    end

    if !included.community_height_red
        append!(excl_p, [:β_community_height, :α_community_height])
    end

    if !included.height_competition
        append!(excl_p, [:height_strength_exp])
    end

    return excl_p
end

function calibrated_parameter(; input_obj = nothing)
    p = (;
        # α_sen = (Uniform(0, 0.1), as(Real, 0.0, 0.1), u"d^-1"),
        β_sen = (Uniform(0.0, 1.0), as𝕀, NoUnits),
        # Ψ₁ = (Uniform(700.0, 3000.0), as(Real, 700.0, 3000.0), NoUnits),
        # SENₘₐₓ = (Uniform(1.0, 4.0), as(Real, 1.0, 4.0), NoUnits),
        # α_community_height = (Uniform(0.0, 20000.0), as(Real, 0.0, 20000.0),
        #                       u"kg / ha"),
        # β_community_height = (Uniform(0.0, 0.01), as(Real, 0.0, 0.01), u"ha / kg"),
        # exp_community_height = (Uniform(0.0, 1.0), as(Real, 0.0, 1.0), NoUnits),
        # height_strength_exp = (Uniform(0.0, 5.0), as(Real, 0.0, 5.0), NoUnits),
        # mowing_mid_days = (truncated(Normal(10.0, 30.0); lower = 0.0, upper = 60.0),
        #                    as(Real, 0.0, 60.0), NoUnits),
        # leafnitrogen_graz_exp = (Uniform(0.0, 5.0), as(Real, 0.0, 5.0), NoUnits),
        # trampling_factor = (truncated(Normal(0.0, 0.05); lower = 0.0), asℝ₊, u"ha"),
        # trampling_height_exp = (Uniform(0.0, 3.0), as(Real, 0.0, 3.0), NoUnits),
        # grazing_half_factor = (truncated(Normal(500.0, 500.0); lower = 0.0, upper = 1000.0),
        #                        as(Real, 0.0, 1000.0), NoUnits),
        # κ = (Uniform(12.0, 22.5), as(Real, 12.0, 22.5), u"kg/d"),
        # lowbiomass = (Uniform(0.0, 500.0), as(Real, 0.0, 500.0), u"kg/ha"),
        # lowbiomass_k = (Uniform(0.0, 5.0), as(Real, 0.0, 5.0), u"ha/kg"),
        # biomass_dens = (truncated(Normal(1000.0, 1000.0); lower = 0.0), asℝ₊, u"kg/ha"),
        # belowground_density_effect = (truncated(Normal(1.0, 0.5); lower = 0.0),
        #                               asℝ₊, NoUnits),
        # α_pet = (Uniform(0.0, 5.0), as(Real, 0.0, 5.0), u"mm/d"),
        # β_pet = (truncated(Normal(1.0, 1.0); lower = 0.0), asℝ₊, u"d/mm"),
        # sla_tr = (truncated(Normal(0.02, 0.01); lower = 0.0), asℝ₊, u"m^2/g"),
        # sla_tr_exponent = (truncated(Normal(1.0, 5.0); lower = 0.0), asℝ₊, NoUnits),
        # ϕ_sla = (Uniform(0.01, 0.03), as(Real, 0.01, 0.03), u"m^2/g"),
        # η_min_sla = (Uniform(-1.0, 1.0), as(Real, -1.0, 1.0), NoUnits),
        # η_max_sla = (Uniform(-1.0, 1.0), as(Real, -1.0, 1.0), NoUnits),
        # β_η_sla = (Uniform(0.0, 500.0), as(Real, 0.0, 500.0), u"g/m^2"),
        # β_sla = (Uniform(0.0, 50.0), as(Real, 0.0, 50.0), NoUnits),
        # δ_wrsa = (Uniform(0.0, 1.0), as𝕀, NoUnits),
        # δ_sla = (Uniform(0.0, 1.0), as𝕀, NoUnits),
        # ϕ_amc = (Uniform(0.1, 0.5), as(Real, 0.1, 0.5), NoUnits),
        # η_min_amc = (Uniform(-1.0, 1.0), as(Real, -1.0, 1.0), NoUnits),
        # η_max_amc = (Uniform(-1.0, 1.0), as(Real, -1.0, 1.0), NoUnits),
        # κ_min_amc = (Uniform(0.0, 1.0), as𝕀, NoUnits),
        # β_κη_amc = (Uniform(0.0, 250.0), as(Real, 0.0, 250.0), NoUnits),
        # β_amc = (Uniform(0.0, 50.0), as(Real, 0.0, 50.0), NoUnits),
        # δ_amc = (Uniform(0.0, 1.0), as𝕀, NoUnits),
        # δ_nrsa = (Uniform(0.0, 1.0), as𝕀, NoUnits),
        # ϕ_rsa = (Uniform(0.1, 0.25), as(Real, 0.1, 0.25), u"m^2/g"),
        # η_min_rsa = (Uniform(-1.0, 1.0), as(Real, -1.0, 1.0), NoUnits),
        # η_max_rsa =(Uniform(-1.0, 1.0), as(Real, -1.0, 1.0), NoUnits),
        # κ_min_rsa = (Uniform(0.0, 1.0), as𝕀, NoUnits),
        # β_κη_rsa = (Uniform(0.0, 250.0), as(Real, 0.0, 250.0), u"g/m^2"),
        # β_rsa = (Uniform(0.0, 50.0), as(Real, 0.0, 50.0), NoUnits),
        # b_biomass = (truncated(Cauchy(0, 300); lower = 0.0), asℝ₊, NoUnits),
        # b_sla = (truncated(Cauchy(0, 0.05); lower = 0.0), asℝ₊, NoUnits),
        # b_lncm = (truncated(Cauchy(0, 0.5); lower = 0.0), asℝ₊, NoUnits),
        # b_amc = (truncated(Cauchy(0, 30); lower = 0.0), asℝ₊, NoUnits),
        # b_height = (truncated(Cauchy(0, 1); lower = 0.0), asℝ₊, NoUnits),
        # b_rsa_above = (truncated(Cauchy(0, 0.01); lower = 0.0), asℝ₊, NoUnits)
    )


    if !isnothing(input_obj)
        exclude_parameters = exlude_parameter(; input_obj)
        f = collect(keys(p)) .∉ Ref(exclude_parameters)
        p = (; zip(keys(p)[f], collect(p)[f])...)
    end

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

@with_kw mutable struct Parameter{T, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, Q15, Q16, Q17, Q18}
    RUE_max::Q1 = F(3 / 1000) * u"kg / MJ" # Maximum radiation use efficiency
    k::T = F(0.6)    # Extinction coefficientw)
    α_sen::Q2 = F(0.0002)u"d^-1"
    β_sen::T = F(0.03) # senescence rate
    α_ll::T = F(2.41)  # specific leaf area --> leaf lifespan
    β_ll::T = F(0.38)  # specific leaf area --> leaf lifespan
    Ψ₁::T = F(775.0)     # temperature threshold: senescence starts to increase
    Ψ₂::T = F(3000.0)    # temperature threshold: senescence reaches maximum
    SENₘₐₓ::T = F(3.0)  # maximal seasonality factor for the senescence rate
    clonalgrowth_factor::T = F(0.05)
    γ1::Q3 = F(0.0445)u"m^2 * d / MJ"
    γ2::Q4 = F(5.0)u"MJ / (m^2 * d)"
    T₀::T = F(3.0)  #u"°C"
    T₁::T = F(12.0) #u"°C"
    T₂::T = F(20.0) #u"°C"
    T₃::T = F(35.0) #u"°C"
    SEAₘᵢₙ::T = F(0.7)
    SEAₘₐₓ::T = F(1.3)
    ST₁::T = F(625.0)
    ST₂::T = F(1300.0)
    α_community_height::Q5 = F(10000.0)u"kg / ha "
    β_community_height::Q6 = F(0.0005)u"ha / kg"
    exp_community_height::T = F(0.9)
    height_strength_exp::T = F(0.5) # strength of height competition
    mowing_mid_days::T = F(10.0) # day where the plants are grown back to their normal size/2
    mowfactor_β::T = F(0.05)
    leafnitrogen_graz_exp::T = F(1.5) # exponent of the leaf nitrogen grazing effect
    trampling_factor::Q7 = F(0.01)u"ha" # trampling factor
    trampling_height_exp::T = F(0.5)
    grazing_half_factor::T = F(500.0) # half saturation constant for grazing
    κ::Q8 = F(22.0)u"kg / d" # maximum grazing rate
    lowbiomass::Q9 = F(100.0)u"kg / ha" # low biomass
    lowbiomass_k::Q10= F(1.0)u"ha / kg" # low biomass k
    biomass_dens::Q11 = F(1200.0)u"kg / ha" # biomass density
    belowground_density_effect::T = F(2.0) # effect of belowground competition
    α_pet::Q12 = F(2.0)u"mm / d"
    β_pet::Q13 = F(1.2)u"d / mm"
    sla_tr::Q14 = F(0.03)u"m^2 / g"
    sla_tr_exponent::T = F(0.4)
    ϕ_sla::Q15 = F(0.025)u"m^2 / g"
    η_min_sla::T = F(-0.8)
    η_max_sla::T = F(0.8)
    β_η_sla::Q16 = F(75.0)u"g / m^2"
    β_sla::T = F(5.0)
    δ_wrsa::T = F(0.8)
    δ_sla::T = F(0.5)
    maxtotalN::T = F(35.0)
    ϕ_amc::T = F(0.35)
    η_min_amc::T = F(0.05)
    η_max_amc::T = F(0.6)
    κ_min_amc::T = F(0.2)
    β_κη_amc::T = F(10.0)
    β_amc::T = F(7.0)
    δ_amc::T = F(0.8)
    δ_nrsa::T = F(0.5)
    ϕ_rsa::Q17 = F(0.12)u"m^2 / g"
    η_min_rsa::T = F(0.05)
    η_max_rsa::T = F(0.6)
    κ_min_rsa::T = F(0.4)
    β_κη_rsa::Q18 = F(40.0)u"g / m^2"
    β_rsa::T = F(7.0)
    b_biomass::T = F(1000.0)
    b_sla::T = F(0.0005)
    b_lncm::T = F(0.5)
    b_amc::T = F(0.001)
    b_height::T = F(0.01)
    b_rsa_above::T = F(0.004)
end


F = Float64
function Parameter(dual_type)
    global F = dual_type
    p = Parameter()
    global F = Float64

    return p
end

Base.getindex(obj::Parameter, k) = getfield(obj, k)
Base.setindex!(obj::Parameter, val, k) = setfield!(obj, k, val)



function fixed_parameter(; input_obj)
    p = (
        RUE_max = 3 / 1000 * u"kg / MJ", # Maximum radiation use efficiency
        k = 0.6,    # Extinction coefficientw)
        α_sen = 0.0002u"d^-1",
        β_sen = 0.03, # senescence rate
        α_ll = 2.41,  # specific leaf area --> leaf lifespan
        β_ll = 0.38,  # specific leaf area --> leaf lifespan
        Ψ₁ = 775.0,     # temperature threshold: senescence starts to increase
        Ψ₂ = 3000.0,    # temperature threshold: senescence reaches maximum
        SENₘₐₓ = 3.0,  # maximal seasonality factor for the senescence rate
        clonalgrowth_factor = 0.05,
        γ1 = 0.0445u"m^2 * d / MJ",
        γ2 = 5.0u"MJ / (m^2 * d)",
        T₀ = 3,  #u"°C"
        T₁ = 12, #u"°C"
        T₂ = 20, #u"°C"
        T₃ = 35, #u"°C"
        SEAₘᵢₙ = 0.7,
        SEAₘₐₓ = 1.3,
        ST₁ = 625,
        ST₂ = 1300,
        α_community_height = 10000.0u"kg / ha",
        β_community_height = 0.0005u"ha / kg",
        exp_community_height = 0.9,
        height_strength_exp = 0.5, # strength of height competition
        mowing_mid_days = 10.0, # day where the plants are grown back to their normal size/2
        mowfactor_β = 0.05,
        leafnitrogen_graz_exp = 1.5, # exponent of the leaf nitrogen grazing effect
        trampling_factor = 0.01u"ha", # trampling factor
        trampling_height_exp = 0.5,
        grazing_half_factor = 500.0, # half saturation constant for grazing
        κ = 22.0u"kg / d", # maximum grazing rate
        lowbiomass = 100.0u"kg / ha", # low biomass
        lowbiomass_k = 1.0u"ha / kg", # low biomass k
        biomass_dens = 1200.0u"kg / ha", # biomass density
        belowground_density_effect = 2.0, # effect of belowground competition
        α_pet = 2.0u"mm / d",
        β_pet = 1.2u"d / mm",
        sla_tr = 0.03u"m^2 / g",
        sla_tr_exponent = 0.4,
        ϕ_sla = 0.025u"m^2 / g",
        η_min_sla = -0.8,
        η_max_sla = 0.8,
        β_η_sla = 75.0u"g / m^2",
        β_sla = 5.0,
        δ_wrsa = 0.8,
        δ_sla = 0.5,
        maxtotalN = 35.0,
        ϕ_amc = 0.35,
        η_min_amc = 0.05,
        η_max_amc = 0.6,
        κ_min_amc = 0.2,
        β_κη_amc = 10.0,
        β_amc = 7.0,
        δ_amc = 0.8,
        δ_nrsa = 0.5,
        ϕ_rsa = 0.12u"m^2 / g",
        η_min_rsa = 0.05,
        η_max_rsa = 0.6,
        κ_min_rsa = 0.4,
        β_κη_rsa = 40.0u"g / m^2",
        β_rsa = 7.0,
        b_biomass = 1000.0,
        b_sla = 0.0005,
        b_lncm = 0.5,
        b_amc = 0.001,
        b_height = 0.01,
        b_rsa_above = 0.004
    )


    return p
    # exclude_parameters = exlude_parameter(; input_obj)
    # f = collect(keys(p)) .∉ Ref(exclude_parameters)

    # return (; zip(keys(p)[f], collect(p)[f])...)
end


function parameter(; input_obj, variable_p = ())
    p = fixed_parameter(; input_obj)
    for k in keys(variable_p)
        p = @set p[k] = variable_p[k]
    end

    return p
end

function parameter(p; input_obj, variable_p = (), inference_obj)
    # for k in keys(variable_p)
    #     p = @set p[k] = variable_p[k] * inference_obj.units[k]
    # end
    @show "hwlloasd"
    return p
end

function add_units(x; inference_obj)
    for p in keys(x)
        x = @set x[p] = x[p] * inference_obj.units[p]
    end

    return x
end

# function add_units(x, y::T; inference_obj) where {T}
#     for p in keys(x)
#         x = @set x[p] = x[p] * inference_obj.units[p]
#     end
#     @show eltype(y)
#     return x::T
# end

function init_parameter(; input_obj, inference_obj)
    fixed_p = fixed_parameter(; input_obj)
    f = collect(keys(fixed_p)) .∈ Ref(keys(inference_obj.units))
    return (; zip(collect(keys(fixed_p))[f], ustrip.(collect(fixed_p)[f]))...)
end
