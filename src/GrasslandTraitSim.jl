module GrasslandTraitSim

import CSV
import Dates
import Random
import CairoMakie: Makie

using Accessors
using CairoMakie
using DataFrames
using DataFramesMeta
using DimensionalData
using Distributions
using DocStringExtensions
using ForwardDiff
using LinearAlgebra
using JLD2
using Printf
using ProtoStructs
using Statistics
using StatsBase
using PrettyTables
using TimeSeries
using TransformVariables
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
        "**Clonal growth**",
        "**Water dynamics**",
        "**Variance parameter for likelihood**"
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

include("4_water/water.jl")
include("5_likelihood/1_likelihood.jl")
include("6_visualization/1_visualization.jl")

include("height/height.jl")

const ASSETS_DIR = joinpath(@__DIR__, "..", "assets")
assetpath(files...) = normpath(joinpath(ASSETS_DIR, files...))

function __init__()
    @info "Loading grassland data from the Biodiversity Exploratories"
    datapath = assetpath("data")
    load_gm(datapath)
    load_data(datapath)

    set_global_theme()

    return nothing
end

makie_theme = Theme(fontsize = 18,
    Axis = (xgridvisible = false, ygridvisible = false,
        topspinevisible = false, rightspinevisible = false),
    GLMakie = (title = "Grassland Simulation",
        focus_on_show = true))
function set_global_theme(; theme = makie_theme)
    set_theme!(makie_theme)
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
        graz)

    global data = (;
        input,
        valid)

    return nothing
end


end
