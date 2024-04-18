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
# using FiniteDiff
using ForwardDiff
using JLD2
using LinearAlgebra
using Parameters
using Printf
using Statistics
using StatsBase
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

    p = SimulationParameter()
    p_dict = Dict()
    for field in fields
        p_dict[field] = split(docs[field], "Default:")[1] #docs[field]
    end

    fields_ordered = sort(collect(keys(p_dict)))

    println(buf, "| Parameter | Value | Description |")
    println(buf, "|----------:|:------|:------------|")

    for k in fields_ordered
        print(buf, "| `$(k)` | $(p[k]) | ")
        for line in split(p_dict[k], "\n")
            print(buf, " ", rstrip(line))
        end
        println(buf, " |")
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


function __init__()
    @info "Loading grassland data from the Biodiversity Exploratories"
    datapath = joinpath(@__DIR__, "..", "assets", "data")
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
