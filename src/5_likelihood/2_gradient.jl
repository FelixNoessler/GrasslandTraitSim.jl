function gradient_evaluation(; plotID, input_obj, valid_data, p, trait_input)
    p_vals = ustrip.(collect(p))
    p_keys = keys(p)

    p_cache = ParameterCache();

    f = function(x)
        θ_type = eltype(x)

        p_obj = get_buffer(p_cache, θ_type)
        for (i,k) in enumerate(p_keys)
            unit_k = unit(p_obj[k])
            p_obj[k] = x[i] * unit_k
        end

        loglikelihood_model(;
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

function ParameterCache()
    return ParameterCache(SimulationParameter(), nothing)
end

function get_buffer(buffer::ParameterCache, T)
    if T <: ForwardDiff.Dual
        if isnothing(buffer.diff)
            buffer.diff = SimulationParameter(T)
        end
        return buffer.diff

    elseif T <: Float64
        return buffer.normal
    end
end
