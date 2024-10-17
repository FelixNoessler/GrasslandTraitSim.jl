"""
Calculate the distribution of potential growth to each species based on share of the leaf
area index and the height of each species.
"""
function light_competition!(; container, above_biomass, actual_height)
    @unpack lais_heightinfluence, heightinfluence, light_competition, LAIs = container.calc
    @unpack LAItot = container.calc.com
    @unpack included = container.simp

    if iszero(LAItot)
        @. light_competition = 1
        return nothing
    end

    if !included.height_competition
        @info "Height influence turned off!" maxlog=1
        @. heightinfluence = 1.0
    else
        @unpack relative_height = container.calc
        @unpack β_height = container.p

        total_above_biomass = sum(above_biomass)
        relative_height .= actual_height .* above_biomass ./ total_above_biomass
        height_cwm = sum(relative_height)

        @. heightinfluence = (actual_height / height_cwm) ^ β_height
    end

    @. lais_heightinfluence = LAIs .* heightinfluence
    light_competition .= lais_heightinfluence ./ sum(lais_heightinfluence)

    return nothing
end

function plot_height_influence(; θ = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; θ)

    height_strength_exps = LinRange(0.0, 1.5, 40)
    above_biomass = fill(50, nspecies)u"kg / ha"
    ymat = Array{Float64}(undef, nspecies, length(height_strength_exps))
    orig_β_height = container.p.β_height

    ### otherwise the function won't be calculated
    ### the LAI is not used in the hieght influence function
    container.calc.com.LAItot = 0.2 * nspecies

    for (i, β_height) in enumerate(height_strength_exps)
        @reset container.p.β_height = β_height
        light_competition!(; container, above_biomass,
                           actual_height = container.traits.height)
        ymat[:, i] .= container.calc.heightinfluence
    end

    idx = sortperm(container.traits.height)
    height = ustrip.(container.traits.height)[idx]


    ymat = ymat[idx, :]
    colorrange = (minimum(height), maximum(height))

    mean_val = (mean(height) - minimum(height)) / (maximum(height) - minimum(height) )
    colormap = Makie.diverging_palette(0, 230; mid=mean_val)

    fig = Figure(; size = (700, 400))
    ax = Axis(fig[1, 1];
        ylabel = "Plant height growth factor (heightinfluence)",
        xlabel = "Influence strength of the plant height (β_height)",
        yticks = 0.0:5.0)

    for i in Base.OneTo(nspecies)
        lines!(height_strength_exps, ymat[i, :];
            linewidth = 3,
            color = height[i],
            colorrange = colorrange,
            colormap = colormap)
    end

    lines!(height_strength_exps, ones(length(height_strength_exps));
        linewidth = 2,
        linestyle = :dash,
        color = :red)
    # vlines!(orig_β_height)
    Colorbar(fig[1, 2]; colormap, colorrange, label = "Plant height [m]")

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
