module Vis

import Dates

using CairoMakie
using DimensionalData
using Distributions
using Accessors
using Statistics
using Unitful

makie_theme = Theme(fontsize = 18,
    Axis = (xgridvisible = false, ygridvisible = false,
        topspinevisible = false, rightspinevisible = false),
    GLMakie = (title = "Grassland Simulation",
        focus_on_show = true))
function set_global_theme(; theme = makie_theme)
    set_theme!(makie_theme)
end

function __init__()
    set_global_theme()
end

include("dashboard/dashboard.jl")
include("dashboard/dashbaord_layout.jl")
include("dashboard/dashboard_plotting.jl")
include("dashboard/dashboard_prepare_input.jl")

include("doc_figures/doc_figures_utils.jl")
include("doc_figures/clonalgrowth.jl")
include("doc_figures/functional_response.jl")
include("doc_figures/potential_growth.jl")
include("doc_figures/landuse.jl")
include("doc_figures/reducer_functions.jl")
include("doc_figures/height_influence.jl")
include("doc_figures/neighbours.jl")
include("doc_figures/gradient.jl")
include("doc_figures/plant_available_water.jl")
include("doc_figures/leaflifespan.jl")
include("doc_figures/community_height.jl")

include("abiotic.jl")

include("validation/validation.jl")

end # module GrasslandTraitVis
