"""
Simulates the removal of biomass by grazing for each species.
"""
function grazing!(; container, LD, above_biomass, actual_height)
    @unpack lnc = container.traits
    @unpack η_GRZ, β_PAL_lnc, β_height_GRZ, κ = container.p
    @unpack defoliation, grazed_share, relative_lnc, ρ, relative_height, grazed,
            heightinfluence, height_ρ_biomass, feedible_biomass = container.calc
    @unpack nspecies = container.simp

    min_height = 0.05u"m"

    for s in 1:nspecies
        height_proportion_feedible = max(1 - min_height / actual_height[s], 0.0)
        feedible_biomass[s] = height_proportion_feedible * above_biomass[s]
    end

    sum_feedible_biomass = sum(feedible_biomass)

    if iszero(sum_feedible_biomass)
        container.calc.com.fodder_supply = κ * LD
        @. grazed = 0.0u"kg/ha"
        defoliation .+= grazed
        return nothing
    end

    #################################### total grazed biomass
    biomass_squarred = sum_feedible_biomass * sum_feedible_biomass
    α_GRZ = κ * LD * η_GRZ
    total_grazed = κ * LD * biomass_squarred / (α_GRZ * α_GRZ + biomass_squarred)

    container.calc.com.fodder_supply = κ * LD - total_grazed

    #################################### share of grazed biomass per species
    ## Palatability ρ
    relative_lnc .= lnc .* feedible_biomass ./ sum_feedible_biomass
    cwm_lnc = sum(relative_lnc)
    @. ρ = (lnc / cwm_lnc) ^ β_PAL_lnc

    ## Grazers feed more on tall plants
    relative_height .= actual_height .* feedible_biomass ./ sum_feedible_biomass
    cwm_height = sum(relative_height)
    @. heightinfluence = (actual_height / cwm_height) ^ β_height_GRZ

    @. height_ρ_biomass = heightinfluence * ρ * feedible_biomass
    grazed_share .= height_ρ_biomass ./ sum(height_ρ_biomass)

    #################################### add grazed biomass to defoliation
    @. grazed = grazed_share * total_grazed
    defoliation .+= grazed

    return nothing
end

function plot_grazing(; α_GRZ = nothing, β_PAL_lnc = nothing, θ = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; θ)

    if !isnothing(α_GRZ)
        container.p.α_GRZ = α_GRZ
    end

    if !isnothing(β_PAL_lnc)
        container.p.β_PAL_lnc = β_PAL_lnc
    end

    nbiomass = 80
    LD = 2u"ha ^ -1"
    biomass_vec = LinRange(0, 500, nbiomass)u"kg / ha"
    grazing_mat = Array{Float64}(undef, nspecies, nbiomass)

    for (i, biomass_val) in enumerate(biomass_vec)
        container.calc.defoliation .= 0.0u"kg / ha"
        above_biomass = 1 ./ container.traits.abp .* biomass_val

        grazing!(; container, LD, above_biomass, actual_height = container.traits.height)
        grazing_mat[:, i] = ustrip.(container.calc.defoliation)
    end

    idx = sortperm(container.traits.lnc)
    lnc = ustrip.(container.traits.lnc)[idx]
    grazing_mat = grazing_mat[idx, :]
    colorrange = (minimum(lnc), maximum(lnc))

    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1],
        xlabel = "Aboveground biomass per species [kg ha⁻¹]",
        ylabel = "Grazed biomass per species (graz)\n[kg ha⁻¹]",
        title = "")

    for i in 1:nspecies
        lines!(ustrip.(biomass_vec), grazing_mat[i, :];
            color = lnc[i],
            colorrange,
            linewidth = 3)
    end

    Colorbar(fig[1, 2]; colorrange, colormap = :viridis,
        label = "Leaf nitrogen content [mg g⁻¹]")

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end

function plot_η_GRZ(; θ = nothing, path = nothing)
    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1],
        xlabel = "Total biomass [dry mass kg ha⁻¹]",
        ylabel = "Grazed biomass (totgraz)\n[dry mass kg ha⁻¹]",
        title = "")

    for η_GRZ in [1, 5, 10, 20]
        x = LinRange(0, 3000, 120)

        LD = 2
        κ = 22

        k_exp = 2
        y = @. LD * κ * x^k_exp / ((κ * η_GRZ)^k_exp + x^k_exp)

        lines!(x, y, label = "$(κ * η_GRZ)",
            linewidth = 3)
    end

    axislegend("η_GRZ"; framevisible = true, position = :rb)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end
end
