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
using Pkg.Artifacts
using PrettyTables
using Statistics
using Unitful
using UnPack

@template (FUNCTIONS, METHODS) =
    """
    $(SIGNATURES)
    $(DOCSTRING)
    """

include("main_functions.jl")
include("one_day.jl")

include("1_parameter/1_parameter.jl")

include("2_initialisation/1_input_data.jl")
include("2_initialisation/2_measured_data.jl")
include("2_initialisation/3_initialisation.jl")
include("2_initialisation/4_preallocation.jl")
include("2_initialisation/5_traits.jl")

include("3_biomass/1_growth/1_growth.jl")
include("3_biomass/2_senescence/1_senescence.jl")
include("3_biomass/3_management/1_grazing.jl")
include("3_biomass/3_management/2_mowing.jl")

include("4_height/height.jl")

include("5_water/water.jl")


const ASSETS_DIR = joinpath(@__DIR__, "..", "assets")
assetpath(files...) = normpath(joinpath(ASSETS_DIR, files...))

const DEFAULT_ARTIFACTS_DIR = artifact"hainich_data"
artifactpath(name) = @artifact_str(name)

function __init__()
    load_gm()
    load_input_data()
    load_traits()
    return nothing
end

# see extension for the implementation
function dashboard end

end
