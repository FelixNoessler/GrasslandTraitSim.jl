function load_gm(datapath)
    global traits_μ, traits_Σ, traits_ϕ = load(
        "$datapath/input/traits_gaussian_mixture.jld2", "μ", "Σ", "ϕ")

    return nothing
end

function inverse_logit(x)
    return exp(x) / (1 + exp(x))
end

"""
Generate random traits for the simulation.
"""
function random_traits!(; container)
    @unpack trait_seed, nspecies = container.simp
    @unpack traitmat = container.calc
    @unpack traits = container

    ### set seed
    if ismissing(trait_seed)
        trait_seed = rand(1:100000)
    end
    rng = Random.Xoshiro(trait_seed)

    d1 = MvNormal(traits_μ[1, :], Hermitian(traits_Σ[1, :, :]))
    d2 = MvNormal(traits_μ[2, :], Hermitian(traits_Σ[2, :, :]))

    ## generate random traits
    for i in Base.OneTo(nspecies)
        if rand(rng) < traits_ϕ[1]
            Random.rand!(rng, d1, @view traitmat[:, i])
        else
            Random.rand!(rng, d2, @view traitmat[:, i])
        end
    end

    ### backtransformation and add units
    @. traits.sla = exp(@view traitmat[1, :]) * u"m^2/g"
    @. traits.maxheight = exp(@view traitmat[2, :]) * u"m"
    @. traits.lnc = exp(@view traitmat[3, :]) * u"mg/g"
    @. traits.rsa = exp(@view traitmat[4, :]) * u"m^2/g"
    @. traits.amc = inverse_logit(@view traitmat[5, :])
    @. traits.abp = inverse_logit(@view traitmat[6, :])
    @. traits.lbp = inverse_logit(@view traitmat[7, :])

    # proportion of leaf biomass cannot be larger than 0.95 % of aboveground biomass
    for i in Base.OneTo(nspecies)
        if traits.lbp[i] > 0.95 * traits.abp[i]
            traits.lbp[i] = 0.95 * traits.abp[i]
        end
    end

    return nothing
end
