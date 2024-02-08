function lprior(x; inference_obj)
    lprior = 0.0
    for k in keys(inference_obj.priordists)
        lprior += logpdf(inference_obj.priordists[k], x[k])
    end
    return lprior
end

function sample_prior(; inference_obj)
    p_names = keys(inference_obj.priordists)
    vals = Float64[]
    for p in p_names
        push!(vals, rand(inference_obj.priordists[p]))
    end
    return (; zip(p_names, vals)...)
end
