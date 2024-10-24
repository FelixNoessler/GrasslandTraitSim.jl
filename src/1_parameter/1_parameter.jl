"""
Parameter of the GrasslandTraitSim.jl model
"""
@kwdef mutable struct SimulationParameter{
    T, Qkg_MJ, Qkg_ha, Qm2_g, Qg_m2, Qg_kg, Qha_MJ, QMJ_ha, QC, Qkg, Qm}

    ####################################################################################
    ## 1 Mean/reference trait values
    ####################################################################################
    ϕ_rsa::Qm2_g = F(0.07)u"m^2 / g"
    ϕ_amc::T = F(0.2)
    ϕ_sla::Qm2_g = F(0.009)u"m^2 / g"

    ####################################################################################
    ## 2 Light interception and competition
    ####################################################################################
    γ_RUEmax::Qkg_MJ = F(3 / 1000)u"kg / MJ"
    γ_k::T = F(0.6)
    α_LIE_comH::T = F(0.75)
    β_height::T = F(0.5)

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
    κ_ROOT_amc::T = F(0.02)
    κ_ROOT_rsa::T = F(0.01)

    ####################################################################################
    ## 4 Environmental and seasonal growth adjustment
    ####################################################################################
    γ₁::Qha_MJ = F(4.45e-6)u"ha / MJ"
    γ₂::QMJ_ha = F(50000.0)u"MJ / ha"
    ω_TEMP_T1::QC = F(4.0)u"°C"
    ω_TEMP_T2::QC = F(10.0)u"°C"
    ω_TEMP_T3::QC = F(20.0)u"°C"
    ω_TEMP_T4::QC = F(35.0)u"°C"
    ζ_SEA_ST1::QC = F(775.0)u"°C"
    ζ_SEA_ST2::QC = F(1450.0)u"°C"
    ζ_SEAmin::T = F(0.7)
    ζ_SEAmax::T = F(1.3)

    ####################################################################################
    ## 5 Senescence
    ####################################################################################
    α_SEN_month::T = F(0.001)
    β_SEN_sla::T = F(0.3)
    Ψ_ST1::QC = F(775.0)u"°C"
    Ψ_ST2::QC = F(3000.0)u"°C"
    Ψ_SENmax::T = F(3.0)

    ####################################################################################
    ## 6 Management
    ####################################################################################
    β_GRZ_lnc::T = F(1.2)
    β_GRZ_H::T = F(2.0)
    η_GRZ::T = F(2.0)
    κ_GRZ::Qkg = F(22.0)u"kg"
    ϵ_GRZ_minH::Qm = F(0.05)u"m"
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
