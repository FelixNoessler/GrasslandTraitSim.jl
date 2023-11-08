function sample_prior()
    obj = model_parameters()
    nparameter = length(obj.names)
    vals = Array{Float64}(undef, nparameter)

    for i in 1:nparameter
        d = truncated(Normal(obj.mean[i], obj.sd[i]);
            lower = obj.lb[i], upper = obj.ub[i])
        vals[i] = rand(d)
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
        d = obj.prior_dists[i]

        # d = truncated(Normal(obj.mean[i], obj.sd[i]);
        #     lower = obj.lb[i], upper = obj.ub[i])
        lprior += logpdf(d, x[i])
    end

    return lprior
end
