function sample_prior()
    obj = model_parameters()
    nparameter = length(obj.names)
    vals = Array{Float64}(undef, nparameter)

    for i in 1:nparameter
        vals[i] = rand(obj.prior_dists[i])
    end
    return vals
end

function prior_logpdf(obj, x)
    nparameter = length(obj.names)

    neg_filter = obj.names .∉ Ref(["moistureconv_alpha", "moistureconv_beta"])
    if any(x[neg_filter] .< 0)
        return -Inf
    end

    lprior = 0.0
    for i in 1:nparameter
        lprior += logpdf(obj.prior_dists[i], x[i])
    end

    return lprior
end
