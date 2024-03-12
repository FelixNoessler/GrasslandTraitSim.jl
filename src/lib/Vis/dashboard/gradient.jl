function gradient_evaluation(sim, valid; plotID, input_obj, valid_data, p, trait_input)
    p_vals = ustrip.(collect(p))
    p_keys = keys(p)

    p_cache = ParameterCache(sim);

    f = function(x)
        θ_type = eltype(x)

        p_obj = get_buffer(p_cache, sim, θ_type)
        for (i,k) in enumerate(p_keys)
            unit_k = unit(getproperty(p_obj, k))
            setfield!(p_obj, k, x[i] * unit_k)
        end

        valid.loglikelihood_model(sim;
            input_obj,
            data = valid_data,
            plotID,
            p = p_obj,
            trait_input,
            θ_type)
    end

    return ForwardDiff.gradient(f, p_vals)

    return FiniteDiff.finite_difference_gradient(f, p_vals)
end


mutable struct ParameterCache{T}
    normal::T
    diff::Any
end

function ParameterCache(sim::Module)
    return ParameterCache(sim.Parameter(), nothing)
end

function get_buffer(buffer::ParameterCache, sim::Module, T)
    if T <: ForwardDiff.Dual
        if isnothing(buffer.diff)
            buffer.diff = sim.Parameter(T)
        end
        return buffer.diff

    elseif T <: Float64
        return buffer.normal
    end
end
