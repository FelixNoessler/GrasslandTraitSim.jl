module GrasslandTraitSim

import CSV
import Dates
import Random

using Accessors
using DataFrames
using DataFramesMeta
using DimensionalData
using Distributions
using DocStringExtensions
using JLD2
using LinearAlgebra
using PrettyTables
using Statistics
using StatsBase
using Unitful
using UnPack

@template (FUNCTIONS, METHODS) =
    """
    $(SIGNATURES)
    $(DOCSTRING)
    """

struct MyNewFields <: DocStringExtensions.Abbreviation
end

const MYNEWFIELDS = MyNewFields()

function DocStringExtensions.format(abbrv::MyNewFields, buf, doc)
    local docs = get(doc.data, :fields, Dict())
    local binding = doc.data[:binding]
    local object = Docs.resolve(binding)
    local fields = isabstracttype(object) ? Symbol[] : fieldnames(object)

    param_groups = [
        "**Light interception and competition**",
        "**Belowground competition**",
        "**Environmental and seasonal growth adjustment**",
        "**Senescence**",
        "**Management**",
        "**Another parameter group**",
        "**Water dynamics**",
    ]

    p = SimulationParameter()
    latex_symbols = []
    field_docs = []
    field_group = []

    for field in fields
        first_part = split(docs[field], "Default:")[1]
        group_num, latex_symbol, doc_str = split(first_part, "::")
        push!(field_group, parse(Int64, group_num))
        push!(latex_symbols, latex_symbol)
        push!(field_docs, doc_str)
    end

    for g in 1:maximum(field_group)
        println(buf)
        println(buf, "# $(param_groups[g])")
        println(buf)
        println(buf, "| Parameter | Symbol       | Value        | Description |")
        println(buf, "| --------- | ------------ |:-------------|:------------|")

        is = findall(field_group .== g)
        for i in is
            print(buf, "| `$(fields[i])` | $(latex_symbols[i]) | $(p[fields[i]]) | ")
            for line in split(field_docs[i], "\n")
                print(buf, " ", rstrip(line))
            end
            println(buf, " |")
        end
    end
    println(buf)

    return nothing
end

include("main_functions.jl")
include("one_day.jl")

include("1_parameter/1_parameter.jl")

include("2_initialisation/1_input_data.jl")
include("2_initialisation/2_validation_data.jl")
include("2_initialisation/3_initialisation.jl")
include("2_initialisation/4_preallocation.jl")
include("2_initialisation/5_traits.jl")

include("3_biomass/1_growth/1_growth.jl")
include("3_biomass/2_senescence/1_senescence.jl")
include("3_biomass/3_management/1_grazing.jl")
include("3_biomass/3_management/2_mowing.jl")
include("3_biomass/3_management/3_cut_biomass_for_likelihood.jl")

include("4_height/height.jl")

include("5_water/water.jl")


const ASSETS_DIR = joinpath(@__DIR__, "..", "assets")
assetpath(files...) = normpath(joinpath(ASSETS_DIR, files...))

function __init__()
    datapath = assetpath("data")
    load_gm(datapath)
    load_data(datapath)

    return nothing
end

function load_data(datapath)
    ########### validation data
    soilmoisture = CSV.read("$datapath/validation/soilmoisture.csv",
        DataFrame)

    evaporation = CSV.read("$datapath/validation/evaporation.csv",
        DataFrame)

    measuredbiomass = CSV.read("$datapath/validation/measured_biomass.csv",
        DataFrame)

    measuredheight = CSV.read("$datapath/validation/measured_height.csv",
        DataFrame)

    mtraits = CSV.read("$datapath/validation/cwm_traits.csv",
        DataFrame)

    traits = (
        cwm = [mtraits.srsa mtraits.amc mtraits.abp mtraits.sla mtraits.height mtraits.lnc],
        dim = [:srsa, :amc, :abp, :sla, :height, :lnc],
        t = mtraits.date,
        num_t = mtraits.numeric_date,
        plotID = mtraits.plotID)

    fun_diversity = (;
        fdis = mtraits.fdis,
        t = mtraits.date,
        num_t = mtraits.numeric_date,
        plotID = mtraits.plotID
    )

    valid = (;
        soilmoisture,
        evaporation,
        traits,
        measuredbiomass,
        measuredheight,
        fun_diversity)

    ########### input data
    ## time dependent 2009-2022
    clim = CSV.read("$datapath/input/temperature_precipitation.csv",
        DataFrame)

    ## time dependent 2006-2008, temperature & precipitation
    dwd_clim = CSV.read("$datapath/input/temperature_precipitation_dwd.csv",
        DataFrame)

    ## time dependent 2006-2022
    pet = CSV.read("$datapath/input/pet.csv",
        DataFrame)

    ## time dependent 2006-2022
    par = CSV.read("$datapath/input/par.csv",
        DataFrame)

    ### mean index from 2011, 2014, 20117, 2021
    nut = CSV.read("$datapath/input/soilnutrients.csv",
        DataFrame)

    ## constant WHC & PWP
    soil = CSV.read("$datapath/input/soilwater.csv",
        DataFrame)

    ## time dependent 2006 - 2021
    mow = CSV.read("$datapath/input/mowing.csv",
        DataFrame)

    ## time dependent 2006 - 2021
    graz = CSV.read("$datapath/input/grazing.csv",
        DataFrame)
    supplementary_feeding = CSV.read("$datapath/input/supplementary_feeding.csv",
        DataFrame)

    ## constant approx coordinates (mainly for selecting calibration / validation sites)
    coord = CSV.read(
        "$datapath/input/approx_coordinates.csv",
        DataFrame)

    input_traits = CSV.read("$datapath/input/traits.csv",
        DataFrame)
    input_traits.lbp = 0.8 .* input_traits.abp
    input_traits.bbp = 1.0 .- input_traits.bbp

    input = (;
        traits = input_traits,
        clim,
        dwd_clim,
        pet,
        par,
        nut,
        soil,
        mow,
        graz,
        supplementary_feeding,
        coord)

    global data = (;
        input,
        valid)

    return nothing
end


function create_container_for_plotting(; nspecies = nothing, param = (;), θ = nothing, kwargs...)
    trait_input = if isnothing(nspecies)
        input_traits()
    else
        nothing
    end

    if isnothing(nspecies)
        nspecies = length(trait_input.amc)
    end

    input_obj = validation_input(;
        plotID = "HEG01", nspecies, kwargs...)
    p = SimulationParameter(;)

    if !isnothing(θ)
        for k in keys(θ)
                p[k] = θ[k]
            end
        end

    if !isnothing(param) && !isempty(param)
        for k in keys(param)
            p[k] = param[k]
        end
    end

    prealloc = preallocate_vectors(; input_obj);
    prealloc_specific = preallocate_specific_vectors(; input_obj);
    container = initialization(; input_obj, p, prealloc, prealloc_specific,
                                   trait_input)

    return nspecies, container
end

function load_optim_result()
    return load(assetpath("data/optim.jld2"), "θ");
end


function optim_parameter()
    θ = load_optim_result()
    return SimulationParameter(; θ...)
end

# see extension for the implementation
function dashboard end

end
