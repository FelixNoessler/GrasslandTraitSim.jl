module GrasslandTraitSim

import Dates
import Random

using JLD2
using LinearAlgebra
using Unitful
using Distributions
using UnPack
using DimensionalData

##### submodules
include("lib/Valid/Valid.jl")
include("lib/Vis/Vis.jl")

include("main_functions.jl")
include("one_day.jl")
include("initialisation/initialisation.jl")
include("growth/growth.jl")
include("water/water.jl")
include("traits/traits.jl")


function __init__()
    datapath = joinpath(@__DIR__, "..", "assets", "data")
    load_gm(datapath)
end

end
