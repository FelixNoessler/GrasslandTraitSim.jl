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
using Parameters
using Printf
using Statistics
using StatsBase
using PrettyTables
using TimeSeries
using TransformVariables
using Unitful

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

include("lib/valid/valid.jl")
include("lib/visualization/visualization.jl")
include("main_functions.jl")
include("one_day.jl")
include("cut_biomass.jl")
include("initialisation/initialisation.jl")
include("growth/growth.jl")
include("water/water.jl")
include("traits/traits.jl")


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

end
