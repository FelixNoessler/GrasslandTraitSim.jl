module GrasslandTraitSim

import Dates

using JLD2
using Unitful
using Distributions
using UnPack

include("main_functions.jl")
include("preallocation.jl")
include("initialization.jl")
include("neighbours.jl")
include("one_day.jl")
include("Growth/Growth.jl")
include("Water/Water.jl")
include("Functional response/FunctionalResponse.jl")
include("Traits/Traits.jl")

function __init__()
    datapath = joinpath(@__DIR__, "..", "lib", "GrasslandTraitData")
    Traits.load_gm(datapath)
end

end
