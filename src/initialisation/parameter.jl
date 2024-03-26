"""
    SimulationParameter(; kwargs...)

Here is an overview of the parameters that are used in the model. The parameters are...
$(FIELDS)
"""
@with_kw mutable struct SimulationParameter{T, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9,
                                  Q10, Q11, Q12, Q13, Q14, Q15, Q16} @deftype T

    """
    Maximum radiation use efficiency, \\
    see [`potential_growth!`](@ref) \\
    """
    RUE_max::Q1 = F(3 / 1000) * u"kg / MJ"

    """
    Extinction coefficient, \\
    see [`potential_growth!`](@ref) \\
    """
    k = F(0.6)

    """
    is the community weighted mean height, where the community height growth reducer is 0.5, \\
    see [`potential_growth!`](@ref) \\
    """
    α_comH::Q7 = F(0.5)u"m"

    """
    is the slope of the logistic function that relates the community weighted mean height to the community height growth reducer, \\
    see [`potential_growth!`](@ref) \\
    """
    β_comH::Q8 = F(5.0)u"m^-1"

    """
    senescence rate-intercept of a linear equation that relate the leaf life span to the senescence rate, \\
    see [`senescence_rate!`](@ref) \\
    """
    α_sen = F(0.0002)

    """
    slope of a linear equation that relates the leaf life span to the senescence rate, \\
    see [`senescence_rate!`](@ref) \\
    """
    β_sen::Q2 = F(0.03)u"d"

    """
    transform SLA to leaflifespan,\\
    equation given by [Reich1992](@cite) \\
    """
    α_ll = F(2.41)

    """
    transform SLA to leaflifespan,\\
    equation given by [Reich1992](@cite) \\
    """
    β_ll = F(0.38)

    """
    emperature threshold: senescence starts to increase, \\
    see [`seasonal_component_senescence`](@ref) \\
    """
    Ψ₁ = F(775.0)

    """
    temperature threshold: senescence reaches maximum, \\
    see [`seasonal_component_senescence`](@ref) \\
    """
    Ψ₂ = F(3000.0)

    """
    maximal seasonality factor for the senescence rate, \\
    see [`seasonal_component_senescence`](@ref) \\
    """
    SENₘₐₓ = F(3.0)

    """
    Proportion of biomass that growths to the neighbouring cells, \\
    see [`clonalgrowth!`](@ref) \\
    """
    clonalgrowth_factor = F(0.05)

    """
    is the empirical parameter for a decrease in radiation use efficiency
    for values of the photosynthetically active radiation (PAR) higher than `γ2`, \\
    see [`radiation_reduction`](@ref)
    """
    γ1::Q3 = F(0.0445)u"m^2 / MJ"

    """
    is the threshold value of PAR from which starts a linear decrease
    in radiation use efficiency, \\
    see [`radiation_reduction`](@ref) \\
    """
    γ2::Q4 = F(5.0)u"MJ / m^2"

    """
    is the lower temperature threshold for growth, \\
    see [`temperature_reduction`](@ref) \\
    """
    T₀::Q5 = F(3.0)u"°C"

    """
    is the lower bound for the optimal temperature for growth, \\
    see [`temperature_reduction`](@ref) \\
    """
    T₁::Q5 = F(12.0)u"°C"

    """
    is the upper bound for the optiomal temperature for growth, \\
    see [`temperature_reduction`](@ref) \\
    """
    T₂::Q5 = F(20.0)u"°C"

    """
    is the maximum temperature for growth, \\
    see [`temperature_reduction`](@ref) \\
    """
    T₃::Q5 = F(35.0)u"°C"

    """
    is the minimum value of the seasonal effect, \\
    see [`seasonal_reduction`](@ref) \\
    """
    SEAₘᵢₙ = F(0.7)

    """
    is the maximum value of the seasonal effect, \\
    see [`seasonal_reduction`](@ref) \\
    """
    SEAₘₐₓ = F(1.3)

    """
    is a threshold of the temperature degree days,
    above which the seasonality factor is set to `SEAₘᵢₙ` and
    descreases to `SEAₘₐₓ`, 898.15K = 625 °C, \\
    see [`seasonal_reduction`](@ref) \\
    """
    ST₁::Q6 = F(898.15)u"K"

    """
    is a threshold of the temperature degree-days,
    where the seasonality growth factor is set to `SEAₘᵢₙ`, 1573.15 K = 1300.0 °C, \\
    see [`seasonal_reduction`](@ref) \\
    """
    ST₂::Q6 = F(1573.15)u"K"

    """
    controls how strongly taller plants gets more light for growth, \\
    see [`light_competition!`](@ref) \\
    """
    β_H = F(0.5)

    """
    number of days after a mowing event when the plants are grown back to
    half of their normal size, \\
    see [`mowing!`](@ref) \\
    """
    mowing_mid_days = F(10.0)
    mowfactor_β = F(0.05)

    """
    controls how strongly grazers prefer plant species with high leaf nitrogen content, \\
    see [`grazing!`](@ref) \\
    """
    leafnitrogen_graz_exp = F(1.5)

    """
    defines together with the height of the plants and the livestock density
    the proportion of biomass that is trampled [ha m⁻¹], \\
    see [`trampling!`](@ref) \\
    """
    trampling_factor::Q9 = F(0.01)u"ha"
    trampling_height_exp = F(0.5)
    trampling_half_factor = F(10000.0)

    """
    total biomass [kg ha⁻¹] when the daily consumption by grazers reaches half
    of their maximal consumption defined by κ · livestock density, \\
    see [`grazing!`](@ref) \\
    """
    grazing_half_factor = F(1000.0)

    """"
    maximal consumption of a livestock unit per day, \\
    see [`grazing!`](@ref) \\
    """
    κ::Q10 = F(22.0)u"kg"
    lowbiomass::Q11 = F(100.0)u"kg / ha"

    """
    if the matrix multiplication between the trait similarity matrix and
    the biomass equals `biomass_dens` the available water and nutrients
    for growth are not in- or decreased,
    see [`below_ground_competition!`](@ref) \\
    """
    biomass_dens::Q11 = F(1200.0)u"kg / ha"
    lowbiomass_k::Q12 = F(0.1)u"ha / kg"

    """
    the available water and nutrients are in- or decreased
    if the matrix multiplication between the trait similarity matrix and
    the biomass of the species is above or below of `biomass_dens`,
    see [`below_ground_competition!`] \\
    """
    belowground_density_effect = F(2.0)
    α_pet::Q13 = F(2.0)u"mm"
    β_pet::Q14 = F(1.2)u"mm^-1"

    """
    reference community weighted mean specific leaf area,
    if the community weighted mean specific leaf area is
    equal to `sla_tr` then transpiration is neither increased nor decreased,
    see `transpiration`](@ref) \\
    """
    sla_tr::Q15 = F(0.03)u"m^2 / g"

    """
    controls how strongly a community mean specific leaf area that deviates
    from `sla_tr` is affecting the transpiration,
    see [`transpiration`](@ref) \\
    """
    sla_tr_exponent = F(0.4)
    ϕ_sla::Q15 = F(0.025)u"m^2 / g"
    η_min_sla = F(-0.8)
    η_max_sla = F(0.8)
    β_η_sla::Q16 = F(75.0)u"g / m^2"
    β_sla = F(5.0)

    """
    maximal reduction of the plant-available water linked to the trait root surface area /
    aboveground biomass,
    see [`init_transfer_functions!`](@ref) \\
    """
    δ_wrsa = F(0.8)

    """
    maximal reduction of the plant-available water linked to the trait specific leaf area,
    see [`init_transfer_functions!`](@ref) \\
    """
    δ_sla = F(0.5)

    """
    based on the maximum total N of ≈ 30.63 [g kg⁻¹] in the data from the
    Biodiversity Exploratories \\
    [explo14446v19](@cite)[explo18787v6](@cite)[explo23846v10](@cite)[explo31210v6](@cite),
    see [`input_nutrients!`](@ref) \\
    """
    maxtotalN = F(35.0)
    ϕ_amc = F(0.35)
    η_min_amc = F(0.05)
    η_max_amc = F(0.6)
    κ_min_amc = F(0.2)
    β_κη_amc = F(10.0)
    β_amc = F(7.0)

    """
    maximal reduction of the plant-available nutrients linked to the trait
    arbuscular mycorrhizal colonisation rate,\\
    see [`init_transfer_functions!`](@ref) \\
    """
    δ_amc = F(0.5)

    """
    maximal reduction of the plant-available nutrients linked to the trait
    root surface area / aboveground biomass,\\
    see [`init_transfer_functions!`](@ref) \\
    """
    δ_nrsa = F(0.5)
    ϕ_rsa::Q15 = F(0.12)u"m^2 / g"
    η_min_rsa = F(0.05)
    η_max_rsa = F(0.6)
    κ_min_rsa = F(0.4)
    β_κη_rsa::Q16 = F(40.0)u"g / m^2"
    β_rsa = F(7.0)
    b_biomass = F(1000.0)
    inv_ν_biomass = F(0.2)
    b_sla = F(0.0005)
    b_lncm = F(0.5)
    b_amc = F(0.001)
    b_height = F(0.01)
    b_rsa_above = F(0.004)
end

function exlude_parameter(; input_obj)
    @unpack likelihood_included, included, npatches = input_obj.simp

    excl_p = Symbol[]
    if !likelihood_included.biomass
        append!(excl_p, [:b_biomass, :inv_ν_biomass])
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
        append!(excl_p, [:leafnitrogen_graz_exp, :κ, :grazing_half_factor])
    end

    if !included.trampling
        append!(excl_p, [:trampling_factor, :trampling_half_factor, :trampling_height_exp])
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
        append!(excl_p, [:α_comH, :β_comH])
    end

    if !included.height_competition
        append!(excl_p, [:β_H])
    end

    return excl_p
end

function calibrated_parameter(; input_obj = nothing)
    p = (;
        # α_comH = (Uniform(-5.0, 5.0), as(Real, -5.0, 5.0)),
        # β_comH = (Uniform(-10.0, 0.0), as(Real, -10.0, 0.0)),
        α_sen = (Uniform(0, 0.01), as(Real, 0.0, 0.01)),
        β_sen = (Uniform(0.0, 0.1),  as(Real, 0.0, 0.1)),
        Ψ₁ = (Uniform(700.0, 3000.0), as(Real, 700.0, 3000.0)),
        SENₘₐₓ = (Uniform(1.0, 4.0), as(Real, 1.0, 4.0)),
        SEAₘᵢₙ = (Uniform(0.5, 1.0), as(Real, 0.5, 1.0)),
        SEAₘₐₓ = (Uniform(1.0, 2.0), as(Real, 1.0, 2.0)),
        β_H = (Uniform(0.0, 5.0), as(Real, 0.0, 5.0)),
        mowing_mid_days = (truncated(Normal(10.0, 30.0); lower = 0.0, upper = 60.0),
                           as(Real, 0.0, 60.0)),
        leafnitrogen_graz_exp = (Uniform(0.0, 5.0), as(Real, 0.0, 5.0)),
        trampling_factor = (truncated(Normal(0.0, 0.05); lower = 0.0), asℝ₊),
        trampling_height_exp = (Uniform(0.0, 3.0), as(Real, 0.0, 3.0)),
        trampling_half_factor = (truncated(Normal(10000.0, 1000.0); lower = 0.0), asℝ₊),
        grazing_half_factor = (truncated(Normal(500.0, 1000.0); lower = 0.0, upper = 2000.0),
                               as(Real, 0.0, 2000.0)),
        κ = (Uniform(12.0, 22.5), as(Real, 12.0, 22.5)),
        lowbiomass = (Uniform(0.0, 500.0), as(Real, 0.0, 500.0)),
        lowbiomass_k = (Uniform(0.0, 1.0), as(Real, 0.0, 1.0)),
        biomass_dens = (truncated(Normal(1000.0, 1000.0); lower = 0.0), asℝ₊),
        belowground_density_effect = (truncated(Normal(1.0, 0.5); lower = 0.0),
                                      asℝ₊),
        α_pet = (Uniform(0.0, 5.0), as(Real, 0.0, 5.0)),
        β_pet = (truncated(Normal(1.0, 1.0); lower = 0.0), asℝ₊),
        sla_tr = (truncated(Normal(0.02, 0.01); lower = 0.0), asℝ₊),
        sla_tr_exponent = (truncated(Normal(1.0, 5.0); lower = 0.0), asℝ₊),
        ϕ_sla = (Uniform(0.01, 0.03), as(Real, 0.01, 0.03)),
        η_min_sla = (Uniform(-1.0, 1.0), as(Real, -1.0, 1.0)),
        η_max_sla = (Uniform(-1.0, 1.0), as(Real, -1.0, 1.0)),
        β_η_sla = (Uniform(0.0, 500.0), as(Real, 0.0, 500.0)),
        β_sla = (Uniform(0.0, 50.0), as(Real, 0.0, 50.0)),
        δ_wrsa = (Uniform(0.0, 1.0), as𝕀),
        δ_sla = (Uniform(0.0, 1.0), as𝕀),
        ϕ_amc = (Uniform(0.1, 0.5), as(Real, 0.1, 0.5)),
        η_min_amc = (Uniform(-1.0, 1.0), as(Real, -1.0, 1.0)),
        η_max_amc = (Uniform(-1.0, 1.0), as(Real, -1.0, 1.0)),
        κ_min_amc = (Uniform(0.0, 1.0), as𝕀),
        β_κη_amc = (Uniform(0.0, 250.0), as(Real, 0.0, 250.0)),
        β_amc = (Uniform(0.0, 50.0), as(Real, 0.0, 50.0)),
        δ_amc = (Uniform(0.0, 1.0), as𝕀),
        δ_nrsa = (Uniform(0.0, 1.0), as𝕀),
        ϕ_rsa = (Uniform(0.1, 0.25), as(Real, 0.1, 0.25)),
        η_min_rsa = (Uniform(-1.0, 1.0), as(Real, -1.0, 1.0)),
        η_max_rsa =(Uniform(-1.0, 1.0), as(Real, -1.0, 1.0)),
        κ_min_rsa = (Uniform(0.0, 1.0), as𝕀),
        β_κη_rsa = (Uniform(0.0, 250.0), as(Real, 0.0, 250.0)),
        β_rsa = (Uniform(0.0, 50.0), as(Real, 0.0, 50.0)),
        b_biomass = (truncated(Cauchy(0, 300); lower = 0.0), asℝ₊),
        inv_ν_biomass = (Uniform(0.0, 0.5), as(Real, 0.0, 0.5)),
        b_sla = (truncated(Cauchy(0, 0.05); lower = 0.0), asℝ₊),
        b_lncm = (truncated(Cauchy(0, 0.5); lower = 0.0), asℝ₊),
        b_amc = (truncated(Cauchy(0, 30); lower = 0.0), asℝ₊),
        b_height = (truncated(Cauchy(0, 1); lower = 0.0), asℝ₊),
        b_rsa_above = (truncated(Cauchy(0, 0.01); lower = 0.0), asℝ₊)
    )

    # if !isnothing(input_obj)
    #     exclude_parameters = exlude_parameter(; input_obj)
    #     f = collect(keys(p)) .∉ Ref(exclude_parameters)
    #     p = (; zip(keys(p)[f], collect(p)[f])...)
    # end

    prior_vec = first.(collect(p))
    lb = quantile.(prior_vec, 0.0)
    ub = quantile.(prior_vec, 1.0)

    lb = (; zip(keys(p), lb)...)
    ub = (; zip(keys(p), ub)...)
    priordists = (; zip(keys(p), prior_vec)...)
    t = as((; zip(keys(p), getindex.(collect(p), 2))...))

    return (; priordists, lb, ub, t)
end




F = Float64
function SimulationParameter(dual_type)
    global F = dual_type
    p = SimulationParameter()
    global F = Float64

    return p
end

Base.getindex(obj::SimulationParameter, k) = getfield(obj, k)
Base.setindex!(obj::SimulationParameter, val, k) = setfield!(obj, k, val)
Base.keys(obj::SimulationParameter) = propertynames(obj)
Base.length(obj::SimulationParameter) = length(propertynames(obj))

function Base.iterate(obj::SimulationParameter)
    return (obj[propertynames(obj)[1]], 2)
end

function Base.iterate(obj::SimulationParameter, i)
    if i > length(obj)
        return nothing
    end
    return (obj[keys(obj)[i]], i + 1)
end


function add_units(x; p = SimulationParameter())
    for k in keys(x)
        @reset x[k] = x[k] * unit(p[k])
    end
    return x
end
