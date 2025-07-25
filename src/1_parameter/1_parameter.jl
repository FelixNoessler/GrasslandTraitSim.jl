"""
Parameter of the GrasslandTraitSim.jl model
"""
@kwdef mutable struct SimulationParameter{
    T, Qkg_MJ, Qkg_ha, Qha_kg, Qm2_g, Qg_m2, Qkg_g, Qha_MJ, QMJ_ha, QC, Qkg, Qm, Qcm3_g}

    ####################################################################################
    ## 1 Mean/reference trait values
    ####################################################################################
    ϕ_TRSA::Qm2_g = F(0.07)u"m^2 / g"
    ϕ_TAMC::T = F(0.2)
    ϕ_sla::Qm2_g = F(0.009)u"m^2 / g"

    ####################################################################################
    ## 2 Light interception and competition
    ####################################################################################
    γ_RUEmax::Qkg_MJ = F(3 / 1000)u"kg / MJ"
    γ_RUE_k::T = F(0.6)
    α_RUE_cwmH::T = F(0.95)

    ####################################################################################
    ## 3 Water stress
    ####################################################################################
    α_WAT_rsa05::T = F(0.9)
    β_WAT_rsa::T = F(7.0)
    δ_WAT_rsa::Qg_m2 = F(20.0)u"g / m^2"

    ####################################################################################
    ## 4 Nutrient stress
    ####################################################################################
    ω_NUT_totalN::Qkg_g = F(0.1)u"kg/g"
    ω_NUT_fertilization::Qha_kg = F(0.001)u"ha/kg"
    β_TS::T = F(1.0)
    α_NUT_TSB::Qkg_ha = F(15000.0)u"kg / ha"
    α_NUT_maxadj::T = F(10.0)
    α_NUT_amc05::T = F(0.95)
    α_NUT_rsa05::T = F(0.95)
    β_NUT_rsa::T = F(15.0)
    β_NUT_amc::T = F(15.0)
    δ_NUT_rsa::Qg_m2 = F(20.0)u"g / m^2"
    δ_NUT_amc::T = F(10.0)

    ####################################################################################
    ## 5 Maintenance costs for roots and mycorrhiza
    ####################################################################################
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
    α_SEN::T = F(0.05)
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
    # β_TRM_height::T = F(1.0)
    # α_TRM_LD::Qha = F(0.01)u"ha"

    ####################################################################################
    ## 7 Soil water dynamics
    ####################################################################################
    β_SND_WHC::T = F(0.5678)
    β_SLT_WHC::T = F(0.9228)
    β_CLY_WHC::T = F(0.9135)
    β_OM_WHC::T = F(0.6103)
    β_BLK_WHC::Qcm3_g = F(-0.2696)u"cm^3/g"
    β_SND_PWP::T = F(-0.0059)
    β_SLT_PWP::T = F(0.1142)
    β_CLY_PWP::T = F(0.5766)
    β_OM_PWP::T = F(0.2228)
    β_BLK_PWP::Qcm3_g = F(0.02671)u"cm^3/g"
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

function load_optim_result()
    return load(assetpath("data/optim.jld2"), "θ");
end

function optim_parameter()
    p = load_optim_result()
    simulation_keys = keys(SimulationParameter())
    p_subset = NamedTuple{filter(x -> x ∈ simulation_keys, keys(p))}(p)
    return SimulationParameter(; p_subset...)
end
