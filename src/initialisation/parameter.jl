"""
    SimulationParameter(; kwargs...)

Here is an overview of the parameters that are used in the model. In addition
to the parameters listed here, a regression equation with parameters not listed here
from [Gupta1979](@cite) is used to derive the water holding capacity and
the permanent wilting point (see [`input_WHC_PWP!`](@ref)).


$(MYNEWFIELDS)
"""
@with_kw_noshow mutable struct SimulationParameter{T, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8,
                                  Q10, Q11, Q12, Q13, Q14, Q15, Q16, Q17} @deftype T

    ####################################################################################
    ## 1 Light interception and competition
    ####################################################################################
    """
    1::``RUE_{\\max}``::Maximal radiation use efficiency,
    see [`potential_growth!`](@ref)
    """
    RUE_max::Q1 = F(3 / 1000) * u"kg / MJ"

    """
    1::``k``::Extinction coefficient,
    see [`potential_growth!`](@ref)
    """
    k = F(0.6)

    """
    1::``\\alpha_{comH}``::is the community weighted mean height,
    where the community height growth reducer equals 0.5,
    see [`potential_growth!`](@ref)
    """
    α_com_height::Q7 = F(0.2)u"m"

    """
    1::``\\beta_{comH}``::is the slope of the logistic function that relates
    the community weighted mean height to the community height growth reducer,
    see [`potential_growth!`](@ref)
    """
    β_com_height::Q8 = F(5)u"m^-1"

    """
    1::``\\beta_{H}``::controls how strongly taller plants gets more light for growth,
    see [`light_competition!`](@ref)
    """
    β_height = F(0.5)

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
    α_TSB::Q11 = F(1200.0)u"kg / ha"

    """
    2::``\\beta_{TSB}``::part of the equation of the biomass density factor ``D_{txys}``,
    controls how strongly the biomass density factor
    deviates from one, if the matrix multiplication between the
    trait similarity matrix and the biomass of the species is above
    or below ``\\alpha_{TSB}``,
    see [`below_ground_competition!`](@ref)
    """
    β_TSB = F(2.0)

    """
    2::``\\alpha_{PET}``::reference value for influence of
    the potential evapotranspiration ``PET_{txy}`` on the plant available water;
    if ``PET_{txy}`` is above ``\\alpha_{PET}``, the factor ``PET_{Wp, txy}``
    is below one and the plant available water is lowered,
    see [`water_reduction!`](@ref)
    """
    α_PET::Q13 = F(2.0)u"mm"

    """
    2::``\\beta_{PET}``::slope of the function for the influence of
    the potential evapotranspiration ``PET_{txy}`` on the plant available
    water ``PET_{Wp, txy}``; controls how strongly the factor ``PET_{Wp, txy}``
    deviates from one if the ``PET_{txy}`` deviates from ``\\alpha_{PET}``,
    see [`water_reduction!`](@ref)
    """
    β_PET::Q14 = F(1.2)u"mm^-1"

    """
    2::``\\delta_{sla}``::part of the growth reducer based on the water stress
    and the specific leaf area ``W_{sla, txys}`` function;
    maximal possible growth reduction,
    see [`water_reduction!`](@ref)
    """
    δ_sla = F(0.5)

    """
    2::``\\beta_{sla}``::part of the growth reducer based on the water stress
    and the specific leaf area function ``W_{sla, txys}``;
    slope of the logistic function, controls how steep
    the transition from ``1-\\delta_{sla}`` to 1 is,
    see [`water_reduction!`](@ref)
    """
    β_sla = F(5.0)

    """
    2::``\\eta_{\\min, sla}``::part of the growth reducer based on the water stress
    and the specific leaf area function ``W_{sla, txys}``;
    minimum of the midpoint of the logistic function ``A_{sla, s}`` for ``W_{sla, txys}``,
    see [`water_reduction!`](@ref)
    """
    η_min_sla = F(-0.8)

    """
    2::``\\eta_{\\max, sla}``::part of the growth reducer based on the water stress
    and the specific leaf area function ``W_{sla, txys}``;
    maximum of the midpoint of the logistic function ``A_{sla, s}`` for ``W_{sla, txys}``,
    see [`water_reduction!`](@ref)
    """
    η_max_sla = F(0.8)

    """
    2::``\\phi_{sla}``::part of the growth reducer based on the water stress and the
    specific leaf area function ``W_{sla, txys}``; is the specific leaf area where
    the species has a value of ``A_{sla, s}`` that is halfway between
    ``\\eta_{\\min, sla}`` and ``\\eta_{\\max, sla}``,
    see [`water_reduction!`](@ref)
    """
    ϕ_sla::Q15 = F(0.025)u"m^2 / g"

    """
    2::``\\beta_{\\eta, sla}``::part of the growth reducer based on the water stress
    and the specific leaf area function ``W_{sla, txys}``; slope of a logistic function
    that relates the specific leaf area to ``A_{sla, s}``,
    see [`water_reduction!`](@ref)
    """
    β_η_sla::Q16 = F(75.0)u"g / m^2"

    """
    2::``\\delta_{wrsa}``::part of the growth reducer based on the
    root surface area per aboveground biomass and the water stress function
    ``W_{rsa, txys}``; maximal possible reduction & calibrated
    see [`water_reduction!`](@ref)
    """
    δ_wrsa = F(0.8)

    """
    2::``\\beta_{wrsa}``::part of the growth reducer based on the root surface area
    per aboveground biomass and the water stress function ``W_{rsa, txys}``;
    slope of the logistic function, controls how steep the transition
    from ``1-\\delta_{wrsa}`` to ``K_{wrsa, s}`` is,
    see [`water_reduction!`](@ref)
    """
    β_wrsa = F(7.0)

    """
    2::``\\phi_{rsa}``::part of the growth reducer based on the
    root surface area per aboveground biomass and the water stress
    function ``W_{rsa, txys}`` and the nutrient stress function ``N_{rsa, txys}``;
    is the root surface area per aboveground biomass area where the species have
    values of ``A_{wrsa, s}`` (``A_{nrsa, s}``) and ``K_{wrsa, s}`` (``K_{nrsa, s}``)
    that are halfway between the minimum and the maximum of
    ``A_{wrsa, s}`` (``A_{nrsa, s}``) and ``K_{wrsa, s}`` (``K_{nrsa, s}``),
    see [`water_reduction!`](@ref)
    """
    ϕ_rsa::Q15 = F(0.12)u"m^2 / g"

    """
    2::``\\beta_{\\eta, wrsa}``::part of the growth reducer based on the root
    surface area per aboveground biomass and the water stress function ``W_{rsa, txys}``;
    is the slope of the two logistic functions that relate the root surface area per
    aboveground biomass to ``K_{wrsa, s}`` and ``A_{nrsa, s}``,
    see [`water_reduction!`](@ref)
    """
    β_η_wrsa::Q16 = F(40.0)u"g / m^2"

    """
    2::``\\eta_{\\min, wrsa}``::part of the growth reducer based on the
    root surface area per aboveground biomass and the water stress function
        ``W_{rsa, txys}``; minimal possible value of ``A_{wrsa, s}``,
    see [`water_reduction!`](@ref)
    """
    η_min_wrsa = F(0.05)

    """
    2::``\\eta_{\\max, wrsa}``::part of the growth reducer based on the root surface
    area per aboveground biomass and the water stress function ``W_{rsa, txys}``;
    maximal possible value of ``A_{wrsa, s}``,
    see [`water_reduction!`](@ref)
    """
    η_max_wrsa = F(0.6)

    """
    2::``N_{\\max}``:: maximal total soil nitrogen, based on the maximum total N
    of ≈ 30.63 [g kg⁻¹] in the data from the Biodiversity Exploratories
    [explo14446v19](@cite)[explo18787v6](@cite)[explo23846v10](@cite)[explo31210v6](@cite),
    see [`input_nutrients!`](@ref)
    """
    N_max::Q17 = F(35.0)u"g/kg"

    """
    2::``\\delta_{amc}``::part of the growth reducer based on the
    arbuscular mycorrhizal colonization rate and the nutrient stress function
    ``N_{amc, txys}``; maximal possible growth reduction,
    see [`nutrient_reduction!`](@ref)
    """
    δ_amc = F(0.5)

    """
    2::``\\beta_{amc}``::part of the growth reducer based on the arbuscular
    mycorrhizal colonization rate and the nutrient stress function ``N_{amc, txys}``;
    slope of a logistic function that calculates the growth reducer ``N_{amc, txys}``,
    see [`nutrient_reduction!`](@ref)
    """
    β_amc = F(7.0)

    """
    2::``\\kappa_{\\text{red}, amc}``::TODO
    """
    κ_red_amc = F(0.5)

    """
    2::``\\beta_{\\eta, amc}``::part of the growth reducer based on the
    arbuscular mycorrhizal colonization rate and the nutrient stress function
    ``N_{amc, txys}``; is the slope of the two logistic functions that relate
    the arbuscular mycorrhizal colonization rate to ``K_{amc, s}`` and ``A_{amc, s}``,
    see [`nutrient_reduction!`](@ref)
    """
    β_η_amc = F(10.0)

    """
    2::``\\eta_{\\min, amc}``::part of the growth reducer based on the
    arbuscular mycorrhizal colonization rate and the nutrient stress function
    ``N_{amc, txys}``; minimal possible value of ``A_{amc, s}``,
    see [`nutrient_reduction!`](@ref)
    """
    η_min_amc = F(0.05)

    """
    2::``\\eta_{\\max, amc}``::part of the growth reducer based on
    the arbuscular mycorrhizal colonization rate and the nutrient stress function
    ``N_{amc, txys}``; maximal possible value of ``A_{amc, s}``,
    see [`nutrient_reduction!`](@ref)
    """
    η_max_amc = F(0.6)

    """
    2::``\\phi_{amc}``::part of the growth reducer based on the
    arbuscular mycorrhizal colonization rate and the nutrient stress function
    ``N_{amc, txys}``; is the arbuscular mycorrhizal colonization rate where
    the species have values of ``A_{amc, s}`` and ``K_{amc, s}``
    that are halfway between the minimum and the maximum of
    ``A_{amc, s}`` and ``K_{amc, s}``,
    see [`nutrient_reduction!`](@ref)
    """
    ϕ_amc = F(0.35)

    """
    2::``\\delta_{nrsa}``::part of the growth reducer based on the
    root surface area per aboveground biomass and the nutrient stress function
    ``N_{rsa, txys}``; maximal growth reduction,
    see [`nutrient_reduction!`](@ref)
    """
    δ_nrsa = F(0.9)

    """
    2::``\\beta_{nrsa}``:: part of the growth reducer based on
    the root surface area per aboveground biomass and the nutrient stress
    function ``N_{rsa, txys}``; slope of a logistic function
    that calculates the growth reducer ``N_{rsa, txys}``,
    see [`nutrient_reduction!`](@ref)
    """
    β_nrsa = F(7.0)

    """
    2::``\\beta_{\\eta, nrsa}``::part of the growth reducer based on
    the root surface area per aboveground biomass and the nutrient stress
    function ``N_{rsa, txys}``; is the slope of the two logistic functions
    that relate the root surface area per
    aboveground biomass to ``K_{nrsa, s}`` and ``A_{nrsa, s}``,
    see [`nutrient_reduction!`](@ref)
    """
    β_η_nrsa::Q16 = F(40.0)u"g / m^2"

    """
    2::``\\eta_{\\min, nrsa}``::part of the growth reducer based on the
    root surface area per aboveground biomass and the nutrient
    stress function ``N_{rsa, txys}``; minimal possible value of ``A_{nrsa, s}``,
    see [`nutrient_reduction!`](@ref)
    """
    η_min_nrsa = F(0.05)

    """
    2::``\\eta_{\\max, nrsa}``::part of the growth reducer based on the
    root surface area per aboveground biomass and the nutrient
    stress function ``N_{rsa, txys}``; maximal possible value of ``A_{nrsa, s}``,
    see [`nutrient_reduction!`](@ref)
    """
    η_max_nrsa = F(0.6)

    ####################################################################################
    ## 3 Environmental and seasonal growth adjustment
    ####################################################################################
    """
    3::``\\gamma_1``::controls the steepness of the linear decrease in
    radiation use efficiency for high values of the photosynthetically
    active radiation (`PAR`),
    see [`radiation_reduction!`](@ref)
    """
    γ₁::Q3 = F(4.45e-6)u"ha / MJ"  # uconvert(u"ha/MJ", 0.0445u"m^2 / MJ")

    """
    3::``\\gamma_2``::threshold value of `PAR` from which starts a linear decrease in
    radiation use efficiency,
    see [`radiation_reduction!`](@ref)
    """
    γ₂::Q4 = F(50000.0)u"MJ / ha" # uconvert(u"MJ/ha", 5.0u"MJ / m^2")

    """
    3::``T_0``::is the lower temperature threshold for growth,
    see [`temperature_reduction!`](@ref)
    """
    T₀::Q5 = F(4.0)u"°C"

    """
    3::``T_1``::is the lower bound for the optimal temperature for growth,
    see [`temperature_reduction!`](@ref)
    """
    T₁::Q5 = F(10.0)u"°C"

    """
    3::``T_2``::is the upper bound for the optiomal temperature for growth,
    see [`temperature_reduction!`](@ref)
    """
    T₂::Q5 = F(20.0)u"°C"

    """
    3::``T_3``::is the maximum temperature for growth,
    see [`temperature_reduction!`](@ref)
    """
    T₃::Q5 = F(35.0)u"°C"

    """
    3::``ST_1``::is a threshold of the temperature degree days,
    above which the seasonality factor is set to `SEA_min` and
    descreases to `SEA_max`,
    see [`seasonal_reduction!`](@ref)
    """
    ST₁::Q6 = F(775.0)u"K"

    """
    3::``ST_2``::is a threshold of the temperature degree-days,
    where the seasonality growth factor is set to `SEA_min`,
    see [`seasonal_reduction!`](@ref)
    """
    ST₂::Q6 = F(1450.0)u"K"

    """
    3::``SEA_{\\min}``::is the minimal value of the seasonal effect,
    see [`seasonal_reduction!`](@ref)
    """
    SEA_min = F(0.7)

    """
    3::``SEA_{\\max}``::is the maximal value of the seasonal effect,
    see [`seasonal_reduction!`](@ref)
    """
    SEA_max = F(1.3)

    ####################################################################################
    ## 4 Senescence
    ####################################################################################
    """
    4::``\\alpha_{SEN}``::senescence rate-intercept of a linear equation that relate
    the leaf life span to the senescence rate,
    see [`senescence_rate!`](@ref)
    """
    α_sen = F(0.0)

    """
    4::``\\beta_{SEN}``::slope of a linear equation that relates the
    leaf life span to the senescence rate,
    see [`senescence_rate!`](@ref)
    """
    β_sen::Q2 = F(0.9)u"d"

    """
    4::``\\alpha_{ll}``::transform SLA to leaflifespan,
    equation given by [Reich1992](@cite)
    """
    α_ll = F(2.41)

    """
    4::``\\beta_{ll}``::transform SLA to leaflifespan,
    equation given by [Reich1992](@cite)
    """
    β_ll = F(0.38)

    """
    4::``Ψ_1``::temperature threshold: senescence starts to increase,
    see [`seasonal_component_senescence`](@ref)
    """
    Ψ₁ = F(775.0)

    """
    4::``Ψ_2``::temperature threshold: senescence reaches maximum,
    see [`seasonal_component_senescence`](@ref)
    """
    Ψ₂ = F(3000.0)

    """
    4::``SEN_{\\max}``::maximal seasonality factor for the senescence rate,
    see [`seasonal_component_senescence`](@ref)
    """
    SEN_max = F(3.0)

    ####################################################################################
    ## 5 Management
    ####################################################################################
    """
    5::``\\beta_{PAL, lnc}``::controls how strongly grazers prefer
    plant species with high leaf nitrogen content,
    see [`grazing!`](@ref)
    """
    β_PAL_lnc = F(1.5)

    """
    5::``\\alpha_{GRZ}``::total biomass [kg ha⁻¹] when the daily
    consumption by grazers reaches half of their
    maximal consumption defined by κ · livestock density,
    see [`grazing!`](@ref)
    """
    α_GRZ::Q11 = F(1000.0)u"kg / ha"

    """
    5::``\\kappa``::maximal consumption of a livestock unit per day,
    see [`grazing!`](@ref)
    """
    κ::Q10 = F(22.0)u"kg"

    """
    5::``\\alpha_{TRM}``::
    """
    α_TRM::Q11 = F(10000.0)u"kg / ha"

    """
    5::``\\beta_{TRM}``::defines together with the height of
    the plants and the livestock density
    the proportion of biomass that is trampled [ha m⁻¹],
    see [`trampling!`](@ref)
    """
    β_TRM::Q10 = F(5.0)u"kg"

    """
    5::``\\beta_{TRM, H}``::
    """
    β_TRM_H = F(0.5)

    """
    5::``\\alpha_{\\text{low}B}``::
    """
    α_lowB::Q11 = F(100.0)u"kg / ha"

    """
    5::``\\beta_{\\text{low}B}``::
    """
    β_lowB::Q12 = F(0.1)u"ha / kg"

    ####################################################################################
    ## 6 Clonal growth
    ####################################################################################
    """
    6::``\\beta_{clo}``::Proportion of biomass that growths to the neighbouring cells,
    see [`clonalgrowth!`](@ref)
    """
    β_clo = F(0.1)

    ####################################################################################
    ## 7 Water dynamics
    ####################################################################################
    """
    7::``\\alpha_{TR, sla}``::reference community weighted mean specific leaf area,
    if the community weighted mean specific leaf area is
    equal to `α_TR_sla` then transpiration is neither increased nor decreased,
    see `transpiration`](@ref)
    """
    α_TR_sla::Q15 = F(0.03)u"m^2 / g"

    """
    7::``\\beta_{TR, sla}``::controls how strongly a
    community mean specific leaf area that deviates
    from `α_TR_sla` is affecting the transpiration,
    see [`transpiration`](@ref)
    """
    β_TR_sla = F(0.4)

    ####################################################################################
    ## 8 Variance parameter for likelihood
    ####################################################################################
    """
    8::``\\sigma_{B}``::
    """
    b_biomass = F(1000.0)

    """
    8::``\\sigma_{sla}``::
    """
    b_sla = F(0.0005)

    """
    8::``\\sigma_{lnc}``::
    """
    b_lnc = F(0.5)

    """
    8::``\\sigma_{amc}``::
    """
    b_amc = F(0.001)

    """
    8::``\\sigma_{H}``::
    """
    b_height = F(0.01)

    """
    8::``\\sigma_{rsa}``::
    """
    b_rsa = F(0.004)
end


function SimulationParameter(input_obj::NamedTuple; exclude_not_used)
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
    if haskey(likelihood_included, :biomass) && !likelihood_included.biomass
        append!(excl_p, [:b_biomass])
    end

    if haskey(likelihood_included, :trait) && !likelihood_included.trait
        append!(excl_p, [:b_sla, :b_lnc, :b_amc, :b_height, :b_rsa])
    end

    if haskey(included, :potential_growth) && !included.potential_growth
        append!(excl_p, [:RUE_max, :k])
    end

    if isone(npatches) || (haskey(included, :clonalgrowth) && !included.clonalgrowth)
        append!(excl_p, [:β_clo])
    end

    if haskey(included, :radiation_red) && !included.radiation_red
        append!(excl_p, [:γ₁, :γ₂])
    end

    if haskey(included, :temperature_growth_reduction) &&
       !included.temperature_growth_reduction
        append!(excl_p, [:T₀, :T₁, :T₂, :T₃])
    end

    if haskey(included, :season_red) && !included.season_red
        append!(excl_p, [:SEA_min, :SEA_max, :ST₁, :ST₂])
    end

    if haskey(included, :water_growth_reduction) && !included.water_growth_reduction
        water_names = [:ϕ_sla, :η_min_sla, :η_max_sla, :β_η_sla, :β_sla, :δ_wrsa, :δ_sla,
                       :β_wrsa, :η_min_wrsa, :η_max_wrsa, :β_η_wrsa]
        append!(excl_p, water_names)
    end

    if haskey(included, :nutrient_growth_reduction) && !included.nutrient_growth_reduction
        nutrient_names = [:N_max, :ϕ_amc, :η_min_amc, :η_max_amc, :κ_red_amc, :β_η_amc,
                          :β_amc, :δ_amc, :δ_nrsa, :β_nrsa,
                          :η_min_nrsa, :η_max_nrsa, :β_η_nrsa]
        append!(excl_p, nutrient_names)
    end

    if haskey(included, :nutrient_growth_reduction) && !included.nutrient_growth_reduction &&
       haskey(included, :water_growth_reduction) && !included.water_growth_reduction
        append!(excl_p, [:ϕ_rsa])
    end

    if haskey(included, :pet_growth_reduction) && !included.pet_growth_reduction
        append!(excl_p, [:α_PET, :β_PET])
    end

    if haskey(included, :sla_transpiration) && !included.sla_transpiration
        append!(excl_p, [:α_TR_sla, :β_TR_sla])
    end

    if haskey(included, :belowground_competition) && !included.belowground_competition
        append!(excl_p, [:α_TSB, :β_TSB])
    end

    if  haskey(included, :grazing) && !included.grazing
        append!(excl_p, [:β_PAL_lnc, :κ, :α_GRZ])
    end

    if haskey(included, :trampling) && !included.trampling
        append!(excl_p, [:β_TRM, :α_TRM, :β_TRM_H])
    end

    if haskey(included, :mowing)  && !included.mowing &&
       haskey(included, :grazing)  && !included.grazing
       haskey(included, :trampling)  && !included.trampling
        append!(excl_p, [:α_lowB, :β_lowB])
    end

    if  haskey(included, :senescence) && !included.senescence
        append!(excl_p, [:α_sen, :β_sen, :α_ll, :β_ll])
    end

    if (haskey(included, :senescence) && !included.senescence) ||
       (haskey(included, :senescence_season) && !included.senescence_season)
        append!(excl_p, [:Ψ₁, :Ψ₂, :SEN_max])
    end

    if haskey(included, :community_height_red) && !included.community_height_red
        append!(excl_p, [:α_com_height, :β_com_height])
    end

    if haskey(included, :height_competition) && !included.height_competition
        append!(excl_p, [:β_height])
    end

    if haskey(included, :lowbiomass_avoidance) && !included.lowbiomass_avoidance
        append!(excl_p, [:α_lowB, :β_lowB])

    end

    return excl_p
end

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
        # α_sen = (Uniform(0, 0.01), as(Real, 0.0, 0.01)),
        β_sen = (truncated(Beta(2, 1); lower = 0.8),  as(Real, 0.8, 1.0),
            """a value of 1 means that the leaf life span is equal to the senescence rate,
            lower values account for for a lower senescence rate for the stem biomass"""),
        Ψ₁ = (Uniform(700.0, 3000.0), as(Real, 700.0, 3000.0),
            """Jouven (2006) used 775 for this parameter; this parameter should be lower
            than Ψ₂ which is 3000 because otherwise the senescence rate would be
            decreased in autumn"""),
        SEN_max = (truncated(Normal(3.0, 2.0); lower = 1.0, upper = 4.0),
            as(Real, 1.0, 4.0),
            """Jouven (2006) used the value three for this parameter, this means that the
            senescence rate can be three time higher under certain conditions;
            we decided to use a prior from one to four, this means that the senescence rate
            is not increased in autumn (0) to it is strongly increased (4)"""),
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
        b_rsa = (truncated(Cauchy(0, 0.01); lower = 0.0), asℝ₊, "text")
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
