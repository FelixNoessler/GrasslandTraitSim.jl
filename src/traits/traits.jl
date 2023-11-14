function load_gm(datapath)
    global traits_μ, traits_Σ, traits_ϕ = load(
        "$datapath/input/traits_gaussian_mixture.jld2", "μ", "Σ", "ϕ")

    return nothing
end

function inverse_logit(x)
    return exp(x) / (1 + exp(x))
end

"""
    random_traits!(; calc, input_obj)

Generate random traits for the simulation.

The traits are generated using a bivariate Gaussian mixture model
with full covariance matrices. For each species
either the first or the second Gaussian distribution is used to
generate the log/logit-transformed traits. The traits are then backtransformed
to the original scale and the units are added. If the proportion of the leaf mass
of the total plant mass (`lmpm`) is larger than 0.95 % of the proportion of the
aboveground mass of the total mass (`ampm`), `lmpm` is set to 0.95 % of `ampm`.

The Gaussian mixture model was fitted to the data with the function
`BayesianGaussianMixture` of [scikit-learn](@cite).

Overview of the traits:

| trait       | unit   | description                               | transformation |
| ----------- | ------ | ----------------------------------------- | -------------- |
| `sla`       | m² g⁻¹ | specific   leaf area                      | log            |
| `height`    | m      | plant height                              | log            |
| `lncm`      | mg g⁻¹ | leaf nitrogen content per leaf dry mass   | log            |
| `rsa_above` | m² g⁻¹ | root surface area per aboveground biomass | log            |
| `amc`       | -      | arbuscular mycorrhizal colonisation rate  | logit          |
| `ampm`      | -      | aboveground dry mass per plant dry mass   | logit          |
| `lmpm`      | -      | leaf dry mass per plant dry mass          | logit          |

"""
function random_traits!(; calc, input_obj)
    @unpack trait_seed, nspecies = input_obj.simp
    @unpack traitmat = calc.calc
    @unpack traits = calc

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
    @. traits.lncm = exp(@view traitmat[3, :]) * u"mg/g"
    @. traits.rsa_above = exp(@view traitmat[4, :]) * u"m^2/g"
    @. traits.amc = inverse_logit(@view traitmat[5, :])
    @. traits.ampm = inverse_logit(@view traitmat[6, :])
    @. traits.lmpm = inverse_logit(@view traitmat[7, :])

    # proportion of leaf biomass cannot be larger than 0.95 % of aboveground biomass
    for i in Base.OneTo(nspecies)
        if traits.lmpm[i] > 0.95 * traits.ampm[i]
            traits.lmpm[i] = 0.95 * traits.ampm[i]
        end
    end

    return nothing
end

@doc raw"""
    similarity_matrix!(; input_obj, calc)

Calculates the similarity between plants concerning their investment
in fine roots and collaboration with mycorrhiza.

The trait similarity is build with the traits root surface area per
aboveground biomass (`rsa_above`) and the arbuscular mycorrhizal
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
function similarity_matrix!(; input_obj, calc)
    @unpack nspecies = input_obj.simp
    @unpack amc, rsa_above, TS = calc.traits
    @unpack nspecies = input_obj.simp
    @unpack amc_resid, rsa_above_resid = calc.calc

    amc_resid .= (amc .- mean(amc)) ./ std(amc)
    rsa_above_resid .= (rsa_above .- mean(rsa_above)) ./ std(rsa_above)

    TS .= 0.0
    for i in Base.OneTo(nspecies)
        for u in Base.OneTo(nspecies)
            TS[i, u] += abs(amc_resid[i] - amc_resid[u])
            TS[i, u] += abs(rsa_above_resid[i] - rsa_above_resid[u])
        end
    end

    TS .= 1 .- TS ./ maximum(TS)

    ### to avoid very small numbers/zeros in the matrix
    for i in Base.OneTo(nspecies)
        for u in Base.OneTo(nspecies)
            if TS[i, u] < 0.01
                TS[i, u] = 0.01
            end
        end
    end

    return nothing
end
