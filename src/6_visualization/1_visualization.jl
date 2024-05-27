include("2_dashboard.jl")
include("3_dashbaord_layout.jl")
include("4_dashboard_plotting.jl")
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
    p = SimulationParameter(; param...)


    if !isnothing(θ)
        for k in keys(θ)
            p[k] = θ[k]
        end
    end

    prealloc = preallocate_vectors(; input_obj);
    prealloc_specific = preallocate_specific_vectors(; input_obj);
    container = initialization(; input_obj, p, prealloc, prealloc_specific,
                                   trait_input)

    return nspecies, container
end
