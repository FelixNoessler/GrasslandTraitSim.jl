function create_container(; sim, valid, nspecies = nothing)
    trait_input = if isnothing(nspecies)
        valid.input_traits()
    else
        nothing
    end

    if isnothing(nspecies)
        nspecies = length(trait_input.amc)
    end

    input_obj = valid.validation_input(;
        plotID = "HEG01", nspecies)
    p = sim.Parameter()
    calc = sim.preallocate_vectors(; input_obj)
    prealloc = sim.preallocate_vectors(; input_obj);
    prealloc_specific = sim.preallocate_specific_vectors(; input_obj);
    container = sim.initialization(; input_obj, p, prealloc, prealloc_specific,
                                   trait_input)

    return nspecies, container
end
