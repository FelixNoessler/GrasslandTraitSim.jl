module Traits

import Random

using Unitful
using Distributions
using JLD2
using LinearAlgebra
using UnPack

function load_gm(datapath)
    μ, Σ, ϕ = load("$datapath/input/traits_gaussian_mixture.jld2", "μ", "Σ", "ϕ")

    global mm_normald = [
        MvNormal(μ[1, :], Hermitian(Σ[1, :, :])),
        MvNormal(μ[2, :], Hermitian(Σ[2, :, :]))]
    global mm_prior = ϕ[1]

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
to the original scale and the units are added. Furthermore, the
two traits specific leaf area (`sla`) and the root surface area per
aboveground biomass (`rsa_above`) are calculated.

The Gaussian mixture model was fitted to the data with the function
`BayesianGaussianMixture` of [scikit-learn](@cite).


Overview of the traits:

| trait       | unit   | description                               | transformation |
| ----------- | ------ | ----------------------------------------- | -------------- |
| `la`        | mm²    | leaf area                                 | log            |
| `lfm`       | mg     | leaf fresh mass                           | log            |
| `ldm`       | mg     | leaf dry mass                             | log            |
| `ba`        | -      | biomass allocation                        | log            |
| `srsa`      | m² g⁻¹ | specific root surface area                | log            |
| `amc`       | -      | arbuscular mycorrhizal colonisation rate  | logit          |
| `height`    | m      | plant height                              | log            |
| `ldmpm`     | g g⁻¹  | leaf dry mass per plant dry mass          | log            |
| `lncm`      | mg g⁻¹ | leaf nitrogen content per leaf dry mass   | log            |
| `sla`       | m² g⁻¹ | specific leaf area                        | -              |
| `rsa_above` | m² g⁻¹ | root surface area per aboveground biomass | -              |
"""
function random_traits!(; calc, input_obj)
    @unpack constant_seed, nspecies = input_obj.simp
    @unpack traitmat = calc.calc
    @unpack traits = calc

    ### set seed
    seed = 88675
    if !constant_seed
        seed = rand(1:100000)
    end
    rng = Random.Xoshiro(seed)

    ## generate random traits
    for i in Base.OneTo(nspecies)
        if rand(rng) < mm_prior
            Random.rand!(rng, mm_normald[1], @view traitmat[:, i])
        else
            Random.rand!(rng, mm_normald[2], @view traitmat[:, i])
        end
    end

    ### backtransform the trait values
    for i in 1:5
        @views traitmat[i, :] .= exp.(traitmat[i, :])
    end
    @views traitmat[6, :] .= inverse_logit.(traitmat[6, :])
    for i in 7:9
        @views traitmat[i, :] .= exp.(traitmat[i, :])
    end

    ### add units
    @. traits[:la] = u"mm^2" * @view traitmat[1, :]
    @. traits[:lfm] = u"mg" * @view traitmat[2, :]
    @. traits[:ldm] = u"mg" * @view traitmat[3, :]
    @. traits[:ba] = @view traitmat[4, :]
    @. traits[:srsa] = u"m^2/g" * @view traitmat[5, :]
    @. traits[:amc] = @view traitmat[6, :]
    @. traits[:height] = u"m" * @view traitmat[7, :]
    @. traits[:ldmpm] = u"g/g" * @view traitmat[8, :]
    @. traits[:lncm] = u"mg/g" * @view traitmat[9, :]

    @. traits[:sla] = uconvert(u"m^2/g", traits[:la] / traits[:ldm])
    @. traits[:rsa_above] = traits[:srsa] * traits[:ba]

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

end
