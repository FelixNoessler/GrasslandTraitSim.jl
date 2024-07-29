"""
    SimulationParameter(; kwargs...)

Here is an overview of the parameters that are used in the model. In addition
to the parameters listed here, a regression equation with parameters not listed here
from [Gupta1979](@cite) is used to derive the water holding capacity and
the permanent wilting point (see [`input_WHC_PWP!`](@ref)).


$(MYNEWFIELDS)
"""
@kwdef mutable struct SimulationParameter{T, Qkg_MJ, Qm, Qkg_ha, Qm2_g, Qg_m2, Qg_kg,
                                          Qha_MJ, QMJ_ha, QC, QK, Qkg, Qha_Mg}

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
    1::``\\alpha_{comH}``::is the community weighted mean height per
    total leaf area index, where the community self shading reducer equals 0.5,
    see [`potential_growth!`](@ref)
    """
    α_height_per_lai::Qm = F(0.02)u"m"

    """
    1::``\\beta_{H}``::controls how strongly taller plants gets more light for growth,
    see [`light_competition!`](@ref)
    """
    β_height::T = F(0.5)

    ####################################################################################
    ## 2 Belowground competition
    ####################################################################################

    ############################# Water competition
    """
    2::``\\text{water-red-SRSA-Lolium}``::TODO; water growth reducer for Lolium perenne
    at 0.4 scaled soil water content
    see [`water_reduction!`](@ref)
    """
    R_wrsa_04_Lolium::T = F(0.97)

    """
    2::``\\text{SRSA-Lolium}``::TODO fixed value for Lolium perenne
    see [`water_reduction!`](@ref)
    """
    RSA_per_totalbiomass_Lolium::Qm2_g = F(0.07832)u"m^2 / g"

    """
    2::``\\text{RSA-per-totalbiomass-influence}``::TODO
    see [`water_reduction!`](@ref)
    """
    RSA_per_totalbiomass_influence::T = F(0.01)

    """
    2::``\\eta_{\\min, wrsa}``::TODO
    see [`water_reduction!`](@ref)
    """
    R_wrsa_04_min::T = F(0.0)

    """
    2::``\\eta_{\\max, wrsa}``::TODO
    see [`water_reduction!`](@ref)
    """
    R_wrsa_04_max::T = F(1.0)

    """
    2::``\\beta_{wrsa}``::part of the growth reducer based on the root surface area
    per aboveground biomass and the water stress function ``W_{srsa, txys}``;
    slope of the logistic function, controls how steep the transition
    from ``1-\\delta_{wrsa}`` to ``K_{wrsa, s}`` is,
    see [`water_reduction!`](@ref)
    """
    β_wrsa::T = F(7.0)

    ############################# Nutrient competition
    """
    2::``N_{\\max}``:: maximal total soil nitrogen, based on the maximum total N
    of ≈ 30.63 [g kg⁻¹] in the data from the Biodiversity Exploratories
    [explo14446v19](@cite)[explo18787v6](@cite)[explo23846v10](@cite)[explo31210v6](@cite),
    see [`input_nutrients!`](@ref)
    """
    N_max::Qg_kg = F(35.0)u"g/kg"

    """
    2::``\\alpha_{TSB}``::part of the equation of the biomass density factor ``D_{txys}``,
    if the matrix multiplication between the trait similarity matrix and the biomass
    equals ``\\alpha_{TSB}`` the biomass density factor is one and the available water
    and nutrients for growth are neither in- nor decreased, a lower value of the matrix
    multiplication leads to biomass density factor above one and an increase of
    the available water and nutrients for growth,
    see [`below_ground_competition!`](@ref)
    """
    α_TSB::Qkg_ha = F(18000.0)u"kg / ha"

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
    κ_maxred_amc::T = F(0.02)

    """
    2::``\\kappa_{\\text{maxred}, srsa}``::TODO
    """
    κ_maxred_srsa::T = F(0.02)

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
    3::``T_{0}``::TODO,
    see [`temperature_reduction!`](@ref)
    """
    T₀::QC = F(4.0)u"°C"

    """
    3::``T_{1}``::TODO,
    see [`temperature_reduction!`](@ref)
    """
    T₁::QC = F(10.0)u"°C"

    """
    3::``T_{2}``::TODO,
    see [`temperature_reduction!`](@ref)
    """
    T₂::QC = F(20.0)u"°C"

    """
    3::``T_{3}``::TODO,
    see [`temperature_reduction!`](@ref)
    """
    T₃::QC = F(35.0)u"°C"

    """
    3::``ST_1``::is a threshold of the temperature degree days,
    above which the seasonality factor is set to `SEA_min` and
    descreases to `SEA_max`,
    see [`seasonal_reduction!`](@ref)
    """
    ST₁::QK = F(775.0)u"°C"

    """
    3::``ST_2``::is a threshold of the temperature degree-days,
    where the seasonality growth factor is set to `SEA_min`,
    see [`seasonal_reduction!`](@ref)
    """
    ST₂::QK = F(1450.0)u"°C"

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
    α_sen::T = F(0.001)

    """
    4::``\\phi_{sen, sla}``::TODO,
    see [`water_reduction!`](@ref)
    """
    ϕ_sen_sla::Qm2_g = F(0.009)u"m^2 / g"

    """
    4::``\\beta_{SEN}``::TODO
    see [`senescence_rate!`](@ref)
    """
    β_sen_sla::T = F(0.3)

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
    5::``\\eta_{GRZ}``::defines with  κ · livestock density the aboveground
    biomass [kg ha⁻¹] when the daily consumption by grazers reaches half of
    their maximal consumption,
    see [`grazing!`](@ref)
    """
    η_GRZ::T = F(25.0)

    """
    5::``\\kappa``::maximal consumption of a livestock unit per day,
    see [`grazing!`](@ref)
    """
    κ::Qkg = F(22.0)u"kg"

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
end


function Base.show(io::IO, obj::SimulationParameter)
    p_names = collect(keys(obj))
    vals = [obj[k] for k in p_names]
    m = hcat(p_names, vals)
    pretty_table(io, m; header = ["Parameter", "Value"],  alignment=[:r, :l], crop = :none)
    return nothing
end

F = Float64
function SimulationParameter(dual_type::DataType)
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
