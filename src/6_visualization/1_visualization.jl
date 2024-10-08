include("2_dashboard.jl")
include("3_dashbaord_layout.jl")
include("4_dashboard_plots_paneA.jl")
include("4_dashboard_plots_paneB.jl")
include("4_dashboard_plots_paneC.jl")
include("4_dashboard_plots_paneD.jl")
include("4_dashboard_plots_paneE.jl")
include("5_dashboard_prepare_input.jl")



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
