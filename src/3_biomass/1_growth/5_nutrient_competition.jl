@doc raw"""
Derive a nutrient index by combining total nitrogen and carbon to nitrogen ratio.

```math
\begin{align*}
\text{CN_scaled} &= \frac{\text{CNratio} - \text{minCNratio}}
                    {\text{maxCNratio} - \text{minCN_ratio}} \\
\text{totalN_scaled} &= \frac{\text{totalN} - \text{mintotalN}}
                        {\text{N_max} - \text{mintotalN}} \\
\text{nutrients} &= \frac{1}{1 + exp(-\text{totalN_β} ⋅ \text{totalN_scaled}
                                     -\text{CN_β} ⋅ \text{CN_scaled}⁻¹)}
\end{align*}
```

- `CNratio`: carbon to nitrogen ratio [-]
- `totalN`: total nitrogen [g kg⁻¹]
- `minCNratio`: minimum carbon to nitrogen ratio [-]
- `maxCNratio`: maximum carbon to nitrogen ratio [-]
- `mintotalN`: minimum total nitrogen [g kg⁻¹]
- `N_max`: maximum total nitrogen [g kg⁻¹]
- `totalN_β`: scaling parameter for total nitrogen [-]
- `CN_β`: scaling parameter for carbon to nitrogen ratio [-]
- `nutrients`: nutrient index [-]

Additionally if more than one patch is simulated a gradient of nutrients can be added
and the last equations changes to:

```math
\text{nutrients} = \frac{1}{1 + exp(-\text{totalN_β} ⋅ \text{totalN_scaled}
                                    -\text{CN_β} ⋅ \text{CN_scaled}⁻¹
                                    -\text{nutheterog} * (\text{nutgradient} - 0.5))}
```

- `nutheterog`: heterogeneity of nutrients [-]
"""
function input_nutrients!(; prealloc, input_obj, p)
    @unpack nutrients = prealloc.patch_variables
    @unpack totalN = input_obj.site
    @unpack included = input_obj.simp

    #### data from the biodiversity exploratories
    # mintotalN = 1.2525
    # N_max = 30.63

    if included.nutrient_growth_reduction
        @. nutrients = totalN / p.N_max
    end

    return nothing
end

@doc raw"""
Calculates the similarity between plants concerning their investment
in fine roots and collaboration with mycorrhiza.

The trait similarity is build with the traits root surface area per
belowground biomass (`srsa`) and the arbuscular mycorrhizal
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
    @unpack amc, srsa = prealloc.traits
    @unpack amc_resid, rsa_above_resid, TS = prealloc.calc

    if isone(nspecies)
        TS .= [1.0;;]
        return nothing
    end

    amc_resid .= (amc .- mean(amc)) ./ std(amc)
    rsa_above_resid .= (srsa .- mean(srsa)) ./ std(srsa)

    for i in Base.OneTo(nspecies)
        for u in Base.OneTo(nspecies)
            TS[i, u] = (amc_resid[i] - amc_resid[u]) ^ 2 +
                       (rsa_above_resid[i] - rsa_above_resid[u]) ^ 2
        end
    end

    TS .= 1 .- TS ./ maximum(TS)

    return nothing
end

@doc raw"""
Models the density-dependent competiton for nutrients between plants.

Plant available nutrients are reduced if a large biomass of plant
species with similar root surface area per belowground biomass (`srsa`)
and arbuscular mycorrhizal colonisation (`amc`) is already present.

We define for $N$ species the trait similarity matrix $TS \in [0,1]^{N \times N}$ with
trait similarities between the species $i$ and $j$ ($ts_{i,j}$),
where $ts_{i,j} = ts_{j,i}$ and $ts_{i,i} = 1$:
```math
TS =
\begin{bmatrix}
    ts_{1,1} & ts_{1,2} & \dots &  & ts_{1,N} \\
    ts_{2,1} & ts_{2,2} &  & \\
    \vdots &  & \ddots &  & \\
    ts_{N,1} & & & & ts_{N,N} \\
\end{bmatrix}
= \begin{bmatrix}
    1 & ts_{1,2} & \dots &  & ts_{1,N} \\
    ts_{2,1} & 1 &  & \\
    \vdots &  & \ddots &  & \\
    ts_{N,1} & & & & 1 \\
\end{bmatrix}
```

and the biomass vector $B \in [0\,\text{kg ha⁻¹}, ∞\,\text{kg ha⁻¹}]^N$ with the biomass
of each plant species $b$:
```math
B =
\begin{bmatrix}
    b_1 \\
    b_2 \\
    \vdots \\
    b_N \\
\end{bmatrix}
```

Then, we multiply the trait similarity matrix $TS$ with the biomass vector $B$:
```math
TS \cdot B =
\begin{bmatrix}
    1 & ts_{1,2} & \dots &  & ts_{1,N} \\
    ts_{2,1} & 1 &  & \\
    \vdots &  & \ddots &  & \\
    ts_{N,1} & & & & 1 \\
\end{bmatrix} \cdot
\begin{bmatrix}
    b_1 \\
    b_2 \\
    \vdots \\
    b_N \\
\end{bmatrix} =
\begin{bmatrix}
    1 \cdot b_1 + ts_{1,2} \cdot b_2 + \dots + ts_{1,N} \cdot b_N \\
    ts_{2,1} \cdot b_1 + 1 \cdot b_2 + \dots + ts_{2,N} \cdot b_N \\
    \vdots \\
    ts_{N,1} \cdot b_1 + ts_{N,2} \cdot b_2 + \dots + 1 \cdot b_N \\
\end{bmatrix}
```

The factors are then calculated as follows:
```math
\text{biomass_density_factor} =
    \left(\frac{TS \cdot B}{\text{α_TSB}}\right) ^
    {- \text{β_TSB}} \\
```

The reduction factors control the density and increases the "functional dispersion"
of the root surface area per belowground biomass and the arbuscular
mycorrhizal colonisation.

The `TS` matrix is computed before the start of the simulation
([calculation of trait similarity](@ref similarity_matrix!))
and includes the traits arbuscular mycorrhizal colonisation rate (`amc`)
and the root surface area devided by the above ground biomass (`srsa`).

- `biomass_density_factor` is the factor that adjusts the
  plant available nutrients [-]
- `TS` is the trait similarity matrix, $TS \in [0,1]^{N \times N}$ [-]
- `B` is the biomass vector, $B \in [0, ∞]^{N}$ [kg ha⁻¹]
- `β_TSB` is the exponent of the below ground
  competition factor [-]

![](../img/below_influence.png)
"""
function below_ground_competition!(; container, total_biomass)
    @unpack biomass_density_factor, TS_biomass, TS = container.calc
    @unpack included, nspecies = container.simp

    if !included.belowground_competition
        @info "No below ground competition for resources!" maxlog=1
        @. biomass_density_factor = 1.0
        return nothing
    end

    @unpack β_TSB, α_TSB = container.p

    TS_biomass .= 0.0u"kg/ha"
    for s in 1:nspecies
        for i in 1:nspecies
            TS_biomass[s] += TS[s, i] * total_biomass[i]
        end
    end

    for i in eachindex(biomass_density_factor)
        # TODO add in manuscript and doc
        biomass_density_factor[i] = 2.0 / (1.0 + exp(-β_TSB * (α_TSB - TS_biomass[i])))
        # biomass_factor = (α_TSB / TS_biomass[i]) ^ β_TSB
        # biomass_density_factor[i] = min(3.0, max(0.33, biomass_factor))
    end

    return nothing
end

"""
Reduction of growth based on plant available nutrients and
the traits arbuscular mycorrhizal colonisation and
root surface area per belowground biomass.

Reduction of growth due to stronger nutrient stress for lower
arbuscular mycorrhizal colonisation (`AMC`).

- the strength of the reduction is modified by the parameter `δ_amc`

`δ_amc` equals 1:
![Graphical overview of the AMC functional response](../img/N_amc_default.png)

`δ_amc` equals 0.5:
![Graphical overview of the AMC functional response](../img/N_amc_0_5.png)

Reduction of growth due to stronger nutrient stress for lower specific
root surface area per belowground biomass (`srsa`).

- the strength of the reduction is modified by the parameter `δ_nrsa`

`δ_nrsa` equals 1:
![Graphical overview of the functional response](../img/N_rsa_default.png)

`δ_nrsa` equals 0.5:
![Graphical overview of the functional response](../img/N_rsa_0_5.png)
"""
function nutrient_reduction!(; container, nutrients, above_biomass, total_biomass)
    @unpack included = container.simp
    @unpack Nutred = container.calc

    if !included.nutrient_growth_reduction
        @info "No nutrient reduction!" maxlog=1
        @. Nutred = 1.0
        return nothing
    end

    @unpack A_amc, A_nrsa = container.transfer_function
    @unpack nutrients_splitted, biomass_density_factor,
            N_amc, nutrients_splitted, N_rsa,
            nutrients_splitted, above_proportion = container.calc
    @unpack δ_amc, δ_nrsa, ϕ_amc, ϕ_rsa, η_μ_amc, η_σ_amc,
            β_η_amc, β_η_nrsa, η_μ_nrsa, η_σ_nrsa, β_amc, β_nrsa = container.p
    @unpack amc, srsa = container.traits


    η_min_amc = η_μ_amc - η_σ_amc
    η_max_amc = η_μ_amc + η_σ_amc
    @. A_amc = (η_max_amc - (η_max_amc - η_min_amc) /
        (1 + exp(-β_η_amc * ((1-above_proportion)*amc - ϕ_amc)))) # TODO

    #### Root surface area per above ground biomass
    η_min_nrsa = η_μ_nrsa - η_σ_nrsa
    η_max_nrsa = η_μ_nrsa + η_σ_nrsa
    @. A_nrsa =  (η_max_nrsa + (η_min_nrsa - η_max_nrsa) /
        (1 + exp(-β_η_nrsa * ((1-above_proportion)*srsa - ϕ_rsa)))) # TODO


    @. nutrients_splitted = nutrients * biomass_density_factor
    @. nutrients_splitted = min(nutrients_splitted, 1.0) # TODO add to documentation
    @. N_amc = 1 - δ_amc + δ_amc /
               (1 + exp(-β_amc * (nutrients_splitted - A_amc)))
    @. N_rsa = 1 - δ_nrsa + δ_nrsa /
               (1 + exp(-β_nrsa * (nutrients_splitted - A_nrsa)))
    @. Nutred = max(N_amc, N_rsa)

    return nothing
end


function plot_N_amc(; δ_amc = nothing, θ = nothing, path = nothing)
    param = ifelse(isnothing(δ_amc), (;), (; δ_amc))
    nspecies, container = create_container_for_plotting(; θ, param)
    δ_amc = container.p.δ_amc


    container.calc.biomass_density_factor .= 1.0

    xs = LinRange(0.0, 1.0, 20)
    ymat = fill(0.0, length(xs), nspecies)
    above_biomass = ones(nspecies)u"kg/ha"
    total_biomass = fill(2, nspecies)u"kg/ha"

    for (i, x) in enumerate(xs)
        nutrient_reduction!(; container, nutrients = x, above_biomass,
                             total_biomass)
        ymat[i, :] .= container.calc.N_amc
    end

    idx = sortperm(container.traits.amc)
    x0s = container.transfer_function.A_amc[idx]
    A = 1 - container.p.δ_amc
    amc = container.traits.amc[idx]
    abp = container.traits.abp[idx]
    ymat = ymat[:, idx]
    colorrange = (minimum(amc), maximum(amc))

    fig = Figure(size = (1000, 500))
    Axis(fig[1, 1];
        xlabel = "Nutrient index",
        ylabel = "Growth reduction factor (N_amc)\n← stronger reduction, less reduction →",
        title = "Influence of the mycorrhizal colonisation",
        limits = (0, 1, nothing, nothing))
    hlines!([1-δ_amc]; color = :black)
    text!(0.7, 1-δ_amc + 0.02; text = "1 - δ_amc")
    for i in Base.OneTo(nspecies)
        lines!(xs, ymat[:, i];
            color = amc[i],
            colorrange)

        ##### midpoint
        x0_y = (1 - A) / 2 + A
        scatter!(x0s[i], x0_y;
            marker = :x,
            color = amc[i],
            colorrange)
    end
    ylims!(-0.05, 1.05)

    η_min_amc = container.p.η_μ_amc - container.p.η_σ_amc
    η_max_amc = container.p.η_μ_amc + container.p.η_σ_amc
    Axis(fig[1, 2];
         xlabel = "arbuscular mycorrhizal colonisation per total biomass [-]\n = belowground biomass fraction ⋅\narbuscular mycorrhizal colonisation [-]",
        ylabel = "Nutrient index\nat midpoint (A_amc)")
    for i in Base.OneTo(nspecies)
        scatter!((1-abp[i]) * amc[i], x0s[i];
            marker = :x,
            color = amc[i],
            colorrange)
    end
    hlines!([η_min_amc, η_max_amc]; color = :black)
    text!([0.0, 0.0], [η_min_amc, η_max_amc] .+ 0.02;
          text = ["η_min_amc = η_μ_amc - η_σ_amc", "η_max_amc = η_μ_amc + η_σ_amc"])
    vlines!(container.p.ϕ_amc; color = :black, linestyle = :dash)
    text!(container.p.ϕ_amc + 0.01,
          (η_max_amc - η_min_amc) * 4/5;
          text = "ϕ_amc")
    ylims!(nothing, η_max_amc + 0.1)
    Colorbar(fig[1, 3]; colorrange, label = "Arbuscular mycorrhizal colonisation [-]")

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end


function plot_N_srsa(; δ_nrsa = nothing, θ = nothing, path = nothing)
    param = ifelse(isnothing(δ_nrsa), (;), (; δ_nrsa))
    nspecies, container = create_container_for_plotting(; param, θ)
    δ_nrsa = container.p.δ_nrsa
    container.calc.biomass_density_factor .= 1.0

    xs = LinRange(0, 1.0, 20)
    ymat = fill(0.0, length(xs), nspecies)
    above_biomass = ones(nspecies)u"kg/ha"
    total_biomass = fill(2, nspecies)u"kg/ha"

    for (i, x) in enumerate(xs)
        nutrient_reduction!(; container, nutrients = x, above_biomass,
                            total_biomass)
        ymat[i, :] .= container.calc.N_rsa
    end

    ##################
    idx = sortperm(container.traits.srsa)
    x0s = container.transfer_function.A_nrsa[idx]
    A = 1 - container.p.δ_nrsa
    srsa = ustrip.(container.traits.srsa[idx])
    abp = container.traits.abp[idx]
    ymat = ymat[:, idx]
    colorrange = (minimum(srsa), maximum(srsa))
    ##################

    fig = Figure(size = (900, 500))

    Label(fig[1, 1:2], "Influence of the root surface area";
        halign = :left,
        font = :bold)

    Axis(fig[2, 1],
        xlabel = "Nutrient index",
        ylabel = "Growth reduction factor (N_rsa)\n← stronger reduction, less reduction →",
        limits = (0, 1, nothing, nothing))
    hlines!([1-δ_nrsa]; color = :black)
    text!(0.7, 1-δ_nrsa + 0.02; text = "1 - δ_nrsa")
    for (i, x0) in enumerate(x0s)
        lines!(xs, ymat[:, i];
            color =srsa[i],
            colorrange)

        ##### midpoint
        x0_y = (1 - A) / 2 + A
        scatter!([x0], [x0_y];
            marker = :x,
            color = srsa[i],
            colorrange)
    end
    ylims!(-0.1, 1.1)

    η_min_nrsa = container.p.η_μ_nrsa - container.p.η_σ_nrsa
    η_max_nrsa = container.p.η_μ_nrsa + container.p.η_σ_nrsa
    Axis(fig[2, 2];
        xlabel = "root surface area per total biomass [m² g⁻¹]\n = belowground biomass fraction ⋅\nroot surface area per belowground biomass [m² g⁻¹]",
        ylabel = "Nutrient index\nat midpoint (A_nrsa)")
    scatter!((1 .- abp) .* srsa, x0s;
        marker = :x,
        color = srsa,
        colorrange)
    hlines!([η_min_nrsa, η_max_nrsa]; color = :black)
    text!([0.02, 0.02], [η_min_nrsa, η_max_nrsa] .+ 0.02;
            text = ["η_min_nrsa = η_μ_nrsa - η_σ_nrsa", "η_max_nrsa = η_μ_nrsa + η_σ_nrsa"])
    vlines!(ustrip(container.p.ϕ_rsa); color = :black, linestyle = :dash)
    text!(ustrip(container.p.ϕ_rsa) + 0.001,
            (η_max_nrsa - η_min_nrsa) * 4/5;
            text = "ϕ_rsa")
    ylims!(nothing, η_max_nrsa + 0.1)

    Colorbar(fig[2, 3]; colorrange, label = "Root surface area per belowground biomass [m² g⁻¹]")

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end

function plot_below_influence(; θ = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; θ)

    #################### varying β_TSB, equal biomass, random traits
    orig_β_TSB = container.p.β_TSB
    below_effects = LinRange(0, 10, 30)u"ha / Mg"
    total_biomass = fill(container.p.α_TSB / (nspecies * mean(container.calc.TS)), nspecies)
    ymat = Array{Float64}(undef, nspecies, length(below_effects))

    for (i, below_effect) in enumerate(below_effects)
        container = @set container.p.β_TSB = below_effect
        below_ground_competition!(; container, total_biomass)
        ymat[:, i] .= container.calc.biomass_density_factor
    end

    traitsimmat = ustrip.(copy(container.calc.TS))
    traitsim = vec(mean(traitsimmat, dims = 1))
    idx = sortperm(traitsim)
    traitsim = traitsim[idx]
    ymat = ymat[idx, :]
    colorrange = (minimum(traitsim), maximum(traitsim))
    colormap = :viridis

    #####################

    ##################### artficial example
    mat = [1 0.8 0.2; 0.8 1 0.5; 0.2 0.5 1]
    total_biomass = [40.0, 10.0, 10.0]u"kg / ha"
    artificial_mat = Array{Float64}(undef, 3, length(below_effects))

    for i in eachindex(below_effects)
        c = (;
            calc = (; TS_biomass = zeros(3)u"kg / ha",
                      TS = mat,
                      biomass_density_factor = zeros(3)),
            simp = (; included = (; belowground_competition = true),
                      nspecies = 3),
            p = (; β_TSB = below_effects[i],
                   α_TSB = 0.4 * 80u"kg / ha"))
        below_ground_competition!(; container = c, total_biomass)

        artificial_mat[:, i] = c.calc.biomass_density_factor
    end

    artificial_labels = [
        "high biomass",
        "low biomass,\nshares traits\nwith species 1",
        "low biomass,\nshares few traits\nwith species 1"]

    #####################
    plot_below_effects = ustrip.(below_effects)

    fig = Figure(; size = (900, 800))
    Axis(fig[1, 1];
        xticklabelsvisible = false,
        title = "Real community with equal biomass")
    for i in Base.OneTo(nspecies)
        lines!(plot_below_effects, ymat[i, :];
            colorrange, colormap, color = traitsim[i])
    end
    lines!([0, maximum(plot_below_effects)], [1, 1];
        color = :black)
    vlines!(ustrip(orig_β_TSB))
    Colorbar(fig[1, 2]; colorrange, colormap, label = "Mean trait similarity")

    ax2 = Axis(fig[2, 1];
        xlabel = "Strength of resource partitioning (β_TSB)",
        title = "Artificial community")
    for i in 1:3
        lines!(plot_below_effects, artificial_mat[i, :];
            label = artificial_labels[i],
            linewidth = 3)
    end
    lines!([0.0, maximum(plot_below_effects)], ones(2);
        color = :black)
    axislegend(ax2; position = :lb)

    Label(fig[1:2, 0], "Plant available nutrient adjustment factor",
        rotation = pi / 2)

    # colgap!(fig.layout, 2, 10)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
