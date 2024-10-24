"""
Calculates the similarity between plants concerning their investment
in fine roots and collaboration with mycorrhiza.
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

"""
Models the density-dependent competiton for nutrients between plants.
"""
function nutrient_competition!(; container, total_biomass)
    @unpack nutrients_adj_factor, TS_biomass, TS = container.calc
    @unpack included, nspecies = container.simp

    if !included.belowground_competition
        @info "No below ground competition for resources!" maxlog=1
        @. nutrients_adj_factor = 1.0
        return nothing
    end

    @unpack α_NUT_TSB, α_NUT_maxadj = container.p

    TS_biomass .= 0.0u"kg/ha"
    for s in 1:nspecies
        for i in 1:nspecies
            TS_biomass[s] += TS[s, i] * total_biomass[i]
        end
    end

    for i in eachindex(nutrients_adj_factor)
        nutrients_adj_factor[i] = α_NUT_maxadj * exp(log(1/α_NUT_maxadj) / α_NUT_TSB * TS_biomass[i])
    end

    return nothing
end

"""
Reduction of growth based on plant available nutrients and
the traits arbuscular mycorrhizal colonisation and
root surface area per belowground biomass.
"""
function nutrient_reduction!(; container, nutrients, total_biomass)
    @unpack included, nspecies = container.simp
    @unpack Nutred = container.calc

    nutrient_competition!(; container, total_biomass)

    if !included.nutrient_growth_reduction
        @info "No nutrient reduction!" maxlog=1
        @. Nutred = 1.0
        return nothing
    end

    @unpack R_05, x0 = container.transfer_function
    @unpack nutrients_splitted, nutrients_adj_factor,
            N_amc, N_rsa, above_proportion = container.calc
    @unpack ϕ_rsa, ϕ_amc, α_NUT_amc05, α_NUT_rsa05,
            β_NUT_rsa, β_NUT_amc, δ_NUT_rsa, δ_NUT_amc = container.p
    @unpack amc, srsa = container.traits

    @. nutrients_splitted = nutrients * nutrients_adj_factor

    ###### 1 relate the root surface area per total biomass
    ###### to growth reduction at 0.5 of Np = R_05
    ## inflection of logistic function ∈ [0, 1]
    x0_R_05 = ϕ_rsa + 1 / δ_NUT_rsa * log((1 - α_NUT_rsa05) / α_NUT_rsa05)

    ## growth reduction at 0.5 of Np ∈ [0, 1]
    @. R_05 = 1 / (1 + exp(-δ_NUT_rsa * ((1 - above_proportion) * srsa - x0_R_05)))

    ###### growth reduction due to nutrient stress for different Np
    ## inflection point of logistic function ∈ [0, ∞]
    @. x0 = log((1 - R_05)/ R_05) / β_NUT_rsa + 0.5

    ## growth reduction
    @. N_rsa = 1 / (1 + exp(-β_NUT_rsa * (nutrients_splitted - x0)))


    ###### 2 relate the arbuscular mycorrhizal colonisation
    ###### to growth reduction at 0.5 of Np = R_05
    ## inflection of logistic function ∈ [0, 1]
    x0_R_05 = ϕ_amc + 1 / δ_NUT_amc * log((1 - α_NUT_amc05) / α_NUT_amc05)

    ## growth reduction at 0.5 of Np ∈ [0, 1]
    @. R_05 = 1 / (1 + exp(-δ_NUT_amc * ((1 - above_proportion) * amc - x0_R_05)))

    ###### growth reduction due to nutrient stress for different Np
    ## inflection point of logistic function ∈ [0, ∞]
    @. x0 = log((1 - R_05)/ R_05) / β_NUT_amc + 0.5

    ## growth reduction
    @. N_amc = 1 / (1 + exp(-β_NUT_amc * (nutrients_splitted - x0)))


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

    @unpack δ_NUT_amc, α_NUT_amc05, ϕ_amc = container.p
    @unpack amc = container.traits
    @unpack above_proportion = container.calc
    x0_R_05 = ϕ_amc + 1 / δ_NUT_amc * log((1 - α_NUT_amc05) / α_NUT_amc05)
    R_05 = @. 1 / (1 + exp(-δ_NUT_amc * ((1 - above_proportion) * amc - x0_R_05)))

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
    scatter!([0.5], [container.p.α_NUT_amc05];
        markersize = 15,
        color = :red)

    ax2 = Axis(fig[1, 2];
        xlabel = "Arbuscular mycorrhizal colonisation\nper total biomass [-]",
        ylabel = "Growth reducer at Np = 0.5 (R_05)")
    scatter!(amc_total, R_05;
        marker = :x,
        color = amc_total,
        colorrange)
    scatter!([ustrip(container.p.ϕ_amc)], [container.p.α_NUT_amc05];
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

    @unpack δ_NUT_rsa, α_NUT_rsa05, ϕ_rsa = container.p
    @unpack srsa = container.traits
    @unpack above_proportion = container.calc
    x0_R_05 = ϕ_rsa + 1 / δ_NUT_rsa * log((1 - α_NUT_rsa05) / α_NUT_rsa05)
    R_05 = @. 1 / (1 + exp(-δ_NUT_rsa * ((1 - above_proportion) * srsa - x0_R_05)))

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
    scatter!([0.5], [container.p.α_NUT_rsa05];
        markersize = 15,
        color = :red)


    ax2 = Axis(fig[2, 2];
        xlabel = "Root surface area per total biomass [m² g⁻¹]",
        ylabel = "Growth reducer at Np = 0.5 (R_05)")
    scatter!(rsa_total, R_05;
        marker = :x,
        color = rsa_total,
        colorrange)
    scatter!([ustrip(container.p.ϕ_rsa)], [container.p.α_NUT_rsa05];
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
    @unpack α_NUT_TSB, α_NUT_maxadj = container.p

    TS_B = LinRange(0, 1.5 * ustrip(α_NUT_TSB), 200)u"kg / ha"
    nutrients_adj_factor = @. α_NUT_maxadj * exp(log(1/α_NUT_maxadj) / α_NUT_TSB * TS_B)


    fig = Figure()
    Axis(fig[1, 1]; xlabel = "∑ TS ⋅ B [kg ⋅ ha⁻¹]",
         ylabel = "nutrient adjustment factor [-]")
    lines!(ustrip.(TS_B), nutrients_adj_factor; linestyle = :solid, color = :coral2, linewidth = 2)

    hlines!(1; linestyle = :dash, color = :black)

    scatter!([ustrip(α_NUT_TSB), 0.0], [1.0, α_NUT_maxadj])
    text!(ustrip(α_NUT_TSB), 1.0; text = "α_NUT_TSB")

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
