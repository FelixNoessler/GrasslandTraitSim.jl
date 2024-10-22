module DashboardExt
    import Dates

    using Accessors
    using DimensionalData
    using GLMakie
    using GLMakie: Makie
    using GrasslandTraitSim
    using Printf
    using Unitful
    using Statistics

    const gts = GrasslandTraitSim

    include("dashboard/1_dashboard.jl")
    include("dashboard/2_layout.jl")
    include("dashboard/3_plots_paneA.jl")
    include("dashboard/3_plots_paneB.jl")
    include("dashboard/3_plots_paneC.jl")
    include("dashboard/3_plots_paneD.jl")
    include("dashboard/3_plots_paneE.jl")
    include("dashboard/4_prepare_input.jl")
end
