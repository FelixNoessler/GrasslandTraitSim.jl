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
