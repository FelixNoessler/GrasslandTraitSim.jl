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
function similarity_matrix!(; container)
    @unpack nspecies = container.simp
    @unpack amc, srsa = container.traits
    @unpack amc_resid, rsa_resid, TS = container.calc

    if isone(nspecies)
        TS .= [1.0;;]
        return nothing
    end

    amc_resid .= (amc .- mean(amc)) ./ std(amc)
    rsa_resid .= (srsa .- mean(srsa)) ./ std(srsa)

    for i in Base.OneTo(nspecies)
        for u in Base.OneTo(nspecies)
            TS[i, u] = (amc_resid[i] - amc_resid[u]) ^ 2 +
                       (rsa_resid[i] - rsa_resid[u]) ^ 2
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
\text{nutrients_adj_factor} =
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

- `nutrients_adj_factor` is the factor that adjusts the
  plant available nutrients [-]
- `TS` is the trait similarity matrix, $TS \in [0,1]^{N \times N}$ [-]
- `B` is the biomass vector, $B \in [0, ∞]^{N}$ [kg ha⁻¹]
- `β_TSB` is the exponent of the below ground
  competition factor [-]

![](../img/nut_adjustment.png)
"""
function below_ground_competition!(; container, total_biomass)
    @unpack nutrients_adj_factor, TS_biomass, TS = container.calc
    @unpack included, nspecies = container.simp

    if !included.belowground_competition
        @info "No below ground competition for resources!" maxlog=1
        @. nutrients_adj_factor = 1.0
        return nothing
    end

    @unpack TSB_max, TSB_k, nutadj_max = container.p

    TS_biomass .= 0.0u"kg/ha"
    for s in 1:nspecies
        for i in 1:nspecies
            TS_biomass[s] += TS[s, i] * total_biomass[i]
        end
    end

    for i in eachindex(nutrients_adj_factor)
        # TODO change documentation
        nutrients_adj_factor[i] = nutadj_max * (1 - exp(TSB_k * (TS_biomass[i]  - TSB_max)))

        if nutrients_adj_factor[i] < 0
            nutrients_adj_factor[i] = 0.0
        end
    end

    return nothing
end

"""
Reduction of growth based on plant available nutrients and
the traits arbuscular mycorrhizal colonisation and
root surface area per belowground biomass.

Reduction of growth due to stronger nutrient stress for lower
arbuscular mycorrhizal colonisation (`AMC`).

![Graphical overview of the AMC functional response](../img/N_amc_default.png)

Reduction of growth due to stronger nutrient stress for lower specific
root surface area per belowground biomass (`srsa`).

![Graphical overview of the functional response](../img/N_rsa_default.png)

"""
function nutrient_reduction!(; container, nutrients, total_biomass)
    @unpack included, nspecies = container.simp
    @unpack Nutred = container.calc

    below_ground_competition!(; container, total_biomass)

    if !included.nutrient_growth_reduction
        @info "No nutrient reduction!" maxlog=1
        @. Nutred = 1.0
        return nothing
    end

    @unpack R_05, x0 = container.transfer_function
    @unpack nutrients_splitted, nutrients_adj_factor,
            N_amc, N_rsa, above_proportion = container.calc
    @unpack ϕ_rsa, ϕ_amc, α_namc_05, α_nrsa_05,
            β_nrsa, β_namc, δ_nrsa, δ_namc = container.p
    @unpack amc, srsa = container.traits

    # nutrients = totalN/N_max
    @. nutrients_splitted = nutrients * nutrients_adj_factor

    ###### 1 relate the root surface area per total biomass
    ###### to growth reduction at 0.5 of Np = R_05
    ## inflection of logistic function ∈ [0, 1]
    x0_R_05 = ϕ_rsa + 1 / δ_nrsa * log((1 - α_nrsa_05) / α_nrsa_05)

    ## growth reduction at 0.5 of Np ∈ [0, 1]
    @. R_05 = 1 / (1 + exp(-δ_nrsa * ((1 - above_proportion) * srsa - x0_R_05)))

    ###### growth reduction due to nutrient stress for different Np
    ## inflection point of logistic function ∈ [0, ∞]
    @. x0 = log((1 - R_05)/ R_05) / β_nrsa + 0.5

    ## growth reduction
    @. N_rsa = 1 / (1 + exp(-β_nrsa * (nutrients_splitted - x0)))


    ###### 2 relate the arbuscular mycorrhizal colonisation
    ###### to growth reduction at 0.5 of Np = R_05
    ## inflection of logistic function ∈ [0, 1]
    x0_R_05 = ϕ_amc + 1 / δ_namc * log((1 - α_namc_05) / α_namc_05)

    ## growth reduction at 0.5 of Np ∈ [0, 1]
    @. R_05 = 1 / (1 + exp(-δ_namc * ((1 - above_proportion) * amc - x0_R_05)))

    ###### growth reduction due to nutrient stress for different Np
    ## inflection point of logistic function ∈ [0, ∞]
    @. x0 = log((1 - R_05)/ R_05) / β_namc + 0.5

    ## growth reduction
    @. N_amc = 1 / (1 + exp(-β_namc * (nutrients_splitted - x0)))


    ###### 3 calculate the nutrient reduction factor
    @. Nutred = max(N_amc, N_rsa)

    for s in 1:nspecies
        if nutrients_splitted[s] <= 0.0
            Nutred[s] = 0.0
        elseif nutrients_splitted[s] >= 1.0
            Nutred[s] = 1.0
        end
    end

    return nothing
end


function plot_N_amc(; θ = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; θ)
    @reset container.simp.included.belowground_competition = false
    container.calc.nutrients_adj_factor .= 1.0
    xs = LinRange(0.0, 1.0, 200)
    ymat = fill(0.0, length(xs), nspecies)
    abp = container.traits.abp
    @. container.calc.above_proportion = abp
    for (i, x) in enumerate(xs)
        nutrient_reduction!(; container, nutrients = x,
                            total_biomass = fill(50.0u"kg/ha", nspecies))
        ymat[i, :] .= container.calc.N_amc
    end

    @unpack δ_namc, α_namc_05, ϕ_amc = container.p
    @unpack amc = container.traits
    @unpack above_proportion = container.calc
    x0_R_05 = ϕ_amc + 1 / δ_namc * log((1 - α_namc_05) / α_namc_05)
    R_05 = @. 1 / (1 + exp(-δ_namc * ((1 - above_proportion) * amc - x0_R_05)))

    amc = container.traits.amc
    amc_total = (1 .- abp) .* amc
    colorrange = (minimum(amc_total), maximum(amc_total))

    fig = Figure(size = (1000, 500))

    ax1 = Axis(fig[1, 1];
        xlabel = "Nutrient index (Np)",
        ylabel = "Growth reduction factor (N_amc)\n← stronger reduction, less reduction →",
        title = "Influence of the mycorrhizal colonisation",
        limits = (-0.05, 1.05, -0.1, 1.1))
    for (i, r05) in enumerate(R_05)
        lines!(xs, ymat[:, i];
            color = amc_total[i],
            colorrange)
        scatter!([0.5], [r05];
            marker = :x,
            color = amc_total[i],
            colorrange)
    end
    scatter!([0.5], [container.p.α_namc_05];
        markersize = 15,
        color = :red)

    ax2 = Axis(fig[1, 2];
        xlabel = "Arbuscular mycorrhizal colonisation\nper total biomass [-]",
        ylabel = "Growth reducer at Np = 0.5 (R_05)")
    scatter!(amc_total, R_05;
        marker = :x,
        color = amc_total,
        colorrange)
    scatter!([ustrip(container.p.ϕ_amc)], [container.p.α_namc_05];
        markersize = 15,
        color = :red)

    Colorbar(fig[1, 3]; colorrange,
             label = "Arbuscular mycorrhizal colonisation\nper total biomass [-]")

    linkyaxes!(ax1, ax2)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end


function plot_N_srsa(; θ = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; θ)
    @reset container.simp.included.belowground_competition = false
    container.calc.nutrients_adj_factor .= 1.0
    xs = LinRange(0, 1.0, 200)
    ymat = fill(0.0, length(xs), nspecies)
    abp = container.traits.abp
    @. container.calc.above_proportion = abp
    for (i, x) in enumerate(xs)
        nutrient_reduction!(; container, nutrients = x,
                            total_biomass = fill(50.0u"kg/ha", nspecies))
        ymat[i, :] .= container.calc.N_rsa
    end

    @unpack δ_nrsa, α_nrsa_05, ϕ_rsa = container.p
    @unpack srsa = container.traits
    @unpack above_proportion = container.calc
    x0_R_05 = ϕ_rsa + 1 / δ_nrsa * log((1 - α_nrsa_05) / α_nrsa_05)
    R_05 = @. 1 / (1 + exp(-δ_nrsa * ((1 - above_proportion) * srsa - x0_R_05)))

    srsa = ustrip.(container.traits.srsa)
    rsa_total = (1 .- abp) .* srsa
    colorrange = (minimum(rsa_total), maximum(rsa_total))

    fig = Figure(size = (1000, 500))

    ax1 = Axis(fig[2, 1],
        xlabel = "Nutrient index (Np)",
        ylabel = "Growth reduction factor (N_rsa)\n← stronger reduction, less reduction →",
        limits = (-0.05, 1.05, -0.1, 1.1))
    for (i, r05) in enumerate(R_05)
        lines!(xs, ymat[:, i];
            color = rsa_total[i],
            colorrange)
        scatter!([0.5], [r05];
            marker = :x,
            color = rsa_total[i],
            colorrange)
    end
    scatter!([0.5], [container.p.α_nrsa_05];
        markersize = 15,
        color = :red)


    ax2 = Axis(fig[2, 2];
        xlabel = "Root surface area per total biomass [m² g⁻¹]",
        ylabel = "Growth reducer at Np = 0.5 (R_05)")
    scatter!(rsa_total, R_05;
        marker = :x,
        color = rsa_total,
        colorrange)
    scatter!([ustrip(container.p.ϕ_rsa)], [container.p.α_nrsa_05];
        markersize = 15,
        color = :red)

    Label(fig[1, 1:2], "Influence of the root surface area per total biomass on the nutrient stress growth reducer";
        halign = :left,
        font = :bold)

    Colorbar(fig[2, 3]; colorrange, label = "Root surface area per total biomass [m² g⁻¹]")

    linkyaxes!(ax1, ax2)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end

function plot_nutrient_adjustment(; θ = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; θ)
    @unpack TSB_max, TSB_k, nutadj_max = container.p

    TS_B = LinRange(0, 1.2 * ustrip(TSB_max), 200)u"kg / ha"

    nutrients_adj_factor = @. nutadj_max * (1 - exp(TSB_k * (TS_B  - TSB_max)))
    nutrients_adj_factor[nutrients_adj_factor .< 0] .= 0.0

    fig = Figure()
    Axis(fig[1, 1]; xlabel = "∑ TS ⋅ B [kg ⋅ ha⁻¹]",
         ylabel = "nutrient adjustment factor [-]")
    lines!(ustrip.(TS_B), nutrients_adj_factor; linestyle = :solid, color = :coral2, linewidth = 2)

    hlines!(1; linestyle = :dash, color = :black)

    scatter!([ustrip(TSB_max), 0.0], [0.0, nutadj_max])
    text!(ustrip(TSB_max), 0.0; text = "TSB_max")

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
