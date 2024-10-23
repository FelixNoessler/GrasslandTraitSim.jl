"""
Parameter of the GrasslandTraitSim.jl model
"""
@kwdef mutable struct SimulationParameter{
    T, Qkg_MJ, Qkg_ha, Qm2_g, Qg_m2, Qg_kg, Qha_MJ, QMJ_ha, QC, Qkg}

    ####################################################################################
    ## 1 Mean/reference trait values
    ####################################################################################
    ϕ_rsa::Qm2_g = F(0.07)u"m^2 / g"
    ϕ_amc::T = F(0.2)
    ϕ_sla::Qm2_g = F(0.009)u"m^2 / g"

    ####################################################################################
    ## 2 Light interception and competition
    ####################################################################################
    RUE_max::Qkg_MJ = F(3 / 1000)u"kg / MJ"
    k::T = F(0.6)
    self_shading_severity::T = F(0.75)

    ####################################################################################
    ## 3 Belowground competition
    ####################################################################################
    ############################# Water competition
    α_wrsa_05::T = F(0.9)
    β_wrsa::T = F(7.0)
    δ_wrsa::Qg_m2 = F(20.0)u"g / m^2"

    ############################# Nutrient competition
    N_max::Qg_kg = F(35.0)u"g/kg"
    TSB_max::Qkg_ha = F(40000.0)u"kg / ha"
    TS_influence::T = F(1.0)
    nutadj_max::T = F(4.0)
    α_namc_05::T = F(0.95)
    α_nrsa_05::T = F(0.95)
    β_nrsa::T = F(15.0)
    β_namc::T = F(15.0)
    δ_nrsa::Qg_m2 = F(20.0)u"g / m^2"
    δ_namc::T = F(10.0)

    ############################# Root investment
    κ_maxred_amc::T = F(0.02)
    κ_maxred_srsa::T = F(0.01)

    ####################################################################################
    ## 4 Environmental and seasonal growth adjustment
    ####################################################################################
    γ₁::Qha_MJ = F(4.45e-6)u"ha / MJ"
    γ₂::QMJ_ha = F(50000.0)u"MJ / ha"
    T₀::QC = F(4.0)u"°C"
    T₁::QC = F(10.0)u"°C"
    T₂::QC = F(20.0)u"°C"
    T₃::QC = F(35.0)u"°C"
    ST₁::QC = F(775.0)u"°C"
    ST₂::QC = F(1450.0)u"°C"
    SEA_min::T = F(0.7)
    SEA_max::T = F(1.3)

    ####################################################################################
    ## 5 Senescence
    ####################################################################################
    α_sen_month::T = F(0.001)
    β_sen_sla::T = F(0.3)
    Ψ₁::QC = F(775.0)u"°C"
    Ψ₂::QC = F(3000.0)u"°C"
    SEN_max::T = F(3.0)

    ####################################################################################
    ## 6 Management
    ####################################################################################
    β_PAL_lnc::T = F(1.2)
    β_height_GRZ::T = F(2.0)
    η_GRZ::T = F(2.0)
    κ::Qkg = F(22.0)u"kg"
end


# """
#     SimulationParameter(; kwargs...)

# Here is an overview of the parameters that are used in the model. In addition
# to the parameters listed here, a regression equation with parameters not listed here
# from [Gupta1979](@cite) is used to derive the water holding capacity and
# the permanent wilting point (see [`input_WHC_PWP!`](@ref)).


# $(MYNEWFIELDS)
# """
# @kwdef mutable struct SimulationParameter{T, Qkg_MJ, Qkg_ha, Qha_kg, Qm2_g, Qg_m2, Qg_kg,
#                                           Qha_MJ, QMJ_ha, QC, Qkg}

#     """
#     3::``ST_1``::is a threshold of the temperature degree days,
#     above which the seasonality factor is set to `SEA_min` and
#     descreases to `SEA_max`,
#     see [`seasonal_reduction!`](@ref)
#     """
#     ST₁::QC = F(775.0)u"°C"

#     """
#     3::``ST_2``::is a threshold of the temperature degree-days,
#     where the seasonality growth factor is set to `SEA_min`,
#     see [`seasonal_reduction!`](@ref)
#     """
#     ST₂::QC = F(1450.0)u"°C"

#     """
#     3::``SEA_{\\min}``::is the minimal value of the seasonal effect,
#     see [`seasonal_reduction!`](@ref)
#     """
#     SEA_min::T = F(0.7)

#     """
#     3::``SEA_{\\max}``::is the maximal value of the seasonal effect,
#     see [`seasonal_reduction!`](@ref)
#     """
#     SEA_max::T = F(1.3)

#     ####################################################################################
#     ## 4 Senescence
#     ####################################################################################
#     """
#     4::``\\alpha_{SEN}``::senescence rate-intercept of a linear equation that relate
#     the leaf life span to the senescence rate,
#     see [`senescence_rate!`](@ref)
#     """
#     α_sen_month::T = F(0.001)

#     """
#     4::``\\phi_{sen, sla}``::TODO,
#     see [`water_reduction!`](@ref)
#     """
#     ϕ_sla::Qm2_g = F(0.009)u"m^2 / g"

#     """
#     4::``\\beta_{SEN}``::TODO
#     see [`senescence_rate!`](@ref)
#     """
#     β_sen_sla::T = F(0.3)

#     """
#     4::``Ψ_1``::temperature threshold: senescence starts to increase,
#     see [`seasonal_component_senescence`](@ref)
#     """
#     Ψ₁::QC = F(775.0)u"°C"

#     """
#     4::``Ψ_2``::temperature threshold: senescence reaches maximum,
#     see [`seasonal_component_senescence`](@ref)
#     """
#     Ψ₂::QC = F(3000.0)u"°C"

#     """
#     4::``SEN_{\\max}``::maximal seasonality factor for the senescence rate,
#     see [`seasonal_component_senescence`](@ref)
#     """
#     SEN_max::T = F(3.0)

#     ####################################################################################
#     ## 5 Management
#     ####################################################################################
#     """
#     5::``\\beta_{PAL, lnc}``::controls how strongly grazers prefer
#     plant species with high leaf nitrogen content,
#     see [`grazing!`](@ref)
#     """
#     β_PAL_lnc::T = F(1.2)

#     """
#     5::``\\eta_{GRZ}``::defines with  κ · livestock density the aboveground
#     biomass [kg ha⁻¹] when the daily consumption by grazers reaches half of
#     their maximal consumption,
#     see [`grazing!`](@ref)
#     """
#     η_GRZ::T = F(25.0)

#     """
#     5::``\\kappa``::maximal consumption of a livestock unit per day,
#     see [`grazing!`](@ref)
#     """
#     κ::Qkg = F(22.0)u"kg"

#     ####################################################################################
#     ## 7 Water dynamics
#     ####################################################################################

#     """
#     7::``\\beta_{TR, sla}``::controls how strongly a
#     community mean specific leaf area that deviates
#     from `ϕ_sla` is affecting the transpiration,
#     see [`transpiration`](@ref)
#     """
#     β_TR_sla::T = F(0.4)
# end


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
