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
    ############################# Community potential growth
    γ_RUEmax::Qkg_MJ = F(3 / 1000)u"kg / MJ"
    γ_RUE_k::T = F(0.6)
    α_RUE_cwmH::T = F(0.95)

    ############################# Competition / shading
    β_LIG_H::T = F(1.0)

    ####################################################################################
    ## 3 Belowground competition
    ####################################################################################
    ############################# Water competition
    α_WAT_rsa05::T = F(0.9)
    β_WAT_rsa::T = F(7.0)
    δ_WAT_rsa::Qg_m2 = F(20.0)u"g / m^2"

    ############################# Nutrient competition
    α_NUT_Nmax::Qg_kg = F(35.0)u"g/kg"
    α_NUT_TSB::Qkg_ha = F(15000.0)u"kg / ha"
    α_NUT_maxadj::T = F(10.0)
    α_NUT_amc05::T = F(0.95)
    α_NUT_rsa05::T = F(0.95)
    β_NUT_rsa::T = F(15.0)
    β_NUT_amc::T = F(15.0)
    δ_NUT_rsa::Qg_m2 = F(20.0)u"g / m^2"
    δ_NUT_amc::T = F(10.0)

    ############################# Root investment
    κ_ROOT_amc::T = F(0.02)
    κ_ROOT_rsa::T = F(0.01)

    ####################################################################################
    ## 4 Environmental and seasonal growth adjustment
    ####################################################################################
    γ_RAD1::Qha_MJ = F(4.45e-6)u"ha / MJ"
    γ_RAD2::QMJ_ha = F(50000.0)u"MJ / ha"
    ω_TEMP_T1::QC = F(4.0)u"°C"
    ω_TEMP_T2::QC = F(10.0)u"°C"
    ω_TEMP_T3::QC = F(20.0)u"°C"
    ω_TEMP_T4::QC = F(35.0)u"°C"
    ζ_SEA_ST1::QC = F(775.0)u"°C"
    ζ_SEA_ST2::QC = F(1450.0)u"°C"
    ζ_SEAmin::T = F(0.9)
    ζ_SEAmax::T = F(1.5)

    ####################################################################################
    ## 5 Senescence
    ####################################################################################
    α_SEN_month::T = F(0.05)
    β_SEN_sla::T = F(1.5)
    ψ_SEN_ST1::QC = F(775.0)u"°C"
    ψ_SEN_ST2::QC = F(3000.0)u"°C"
    ψ_SENmax::T = F(1.5)

    ####################################################################################
    ## 6 Management
    ####################################################################################
    β_GRZ_lnc::T = F(1.2)
    β_GRZ_H::T = F(2.0)
    η_GRZ::T = F(2.0)
    κ_GRZ::Qkg = F(22.0)u"kg"
    ϵ_GRZ_minH::Qm = F(0.05)u"m"
end


function parameter_doc(; html = false)
    param_description = (;
        ϕ_rsa = "Reference root surace area",
        ϕ_amc = "Reference arbuscular mycorriza colonisation rate",
        ϕ_sla = "Reference specific leaf area",
        γ_RUEmax = "Maximum radiation use efficiency",
        γ_RUE_k =  "Extinction coefficient",
    )

    p = optim_parameter()
    p_keys = collect(keys(p))
    p_values = collect(values(p))
    p_descriptions = [haskey(param_description, k) ? param_description[k] : "TODO" for k in p_keys]
    data = hcat(p_keys, p_values, p_descriptions)

    if html
        return pretty_table(HTML, data; alignment = [:r, :l, :l], header = ["Parameter", "Value", "Description"], backend = Val(:html))
    end

    return pretty_table(data; alignment = [:r, :l, :l], header = ["Parameter", "Value", "Description"])
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
