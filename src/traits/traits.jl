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

The traits are generated using a bivariate Gaussian mixture model
with full covariance matrices. For each species
either the first or the second Gaussian distribution is used to
generate the log/logit-transformed traits. The traits are then backtransformed
to the original scale and the units are added. If the proportion of the leaf mass
of the total plant mass (`lbp`) is larger than 0.95 % of the proportion of the
aboveground mass of the total mass (`abp`), `lbp` is set to 0.95 % of `abp`.

The Gaussian mixture model was fitted to the data with the function
`BayesianGaussianMixture` of [scikit-learn](@cite).

Overview of the traits:

| trait       | unit   | description                               | transformation |
| ----------- | ------ | ----------------------------------------- | -------------- |
| `sla`       | m² g⁻¹ | specific   leaf area                      | log            |
| `height`    | m      | plant height                              | log            |
| `lnc`      | mg g⁻¹ | leaf nitrogen content per leaf dry mass   | log            |
| `rsa` | m² g⁻¹ | root surface area per aboveground biomass | log            |
| `amc`       | -      | arbuscular mycorrhizal colonisation rate  | logit          |
| `abp`      | -      | aboveground dry mass per plant dry mass   | logit          |
| `lbp`      | -      | leaf dry mass per plant dry mass          | logit          |

"""
function random_traits!(; prealloc, input_obj)
    @unpack trait_seed, nspecies = input_obj.simp
    @unpack traitmat = prealloc.calc
    @unpack traits = prealloc

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
    @. traits.height = exp(@view traitmat[2, :]) * u"m"
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

@doc raw"""
Calculates the similarity between plants concerning their investment
in fine roots and collaboration with mycorrhiza.

The trait similarity is build with the traits root surface area per
aboveground biomass (`rsa`) and the arbuscular mycorrhizal
colonisation rate (`amc`).

Standardized residuals are calculated for both traits:
```math
\text{amc_resid} =
```

The trait similarity between plant species $i$ and
plant species $u$ for $T$ traits is calculated as follows:
```math
\text{trait_similarity}_{i,u} =
    1-\frac{\sum_{t=1}^{t=T}
        |\text{scaled_trait}_{t,i} - \text{scaled_trait}_{t,u}|}{T}
```

To give each functional trait an equal influence,
the trait values have been scaled by the 5 % ($Q_{0.05, t}$)
and 95 % quantile ($Q_{0.95, t}$) of trait values of 100 plant species:
```math
\text{scaled_trait}_{t,i} =
    \frac{\text{trait}_{t,i} - Q_{0.05, t}}
    {Q_{0.95, t} - Q_{0.05, t}}
```

If the rescaled trait values were below zero or above one, the values were
set to zero or one respectively.
"""
function similarity_matrix!(; input_obj, prealloc)
    @unpack nspecies = input_obj.simp
    @unpack amc, rsa = prealloc.traits
    @unpack amc_resid, rsa_above_resid, TS = prealloc.calc

    if isone(nspecies)
        TS .= [1.0;;]
        return nothing
    end

    amc_resid .= (amc .- mean(amc)) ./ std(amc)
    rsa_above_resid .= (rsa .- mean(rsa)) ./ std(rsa)

    for i in Base.OneTo(nspecies)
        for u in Base.OneTo(nspecies)
            TS[i, u] = (amc_resid[i] - amc_resid[u]) ^ 2 +
                       (rsa_above_resid[i] - rsa_above_resid[u]) ^ 2
        end
    end

    TS .= 1 .- TS ./ maximum(TS)

    return nothing
end
