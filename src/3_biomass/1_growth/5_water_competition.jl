@doc raw"""
Reduction of growth based on the plant available water
and the traits specific leaf area and root surface area
per belowground biomass.

Reduction of growth due to stronger water stress for plants with
lower specific root surface area per above ground biomass (`srsa`).
"""
function water_reduction!(; container, W, PWP, WHC)
    @unpack included = container.simp
    @unpack Waterred, above_proportion = container.calc
    @unpack R_05, x0 = container.transfer_function
    @unpack srsa = container.traits
    @unpack ϕ_rsa, α_wrsa_05, β_wrsa, δ_wrsa = container.p

    if !included.water_growth_reduction
        @info "No water reduction!" maxlog=1
        @. Waterred = 1.0
        return nothing
    end

    Wsc = W > WHC ? 1.0 : W > PWP ? (W - PWP) / (WHC - PWP) : 0.0

    if iszero(Wsc)
        @. Waterred = 0.0
    elseif isone(Wsc)
        @. Waterred = 1.0
    else
        ###### relate the root surface area per total biomass
        ###### to growth reduction at 0.5 of Wsc = R_05
        ## inflection of logistic function ∈ [0, 1]
        x0_R_05 = ϕ_rsa + 1 / δ_wrsa * log((1 - α_wrsa_05) / α_wrsa_05)

        ## growth reduction at 0.5 of Wsc ∈ [0, 1]
        @. R_05 = 1 / (1 + exp(-δ_wrsa * ((1 - above_proportion) * srsa - x0_R_05)))

        ###### growth reduction due to water stress for different Wsc
        ## inflection point of logistic function ∈ [0, ∞]
        @. x0 = log((1 - R_05)/ R_05) / β_wrsa + 0.5

        ## growth reduction
        @. Waterred = 1 / (1 + exp(-β_wrsa * (Wsc - x0)))
    end

    return nothing
end

function plot_W_srsa(; θ = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; θ)
    xs = LinRange(0.0, 1.0, 200)
    ymat = fill(0.0, length(xs), nspecies)
    WHC = 1u"mm"
    PWP = 0u"mm"
    W = 1 * u"mm"
    abp = container.traits.abp
    @. container.calc.above_proportion = abp
    for (i, x) in enumerate(xs)
        water_reduction!(; container, W = x * u"mm", PWP, WHC)
        ymat[i, :] .= container.calc.Waterred
    end

    R_05 = container.transfer_function.R_05
    srsa = ustrip.(container.traits.srsa)
    rsa_total = (1 .- abp) .* srsa
    colorrange = (minimum(rsa_total), maximum(rsa_total))

    fig = Figure(size = (1000, 500))

    ax1 = Axis(fig[1, 1],
        xlabel = "Plant available water (W_sc)",
        ylabel = "Growth reduction factor (W_rsa)\n← stronger reduction, less reduction →",
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
    scatter!([0.5], [container.p.α_wrsa_05];
        markersize = 15,
        color = :red)

    ax2 = Axis(fig[1, 2];
        xlabel = "Root surface area per total biomass [m² g⁻¹]",
        ylabel = "Growth reducer at Wsc = 0.5 (R_05)")
    scatter!(rsa_total, R_05;
        marker = :x,
        color = rsa_total,
        colorrange)
    scatter!([ustrip(container.p.ϕ_rsa)], [container.p.α_wrsa_05];
        markersize = 15,
        color = :red)

    Label(fig[0, 1:2], "Influence of the root surface area per total biomass on the water stress growth reducer";
        halign = :left,
        font = :bold)
    Colorbar(fig[1, 3]; colorrange, label = "Root surface area per total biomass [m² g⁻¹]")

    linkyaxes!(ax1, ax2)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
