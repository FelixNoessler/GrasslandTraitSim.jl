# function read_mcmc_object(filename; name = "res")
#     obj = load(filename)[name]
#     nexternal_chains = length(obj)
#     parameter_names = obj[1]["setup"]["names"]
#     names = vcat(parameter_names, ["posterior", "ll", "prior"])

#     ninternal_chains = length(obj[1]["chain"])
#     nsamples, nparameter = size(obj[1]["chain"][1])
#     mat = Array{Float64, 4}(undef, nexternal_chains, ninternal_chains, nsamples, nparameter)

#     for e in 1:nexternal_chains
#         for i in 1:ninternal_chains
#             mat[e, i, :, :] .= obj[e]["chain"][i]
#         end
#     end

#     return DimArray(mat,
#         (external_chain = 1:nexternal_chains,
#             internal_chain = 1:ninternal_chains,
#             sample = 1:nsamples,
#             parameter = names))
# end

# function sample_posterior(m)
#     nchains, nichains, nsamples, nparameter = size(m)
#     return vec(m[sample = sample((nsamples ÷ 2):nsamples),
#         internal_chain = sample(1:nichains),
#         external_chain = sample(1:nchains)])[1:(nparameter - 3)]
# end

function sample_posterior(obj; chain = nothing)
    ndraws = size(obj, :draw)
    nchains = size(obj, :chain)
    internal_chains = size(obj, :internal_chain)


    if isnothing(chain)
        chain = StatsBase.sample(1:nchains)
    end
    return vec(obj[draw = StatsBase.sample((ndraws ÷ 2):ndraws),
        chain = chain,
        internal_chain = StatsBase.sample(1:internal_chains)])
end
