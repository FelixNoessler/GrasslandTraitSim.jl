"""
$(SIGNATURES)

Here is an overview of the parameters that are used in the model. The parameters are............
$(FIELDS)
"""
@with_kw mutable struct Parameter{T, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9,
                                  Q10, Q11, Q12, Q13, Q14, Q15, Q16} @deftype T

    """\n
    Maximum radiation use efficiency, \\
    see [`potential_growth!`](@ref) \\
    """
    RUE_max::Q1 = F(3 / 1000) * u"kg / MJ"

    """\n
    Extinction coefficient, \\
    see [`potential_growth!`](@ref)\n
    """
    k = F(0.6)

    """\n
    α value of a linear equation that relate the leaf life span to the senescence rate, \\
    see [`senescence_rate!`](@ref)\n
    """
    α_sen = F(0.0002)

    """\n
    slope of a linear equation that relates the leaf life span to the senescence rate, \\
    see [`senescence_rate!`](@ref)\n
    """
    β_sen::Q2 = F(0.03)u"d"

    """\n
    transform SLA to leaflifespan,\\
    equation given by [Reich1992](@cite)\n
    """
    α_ll = F(2.41)

    """\n
    transform SLA to leaflifespan,\\
    equation given by [Reich1992](@cite)\n
    """
    β_ll = F(0.38)

    """\n
    emperature threshold: senescence starts to increase, \\
    see [`seasonal_component_senescence`](@ref)\n
    """
    Ψ₁ = F(775.0)

    """\n
    temperature threshold: senescence reaches maximum, \\
    see [`seasonal_component_senescence`](@ref)\n
    """
    Ψ₂ = F(3000.0)

    """\n
    maximal seasonality factor for the senescence rate, \\
    see [`seasonal_component_senescence`](@ref)\n
    """
    SENₘₐₓ = F(3.0)

    """\n
    Proportion of biomass that growths to the neighbouring cells, \\
    see [`clonalgrowth!`](@ref)\n
    """
    clonalgrowth_factor = F(0.05)

    "see [`radiation_reduction`](@ref)"
    γ1::Q3 = F(0.0445)u"m^2 / MJ"

    "see [`radiation_reduction`](@ref) "
    γ2::Q4 = F(5.0)u"MJ / m^2"

    "see [`temperature_reduction`](@ref)"
    T₀::Q5 = F(3.0)u"°C"

    "see [`temperature_reduction`](@ref)"
    T₁::Q5 = F(12.0)u"°C"

    "see [`temperature_reduction`](@ref)"
    T₂::Q5 = F(20.0)u"°C"

    "see [`temperature_reduction`](@ref)"
    T₃::Q5 = F(35.0)u"°C"

    "[`seasonal_reduction`](@ref)"
    SEAₘᵢₙ = F(0.7)

    "[`seasonal_reduction`](@ref)"
    SEAₘₐₓ = F(1.3)

    """\n
    898.15K = 625 °C, \\
    see [`seasonal_reduction`](@ref)
    """
    ST₁::Q6 = F(898.15)u"K"

    """\n
    1573.15 K = 1300.0 °C, \\
    see [`seasonal_reduction`](@ref)\n
    """
    ST₂::Q6 = F(1573.15)u"K"
    α_community_height::Q7 = F(10000.0)u"kg / ha "
    β_community_height::Q8 = F(0.0005)u"ha / kg"
    exp_community_height = F(0.9)

    """\n
    controls how strongly taller plants gets more light for growth, \\
    see [`light_competition!`](@ref)\n
    """
    height_strength_exp = F(0.5)

    """\n
    number of days after a mowing event when the plants are grown back to
    half of their normal size, \\
    see [`mowing!`](@ref)\n
    """
    mowing_mid_days = F(10.0)
    mowfactor_β = F(0.05)

    """\n
    controls how strongly grazers prefer plant species with high leaf nitrogen content, \\
    see [`grazing!`](@ref)\n
    """
    leafnitrogen_graz_exp = F(1.5)

    """\n
    defines together with the height of the plants and the livestock density
    the proportion of biomass that is trampled [ha m⁻¹], \\
    see [`trampling!`](@ref)\n
    """
    trampling_factor::Q9 = F(0.01)u"ha"
    trampling_height_exp = F(0.5)
    trampling_half_factor = F(10000.0)

    """\n
    total biomass [kg ha⁻¹] when the daily consumption by grazers reaches half
    of their maximal consumption defined by κ · livestock density, \\
    see [`grazing!`](@ref)\n
    """
    grazing_half_factor = F(1000.0)

    """"\n
    maximal consumption of a livestock unit per day, \\
    see [`grazing!`](@ref)\n
    """
    κ::Q10 = F(22.0)u"kg"
    lowbiomass::Q11 = F(100.0)u"kg / ha"

    """\n
    if the matrix multiplication between the trait similarity matrix and
    the biomass equals `biomass_dens` the available water and nutrients
    for growth are not in- or decreased,
    see [`below_ground_competition!`](@ref)\n
    """
    biomass_dens::Q11 = F(1200.0)u"kg / ha"
    lowbiomass_k::Q12= F(0.1)u"ha / kg"

    """
    the available water and nutrients are in- or decreased
    if the matrix multiplication between the trait similarity matrix and
    the biomass of the species is above or below of `biomass_dens`,
    see [`below_ground_competition!`]\n
    """
    belowground_density_effect = F(2.0)
    α_pet::Q13 = F(2.0)u"mm"
    β_pet::Q14 = F(1.2)u"mm^-1"

    """
    reference community weighted mean specific leaf area,
    if the community weighted mean specific leaf area is
    equal to `sla_tr` then transpiration is neither increased nor decreased,
    see `transpiration`](@ref)\n
    """
    sla_tr::Q15 = F(0.03)u"m^2 / g"

    """\n
    controls how strongly a community mean specific leaf area that deviates
    from `sla_tr` is affecting the transpiration,
    see [`transpiration`](@ref)\n
    """
    sla_tr_exponent = F(0.4)
    ϕ_sla::Q15 = F(0.025)u"m^2 / g"
    η_min_sla = F(-0.8)
    η_max_sla = F(0.8)
    β_η_sla::Q16 = F(75.0)u"g / m^2"
    β_sla = F(5.0)

    """\n
    maximal reduction of the plant-available water linked to the trait root surface area /
    aboveground biomass,
    see [`init_transfer_functions!`](@ref)\n
    """
    δ_wrsa = F(0.8)

    """\n
    maximal reduction of the plant-available water linked to the trait specific leaf area,
    see [`init_transfer_functions!`](@ref)\n
    """
    δ_sla = F(0.5)

    """\n
    based on the maximum total N of ≈ 30.63 [g kg⁻¹] in the data from the
    Biodiversity Exploratories \\
    [explo14446v19](@cite)[explo18787v6](@cite)[explo23846v10](@cite)[explo31210v6](@cite),
    see [`input_nutrients!`](@ref)\n
    """
    maxtotalN = F(35.0)
    ϕ_amc = F(0.35)
    η_min_amc = F(0.05)
    η_max_amc = F(0.6)
    κ_min_amc = F(0.2)
    β_κη_amc = F(10.0)
    β_amc = F(7.0)

    """\n
    maximal reduction of the plant-available nutrients linked to the trait
    arbuscular mycorrhizal colonisation rate,\\
    see [`init_transfer_functions!`](@ref)\n
    """
    δ_amc = F(0.5)

    """\n
    maximal reduction of the plant-available nutrients linked to the trait
    root surface area / aboveground biomass,\\
    see [`init_transfer_functions!`](@ref)\n
    """
    δ_nrsa = F(0.5)
    ϕ_rsa::Q15 = F(0.12)u"m^2 / g"
    η_min_rsa = F(0.05)
    η_max_rsa = F(0.6)
    κ_min_rsa = F(0.4)
    β_κη_rsa::Q16 = F(40.0)u"g / m^2"
    β_rsa = F(7.0)
    b_biomass = F(1000.0)
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
        append!(excl_p, [:β_community_height, :α_community_height])
    end

    if !included.height_competition
        append!(excl_p, [:height_strength_exp])
    end

    return excl_p
end

function calibrated_parameter(; input_obj = nothing)
    p = (;
        α_sen = (Uniform(0, 0.01), as(Real, 0.0, 0.01), NoUnits),
        β_sen = (Uniform(0.0, 0.1),  as(Real, 0.0, 0.1), NoUnits),
        Ψ₁ = (Uniform(700.0, 3000.0), as(Real, 700.0, 3000.0), NoUnits),
        SENₘₐₓ = (Uniform(1.0, 4.0), as(Real, 1.0, 4.0), NoUnits),
        α_community_height = (Uniform(0.0, 20000.0), as(Real, 0.0, 20000.0),
                              u"kg / ha"),
        β_community_height = (Uniform(0.0, 0.01), as(Real, 0.0, 0.01), u"ha / kg"),
        exp_community_height = (Uniform(0.0, 1.0), as(Real, 0.0, 1.0), NoUnits),
        height_strength_exp = (Uniform(0.0, 5.0), as(Real, 0.0, 5.0), NoUnits),
        mowing_mid_days = (truncated(Normal(10.0, 30.0); lower = 0.0, upper = 60.0),
                           as(Real, 0.0, 60.0), NoUnits),
        leafnitrogen_graz_exp = (Uniform(0.0, 5.0), as(Real, 0.0, 5.0), NoUnits),
        trampling_factor = (truncated(Normal(0.0, 0.05); lower = 0.0), asℝ₊, u"ha"),
        trampling_height_exp = (Uniform(0.0, 3.0), as(Real, 0.0, 3.0), NoUnits),
        trampling_half_factor = (truncated(Normal(10000.0, 1000.0); lower = 0.0), asℝ₊,
                                 NoUnits),
        grazing_half_factor = (truncated(Normal(500.0, 1000.0); lower = 0.0, upper = 2000.0),
                               as(Real, 0.0, 2000.0), NoUnits),
        κ = (Uniform(12.0, 22.5), as(Real, 12.0, 22.5), u"kg/d"),
        lowbiomass = (Uniform(0.0, 500.0), as(Real, 0.0, 500.0), u"kg/ha"),
        lowbiomass_k = (Uniform(0.0, 1.0), as(Real, 0.0, 1.0), u"ha/kg"),
        biomass_dens = (truncated(Normal(1000.0, 1000.0); lower = 0.0), asℝ₊, u"kg/ha"),
        belowground_density_effect = (truncated(Normal(1.0, 0.5); lower = 0.0),
                                      asℝ₊, NoUnits),
        α_pet = (Uniform(0.0, 5.0), as(Real, 0.0, 5.0), u"mm/d"),
        β_pet = (truncated(Normal(1.0, 1.0); lower = 0.0), asℝ₊, u"d/mm"),
        sla_tr = (truncated(Normal(0.02, 0.01); lower = 0.0), asℝ₊, u"m^2/g"),
        sla_tr_exponent = (truncated(Normal(1.0, 5.0); lower = 0.0), asℝ₊, NoUnits),
        ϕ_sla = (Uniform(0.01, 0.03), as(Real, 0.01, 0.03), u"m^2/g"),
        η_min_sla = (Uniform(-1.0, 1.0), as(Real, -1.0, 1.0), NoUnits),
        η_max_sla = (Uniform(-1.0, 1.0), as(Real, -1.0, 1.0), NoUnits),
        β_η_sla = (Uniform(0.0, 500.0), as(Real, 0.0, 500.0), u"g/m^2"),
        β_sla = (Uniform(0.0, 50.0), as(Real, 0.0, 50.0), NoUnits),
        δ_wrsa = (Uniform(0.0, 1.0), as𝕀, NoUnits),
        δ_sla = (Uniform(0.0, 1.0), as𝕀, NoUnits),
        ϕ_amc = (Uniform(0.1, 0.5), as(Real, 0.1, 0.5), NoUnits),
        η_min_amc = (Uniform(-1.0, 1.0), as(Real, -1.0, 1.0), NoUnits),
        η_max_amc = (Uniform(-1.0, 1.0), as(Real, -1.0, 1.0), NoUnits),
        κ_min_amc = (Uniform(0.0, 1.0), as𝕀, NoUnits),
        β_κη_amc = (Uniform(0.0, 250.0), as(Real, 0.0, 250.0), NoUnits),
        β_amc = (Uniform(0.0, 50.0), as(Real, 0.0, 50.0), NoUnits),
        δ_amc = (Uniform(0.0, 1.0), as𝕀, NoUnits),
        δ_nrsa = (Uniform(0.0, 1.0), as𝕀, NoUnits),
        ϕ_rsa = (Uniform(0.1, 0.25), as(Real, 0.1, 0.25), u"m^2/g"),
        η_min_rsa = (Uniform(-1.0, 1.0), as(Real, -1.0, 1.0), NoUnits),
        η_max_rsa =(Uniform(-1.0, 1.0), as(Real, -1.0, 1.0), NoUnits),
        κ_min_rsa = (Uniform(0.0, 1.0), as𝕀, NoUnits),
        β_κη_rsa = (Uniform(0.0, 250.0), as(Real, 0.0, 250.0), u"g/m^2"),
        β_rsa = (Uniform(0.0, 50.0), as(Real, 0.0, 50.0), NoUnits),
        b_biomass = (truncated(Cauchy(0, 300); lower = 0.0), asℝ₊, NoUnits),
        b_sla = (truncated(Cauchy(0, 0.05); lower = 0.0), asℝ₊, NoUnits),
        b_lncm = (truncated(Cauchy(0, 0.5); lower = 0.0), asℝ₊, NoUnits),
        b_amc = (truncated(Cauchy(0, 30); lower = 0.0), asℝ₊, NoUnits),
        b_height = (truncated(Cauchy(0, 1); lower = 0.0), asℝ₊, NoUnits),
        b_rsa_above = (truncated(Cauchy(0, 0.01); lower = 0.0), asℝ₊, NoUnits)
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
    units = (; zip(keys(p), last.(collect(p)))...)
    t = as((; zip(keys(p), getindex.(collect(p), 2))...))

    return (; priordists, lb, ub, t, units)
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
Base.keys(obj::Parameter) = propertynames(obj)
Base.length(obj::Parameter) = length(propertynames(obj))

function Base.iterate(obj::Parameter)
    return (obj[propertynames(obj)[1]], 2)
end

function Base.iterate(obj::Parameter, i)
    if i > length(obj)
        return nothing
    end
    return (obj[keys(obj)[i]], i + 1)
end


function add_units(x; inference_obj)
    for p in keys(x)
        x = @set x[p] = x[p] * inference_obj.units[p]
    end

    return x
end
