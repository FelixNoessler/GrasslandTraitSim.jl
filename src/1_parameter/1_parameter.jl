include("2_parameter_calibration.jl")

"""
    SimulationParameter(; kwargs...)

Here is an overview of the parameters that are used in the model. In addition
to the parameters listed here, a regression equation with parameters not listed here
from [Gupta1979](@cite) is used to derive the water holding capacity and
the permanent wilting point (see [`input_WHC_PWP!`](@ref)).


$(MYNEWFIELDS)
"""
@with_kw_noshow mutable struct SimulationParameter{T, Qkg_MJ, Qmha_Mg, Qkg_ha, Qm2_g,
                                                 Qg_m2, Qg_kg, Qha_MJ, QMJ_ha,
                                                 QC, QK, QMg_ha, Qkg, Qha_kg, Qha_Mg}

    ####################################################################################
    ## 1 Light interception and competition
    ####################################################################################
    """
    1::``RUE_{\\max}``::Maximal radiation use efficiency,
    see [`potential_growth!`](@ref)
    """
    RUE_max::Qkg_MJ = F(3 / 1000)u"kg / MJ"

    """
    1::``k``::Extinction coefficient,
    see [`potential_growth!`](@ref)
    """
    k::T = F(0.6)

    """
    1::``\\alpha_{comH}``::is the community weighted mean height,
    where the community height growth reducer equals 0.5,
    see [`potential_growth!`](@ref)
    """
    α_com_height::Qmha_Mg = F(0.8)u"m * ha / Mg"

    """
    1::``\\beta_{H}``::controls how strongly taller plants gets more light for growth,
    see [`light_competition!`](@ref)
    """
    β_height::T = F(0.5)

    ####################################################################################
    ## 2 Belowground competition
    ####################################################################################
    """
    2::``\\alpha_{TSB}``::part of the equation of the biomass density factor ``D_{txys}``,
    if the matrix multiplication between the trait similarity matrix and the biomass
    equals ``\\alpha_{TSB}`` the biomass density factor is one and the available water
    and nutrients for growth are neither in- nor decreased, a lower value of the matrix
    multiplication leads to biomass density factor above one and an increase of
    the available water and nutrients for growth,
    see [`below_ground_competition!`](@ref)
    """
    α_TSB::Qkg_ha = F(1200.0)u"kg / ha"

    """
    2::``\\beta_{TSB}``::part of the equation of the biomass density factor ``D_{txys}``,
    controls how strongly the biomass density factor
    deviates from one, if the matrix multiplication between the
    trait similarity matrix and the biomass of the species is above
    or below ``\\alpha_{TSB}``,
    see [`below_ground_competition!`](@ref)
    """
    β_TSB::Qha_Mg = F(2.0)u"ha / Mg"

    """
    2::``\\delta_{sla}``::part of the growth reducer based on the water stress
    and the specific leaf area ``W_{sla, txys}`` function;
    maximal possible growth reduction,
    see [`water_reduction!`](@ref)
    """
    δ_sla::T = F(0.5)

    """
    2::``\\beta_{sla}``::part of the growth reducer based on the water stress
    and the specific leaf area function ``W_{sla, txys}``;
    slope of the logistic function, controls how steep
    the transition from ``1-\\delta_{sla}`` to 1 is,
    see [`water_reduction!`](@ref)
    """
    β_sla::T = F(5.0)

    """
    2::``\\eta_{\\min, sla}``::part of the growth reducer based on the water stress
    and the specific leaf area function ``W_{sla, txys}``;
    ... TODO ... of the logistic function ``A_{sla, s}`` for ``W_{sla, txys}``,
    see [`water_reduction!`](@ref)
    """
    η_μ_sla::T = F(0.1)

    """
    2::``\\eta_{\\max, sla}``::part of the growth reducer based on the water stress
    and the specific leaf area function ``W_{sla, txys}``;
    ... TODO ...``A_{sla, s}`` for ``W_{sla, txys}``,
    see [`water_reduction!`](@ref)
    """
    η_σ_sla::T = F(0.7)

    """
    2::``\\phi_{sla}``::part of the growth reducer based on the water stress and the
    specific leaf area function ``W_{sla, txys}``; is the specific leaf area where
    the species has a value of ``A_{sla, s}`` that is halfway between
    ``\\eta_{\\min, sla}`` and ``\\eta_{\\max, sla}``,
    see [`water_reduction!`](@ref)
    """
    ϕ_sla::Qm2_g = F(0.007)u"m^2 / g"

    """
    2::``\\beta_{\\eta, sla}``::part of the growth reducer based on the water stress
    and the specific leaf area function ``W_{sla, txys}``; slope of a logistic function
    that relates the specific leaf area to ``A_{sla, s}``,
    see [`water_reduction!`](@ref)
    """
    β_η_sla::Qg_m2 = F(500.0)u"g / m^2"

    """
    2::``\\delta_{wrsa}``::part of the growth reducer based on the
    root surface area per aboveground biomass and the water stress function
    ``W_{srsa, txys}``; maximal possible reduction & calibrated
    see [`water_reduction!`](@ref)
    """
    δ_wrsa::T = F(0.8)

    """
    2::``\\beta_{wrsa}``::part of the growth reducer based on the root surface area
    per aboveground biomass and the water stress function ``W_{srsa, txys}``;
    slope of the logistic function, controls how steep the transition
    from ``1-\\delta_{wrsa}`` to ``K_{wrsa, s}`` is,
    see [`water_reduction!`](@ref)
    """
    β_wrsa::T = F(7.0)

    """
    2::``\\phi_{srsa}``::part of the growth reducer based on the
    root surface area per aboveground biomass and the water stress
    function ``W_{srsa, txys}`` and the nutrient stress function ``N_{srsa, txys}``;
    is the root surface area per aboveground biomass area where the species have
    values of ``A_{wrsa, s}`` (``A_{nrsa, s}``) and ``K_{wrsa, s}`` (``K_{nrsa, s}``)
    that are halfway between the minimum and the maximum of
    ``A_{wrsa, s}`` (``A_{nrsa, s}``) and ``K_{wrsa, s}`` (``K_{nrsa, s}``),
    see [`water_reduction!`](@ref)
    """
    ϕ_rsa::Qm2_g = F(0.07)u"m^2 / g"

    """
    2::``\\beta_{\\eta, wrsa}``::part of the growth reducer based on the root
    surface area per aboveground biomass and the water stress function ``W_{srsa, txys}``;
    is the slope of the two logistic functions that relate the root surface area per
    aboveground biomass to ``K_{wrsa, s}`` and ``A_{nrsa, s}``,
    see [`water_reduction!`](@ref)
    """
    β_η_wrsa::Qg_m2 = F(80.0)u"g / m^2"

    """
    2::``\\eta_{\\mu, wrsa}``::part of the growth reducer based on the
    root surface area per aboveground biomass and the water stress function
    ``W_{srsa, txys}``; mean possible value of ``A_{wrsa, s}``,
    see [`water_reduction!`](@ref)
    """
    η_μ_wrsa::T = F(0.3)

    """
    2::``\\eta_{\\sigma, wrsa}``::part of the growth reducer based on the root surface
    area per aboveground biomass and the water stress function ``W_{srsa, txys}``;
    diff to ``\\eta_{\\mu, wrsa}`` to get minimal and maximal possible
    value of ``A_{wrsa, s}``,
    see [`water_reduction!`](@ref)
    """
    η_σ_wrsa::T = F(0.3)

    """
    2::``N_{\\max}``:: maximal total soil nitrogen, based on the maximum total N
    of ≈ 30.63 [g kg⁻¹] in the data from the Biodiversity Exploratories
    [explo14446v19](@cite)[explo18787v6](@cite)[explo23846v10](@cite)[explo31210v6](@cite),
    see [`input_nutrients!`](@ref)
    """
    N_max::Qg_kg = F(35.0)u"g/kg"

    """
    2::``\\delta_{amc}``::part of the growth reducer based on the
    arbuscular mycorrhizal colonization rate and the nutrient stress function
    ``N_{amc, txys}``; maximal possible growth reduction,
    see [`nutrient_reduction!`](@ref)
    """
    δ_amc::T = F(0.5)

    """
    2::``\\beta_{amc}``::part of the growth reducer based on the arbuscular
    mycorrhizal colonization rate and the nutrient stress function ``N_{amc, txys}``;
    slope of a logistic function that calculates the growth reducer ``N_{amc, txys}``,
    see [`nutrient_reduction!`](@ref)
    """
    β_amc::T = F(7.0)

    """
    2::``\\beta_{\\text{red}, amc}``::TODO
    """
    β_red_amc::T = F(12.0)

    """
    2::``\\beta_{\\text{red}, srsa}``::TODO
    """
    β_red_rsa::Qg_m2 = F(20.0)u"g/m^2"

    """
    2::``\\kappa_{\\text{maxred}, amc}``::TODO
    """
    κ_maxred_amc::T = F(0.15)

    """
    2::``\\kappa_{\\text{maxred}, srsa}``::TODO
    """
    κ_maxred_srsa::T = F(0.15)

    """
    2::``\\beta_{\\eta, amc}``::part of the growth reducer based on the
    arbuscular mycorrhizal colonization rate and the nutrient stress function
    ``N_{amc, txys}``; is the slope of the two logistic functions that relate
    the arbuscular mycorrhizal colonization rate to ``K_{amc, s}`` and ``A_{amc, s}``,
    see [`nutrient_reduction!`](@ref)
    """
    β_η_amc::T = F(20.0)

    """
    2::``\\eta_{\\min, amc}``::part of the growth reducer based on the
    arbuscular mycorrhizal colonization rate and the nutrient stress function
    ``N_{amc, txys}``; ... TODO ... ``A_{amc, s}``,
    see [`nutrient_reduction!`](@ref)
    """
    η_μ_amc::T = F(0.3)

    """
    2::``\\eta_{\\sigma, amc}``::part of the growth reducer based on
    the arbuscular mycorrhizal colonization rate and the nutrient stress function
    ``N_{amc, txys}``; ... TODO ... ``A_{amc, s}``,
    see [`nutrient_reduction!`](@ref)
    """
    η_σ_amc::T = F(0.3)

    """
    2::``\\phi_{amc}``::part of the growth reducer based on the
    arbuscular mycorrhizal colonization rate and the nutrient stress function
    ``N_{amc, txys}``; is the arbuscular mycorrhizal colonization rate where
    the species have values of ``A_{amc, s}`` and ``K_{amc, s}``
    that are halfway between the minimum and the maximum of
    ``A_{amc, s}`` and ``K_{amc, s}``,
    see [`nutrient_reduction!`](@ref)
    """
    ϕ_amc::T = F(0.17)

    """
    2::``\\delta_{nrsa}``::part of the growth reducer based on the
    root surface area per aboveground biomass and the nutrient stress function
    ``N_{srsa, txys}``; maximal growth reduction,
    see [`nutrient_reduction!`](@ref)
    """
    δ_nrsa::T = F(0.9)

    """
    2::``\\beta_{nrsa}``:: part of the growth reducer based on
    the root surface area per aboveground biomass and the nutrient stress
    function ``N_{srsa, txys}``; slope of a logistic function
    that calculates the growth reducer ``N_{srsa, txys}``,
    see [`nutrient_reduction!`](@ref)
    """
    β_nrsa::T = F(7.0)

    """
    2::``\\beta_{\\eta, nrsa}``::part of the growth reducer based on
    the root surface area per aboveground biomass and the nutrient stress
    function ``N_{srsa, txys}``; is the slope of the two logistic functions
    that relate the root surface area per
    aboveground biomass to ``K_{nrsa, s}`` and ``A_{nrsa, s}``,
    see [`nutrient_reduction!`](@ref)
    """
    β_η_nrsa::Qg_m2 = F(100.0)u"g / m^2"

    """
    2::``\\eta_{\\mu, nrsa}``::part of the growth reducer based on the
    root surface area per aboveground biomass and the nutrient
    stress function ``N_{srsa, txys}``; ... TODO ... ``A_{nrsa, s}``,
    see [`nutrient_reduction!`](@ref)
    """
    η_μ_nrsa::T = F(0.3)

    """
    2::``\\eta_{\\sigma, nrsa}``::part of the growth reducer based on the
    root surface area per aboveground biomass and the nutrient
    stress function ``N_{srsa, txys}``;... TODO ... ``A_{nrsa, s}``,
    see [`nutrient_reduction!`](@ref)
    """
    η_σ_nrsa::T = F(0.3)

    ####################################################################################
    ## 3 Environmental and seasonal growth adjustment
    ####################################################################################
    """
    3::``\\gamma_1``::controls the steepness of the linear decrease in
    radiation use efficiency for high values of the photosynthetically
    active radiation (`PAR`),
    see [`radiation_reduction!`](@ref)
    """
    γ₁::Qha_MJ = F(4.45e-6)u"ha / MJ"  # uconvert(u"ha/MJ", 0.0445u"m^2 / MJ")

    """
    3::``\\gamma_2``::threshold value of `PAR` from which starts a linear decrease in
    radiation use efficiency,
    see [`radiation_reduction!`](@ref)
    """
    γ₂::QMJ_ha = F(50000.0)u"MJ / ha" # uconvert(u"MJ/ha", 5.0u"MJ / m^2")

    """
    3::``T_0``::is the lower temperature threshold for growth,
    see [`temperature_reduction!`](@ref)
    """
    T₀::QC = F(4.0)u"°C"

    """
    3::``T_1``::is the lower bound for the optimal temperature for growth,
    see [`temperature_reduction!`](@ref)
    """
    T₁::QC = F(10.0)u"°C"

    """
    3::``T_2``::is the upper bound for the optiomal temperature for growth,
    see [`temperature_reduction!`](@ref)
    """
    T₂::QC = F(20.0)u"°C"

    """
    3::``T_3``::is the maximum temperature for growth,
    see [`temperature_reduction!`](@ref)
    """
    T₃::QC = F(35.0)u"°C"

    """
    3::``ST_1``::is a threshold of the temperature degree days,
    above which the seasonality factor is set to `SEA_min` and
    descreases to `SEA_max`,
    see [`seasonal_reduction!`](@ref)
    """
    ST₁::QK = F(775.0)u"K"

    """
    3::``ST_2``::is a threshold of the temperature degree-days,
    where the seasonality growth factor is set to `SEA_min`,
    see [`seasonal_reduction!`](@ref)
    """
    ST₂::QK = F(1450.0)u"K"

    """
    3::``SEA_{\\min}``::is the minimal value of the seasonal effect,
    see [`seasonal_reduction!`](@ref)
    """
    SEA_min::T = F(0.7)

    """
    3::``SEA_{\\max}``::is the maximal value of the seasonal effect,
    see [`seasonal_reduction!`](@ref)
    """
    SEA_max::T = F(1.3)

    ####################################################################################
    ## 4 Senescence
    ####################################################################################
    """
    4::``\\alpha_{SEN}``::senescence rate-intercept of a linear equation that relate
    the leaf life span to the senescence rate,
    see [`senescence_rate!`](@ref)
    """
    α_sen::T = F(0.002)

    """
    4::``\\beta_{SEN}``::TODO
    see [`senescence_rate!`](@ref)
    """
    β_sen_sla::QMg_ha = F(1.0)u"Mg/ha"

    """
    4::``Ψ_1``::temperature threshold: senescence starts to increase,
    see [`seasonal_component_senescence`](@ref)
    """
    Ψ₁::T = F(775.0)

    """
    4::``Ψ_2``::temperature threshold: senescence reaches maximum,
    see [`seasonal_component_senescence`](@ref)
    """
    Ψ₂::T = F(3000.0)

    """
    4::``SEN_{\\max}``::maximal seasonality factor for the senescence rate,
    see [`seasonal_component_senescence`](@ref)
    """
    SEN_max::T = F(3.0)

    ####################################################################################
    ## 5 Management
    ####################################################################################
    """
    5::``\\beta_{PAL, lnc}``::controls how strongly grazers prefer
    plant species with high leaf nitrogen content,
    see [`grazing!`](@ref)
    """
    β_PAL_lnc::T = F(1.2)

    """
    5::``\\eta_{GRZ}``::defines with  κ · livestock density the aboveground biomass [kg ha⁻¹] when the daily consumption by grazers reaches half of their maximal consumption,
    see [`grazing!`](@ref)
    """
    η_GRZ::T = F(25.0)

    """
    5::``\\kappa``::maximal consumption of a livestock unit per day,
    see [`grazing!`](@ref)
    """
    κ::Qkg = F(22.0)u"kg"

    """
    5::``\\alpha_{\\text{low}B}``::
    """
    α_lowB::Qkg_ha = F(20.0)u"kg / ha"

    """
    5::``\\beta_{\\text{low}B}``::
    """
    β_lowB::Qha_kg = F(0.1)u"ha / kg"

    ####################################################################################
    ## 6 Clonal growth
    ####################################################################################
    """
    6::``\\beta_{clo}``::Proportion of biomass that growths to the neighbouring cells,
    see [`clonalgrowth!`](@ref)
    """
    β_clo::T = F(0.1)

    ####################################################################################
    ## 7 Water dynamics
    ####################################################################################
    """
    7::``\\alpha_{TR, sla}``::reference community weighted mean specific leaf area,
    if the community weighted mean specific leaf area is
    equal to `α_TR_sla` then transpiration is neither increased nor decreased,
    see `transpiration`](@ref)
    """
    α_TR_sla::Qm2_g = F(0.03)u"m^2 / g"

    """
    7::``\\beta_{TR, sla}``::controls how strongly a
    community mean specific leaf area that deviates
    from `α_TR_sla` is affecting the transpiration,
    see [`transpiration`](@ref)
    """
    β_TR_sla::T = F(0.4)

    ####################################################################################
    ## 8 Variance parameter for likelihood
    ####################################################################################
    """
    8::``\\sigma_{B}``::
    """
    b_biomass::T = F(5000.0)

    """
    8::``\\sigma_{sla}``::
    """
    b_sla::T = F(0.005)

    """
    8::``\\sigma_{lnc}``::
    """
    b_lnc::T = F(2.0)

    """
    8::``\\sigma_{abp}``::
    """
    b_abp::T = F(0.01)

    """
    8::``\\sigma_{amc}``::
    """
    b_amc::T = F(0.01)

    """
    8::``\\sigma_{H}``::
    """
    b_height::T = F(0.5)

    """
    8::``\\sigma_{srsa}``::
    """
    b_srsa::T = F(0.004)
end


function SimulationParameter(input_obj::NamedTuple; exclude_not_used = true)
    p = SimulationParameter()

    if exclude_not_used
        exclude_parameters = exlude_parameter(; input_obj)
        f = collect(keys(p)) .∉ Ref(exclude_parameters)
        p = (; zip(keys(p)[f], collect(p)[f])...)
    end

    return p
end

function Base.show(io::IO, obj::SimulationParameter)
    p_names = collect(keys(obj))
    vals = [obj[k] for k in p_names]
    m = hcat(p_names, vals)
    pretty_table(io, m; header = ["Parameter", "Value"],  alignment=[:r, :l], crop = :none)
    return nothing
end

function exlude_parameter(; input_obj)
    @unpack likelihood_included, included, npatches = input_obj.simp

    excl_p = Symbol[]
    if !likelihood_included.biomass
        append!(excl_p, [:b_biomass])
    end

    if !likelihood_included.trait
        append!(excl_p, [:b_sla, :b_lnc, :b_amc, :b_height, :b_srsa])
    end

    if !included.potential_growth
        append!(excl_p, [:RUE_max, :k])
    end

    if isone(npatches) || !included.clonalgrowth
        append!(excl_p, [:β_clo])
    end

    if !included.radiation_red
        append!(excl_p, [:γ₁, :γ₂])
    end

    if !included.temperature_growth_reduction
        append!(excl_p, [:T₀, :T₁, :T₂, :T₃])
    end

    if !included.season_red
        append!(excl_p, [:SEA_min, :SEA_max, :ST₁, :ST₂])
    end

    if !included.water_growth_reduction
        water_names = [:ϕ_sla, :η_min_sla, :η_max_sla, :β_η_sla, :β_sla, :δ_wrsa, :δ_sla,
                       :β_wrsa, :η_μ_wrsa, :η_σ_wrsa, :β_η_wrsa]
        append!(excl_p, water_names)
    end

    if !included.nutrient_growth_reduction
        nutrient_names = [:N_max, :ϕ_amc, :η_min_amc, :η_max_amc, :κ_red_amc, :β_η_amc,
                          :β_amc, :δ_amc, :δ_nrsa, :β_nrsa,
                          :η_min_nrsa, :η_max_nrsa, :β_η_nrsa]
        append!(excl_p, nutrient_names)
    end

    if !included.nutrient_growth_reduction && !included.water_growth_reduction
        append!(excl_p, [:ϕ_rsa])
    end

    if !included.sla_transpiration
        append!(excl_p, [:α_TR_sla, :β_TR_sla])
    end

    if !included.belowground_competition
        append!(excl_p, [:α_TSB, :β_TSB])
    end

    if !included.grazing
        append!(excl_p, [:β_PAL_lnc, :κ, :α_GRZ])
    end

    if !included.mowing && !included.grazing
        append!(excl_p, [:α_lowB, :β_lowB])
    end

    if  !included.senescence
        append!(excl_p, [:α_sen, :β_sen_sla])
    end

    if !included.senescence || !included.senescence_season
        append!(excl_p, [:Ψ₁, :Ψ₂, :SEN_max])
    end

    if !included.community_height_red
        append!(excl_p, [:α_com_height, :β_com_height])
    end

    if !included.height_competition
        append!(excl_p, [:β_height])
    end

    if !included.lowbiomass_avoidance
        append!(excl_p, [:α_lowB, :β_lowB])

    end

    return excl_p
end

F = Float64
function SimulationParameter(dual_type)
    global F = dual_type
    p = SimulationParameter()
    global F = Float64

    return p
end

Base.getindex(obj::SimulationParameter, k::Symbol) = getfield(obj, k)
Base.getindex(obj::SimulationParameter, k::String) = getfield(obj, key(k))
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
