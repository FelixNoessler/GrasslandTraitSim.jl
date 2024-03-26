function create_container(; nspecies = nothing)
    trait_input = if isnothing(nspecies)
        input_traits()
    else
        nothing
    end

    if isnothing(nspecies)
        nspecies = length(trait_input.amc)
    end

    input_obj = validation_input(;
        plotID = "HEG01", nspecies)
    p = SimulationParameter()
    prealloc = preallocate_vectors(; input_obj);
    prealloc_specific = preallocate_specific_vectors(; input_obj);
    container = initialization(; input_obj, p, prealloc, prealloc_specific,
                                   trait_input)

    return nspecies, container
end
