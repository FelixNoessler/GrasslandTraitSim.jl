@doc raw"""
Reduction of growth based on the plant available water
and the traits specific leaf area and root surface area
per belowground biomass.

Reduction of growth due to stronger water stress for plants with
lower specific root surface area per above ground biomass (`srsa`).

![Graphical overview of the functional response](../img/W_rsa_default.png)

"""
function water_reduction!(; container, W, PWP, WHC)
    @unpack included = container.simp
    @unpack Waterred, above_proportion = container.calc
    @unpack R_wrsa_04, x0_wrsa = container.transfer_function
    @unpack srsa = container.traits
    @unpack RSA_per_totalbiomass_Lolium, R_wrsa_04_Lolium,
            RSA_per_totalbiomass_influence,
            R_wrsa_04_min, R_wrsa_04_max, β_wrsa  = container.p

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
        ###### to growth reduction at 0.4 of Wsc
        ## midpoint of logistic function
        x0_reduction_at_04 =RSA_per_totalbiomass_Lolium -
            RSA_per_totalbiomass_Lolium / 10 ^ RSA_per_totalbiomass_influence

        ## slope of logistic function
        k_reduction_at_04 = 1 / (x0_reduction_at_04 -  RSA_per_totalbiomass_Lolium) *
            log((R_wrsa_04_max - R_wrsa_04_Lolium) /
                (R_wrsa_04_Lolium - R_wrsa_04_min))

        ## growth reduction at 0.4 of Wsc
        @. R_wrsa_04 = R_wrsa_04_min + (R_wrsa_04_max - R_wrsa_04_min) /
            (1 + exp(-k_reduction_at_04 *
                        ((1 - above_proportion) * srsa - x0_reduction_at_04)))

        ###### growth reduction due to water stress for different Wsc
        ## midpoint of logistic function
        @. x0_wrsa = log(1/R_wrsa_04 - 1) / β_wrsa + 0.4

        ## growth reduction
        @. Waterred = 1 / (1 + exp(-β_wrsa * (Wsc - x0_wrsa)))
    end

    return nothing
end

function plot_W_srsa(; θ = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; θ)
    xs = LinRange(-0.1, 1.1, 200)
    ymat = fill(0.0, length(xs), nspecies)

    WHC = 1u"mm"
    PWP = 0u"mm"
    W = 1 * u"mm"

    total_biomass = fill(2, nspecies)u"kg/ha"
    above_biomass = container.traits.abp .* total_biomass
    @. container.calc.above_proportion = above_biomass / total_biomass

    for (i, x) in enumerate(xs)
        water_reduction!(; container, W = x * u"mm", PWP, WHC)
        ymat[i, :] .= container.calc.Waterred
    end

    idx = sortperm(container.traits.srsa)
    R_04 = container.transfer_function.R_wrsa_04[idx]
    srsa = ustrip.(container.traits.srsa[idx])
    abp = container.traits.abp[idx]
    ymat = ymat[:, idx]
    colorrange = (minimum(srsa), maximum(srsa))

    fig = Figure(size = (1000, 500))
    ax1 = Axis(fig[1, 1],
        xlabel = "Plant available water (W_sc)",
        ylabel = "Growth reduction factor (W_rsa)\n← stronger reduction, less reduction →",
        limits = (-0.05, 1.05, -0.1, 1.1))

    for (i, r04) in enumerate(R_04)
        lines!(xs, ymat[:, i];
            color = srsa[i],
            colorrange)

        ##### reduction at 0.4
        scatter!([0.4], [r04];
            marker = :x,
            color = srsa[i],
            colorrange)
    end

    scatter!([0.4], [container.p.R_wrsa_04_Lolium];
        markersize = 15,
        color = :red)

    ax2 = Axis(fig[1, 2];
        xlabel = "root surface area per total biomass [m² g⁻¹]\n = belowground biomass fraction [-] ⋅\nroot surface area per belowground biomass [m² g⁻¹]",
        ylabel = "Growth reducer at Wsc = 0.4 (R_wrsa_04)")
    scatter!((1 .- abp) .* srsa, R_04;
        marker = :x,
        color = srsa,
        colorrange)
    hlines!([container.p.R_wrsa_04_min, container.p.R_wrsa_04_max]; color = :black)


    scatter!([ustrip(container.p.RSA_per_totalbiomass_Lolium)], [container.p.R_wrsa_04_Lolium];
        markersize = 15,
        color = :red)

    Label(fig[0, 1:2], "Influence of the root surface area per total biomass on the water stress growth reducer";
        halign = :left,
        font = :bold)
    Colorbar(fig[1, 3]; colorrange, label = "Root surface area per belowground biomass [m² g⁻¹]")

    linkyaxes!(ax1, ax2)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
