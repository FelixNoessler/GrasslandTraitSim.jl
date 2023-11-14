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

    if any(x .< 0)
        return -Inf
    end

    lprior = 0.0
    for i in 1:nparameter
        lprior += logpdf(obj.prior_dists[i], x[i])
    end

    return lprior
end
