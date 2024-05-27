@doc raw"""
Influence of mowing for plant species with different heights ($height$):
![Image of mowing effect](../img/mowing.png)
"""
function mowing!(; container, mowing_height)
    @unpack defoliation, mown, proportion_mown, actual_height, above_biomass = container.calc

    # --------- proportion of plant height that is mown
    proportion_mown .= max.(actual_height .- mowing_height, 0.0u"m") ./ actual_height

    # --------- add the removed biomass to the defoliation vector
    @. mown = proportion_mown * above_biomass
    defoliation .+= mown

    return nothing
end

function plot_mowing(; mowing_height = 0.07u"m",
    θ = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; θ)

    nbiomass = 50
    max_biomass = 150
    biomass_vec = LinRange(0, max_biomass, nbiomass)u"kg / ha"
    mowing_mat = Array{Float64}(undef, nspecies, nbiomass)



    for (i, biomass_i) in enumerate(biomass_vec)
        biomass = 1 ./ container.traits.abp .* biomass_i
        actual_height!(; container, biomass)

        container.calc.defoliation .= 0.0u"kg / ha"
        mowing!(; container, mowing_height)

        mowing_mat[:, i] = ustrip.(container.calc.defoliation)
    end

    idx = sortperm(container.traits.height)
    height = ustrip.(container.traits.height)[idx]
    mowing_mat = mowing_mat[idx, :]
    colorrange = (minimum(height), maximum(height))
    colormap = :viridis

    fig = Figure(;)
    Axis(fig[1, 1],
    xlabel = "Aboveground biomass per species [kg ha⁻¹]",
    ylabel = """Amount of aboveground biomass that is
            removed by mowing (mow) [kg ha⁻¹]""",
    title = "",
    aspect = DataAspect(),
    width = 400, height = 400)

    for i in 1:nspecies
    lines!(ustrip.(biomass_vec), mowing_mat[i, :];
    linewidth = 3, color = height[i], colorrange, colormap)
    lines!([0, max_biomass], [0, max_biomass]; linestyle = :dash, color = (:black, 0.01))
    end

    Colorbar(fig[1, 2]; colorrange, colormap, label = "Plant height [m]")

    resize_to_layout!(fig)

    if !isnothing(path)
    save(path, fig;)
    else
    display(fig)
    end

    return nothing
end
