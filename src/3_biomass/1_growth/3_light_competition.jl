"""
Calculate the distribution of potential growth to each species based on share of the leaf
area index and the height of each species.
"""
function light_competition!(; container, above_biomass, actual_height)
    @unpack lais_heightinfluence, LIG, LAIs = container.calc
    @unpack LAItot = container.calc.com
    @unpack included, variations = container.simp

    if iszero(LAItot)
        @. LIG = 0.0
        return nothing
    end

    if !included.height_competition
        @info "Height influence turned off!" maxlog=1
        @. LIG = LAIs / LAItot
        return nothing
    end

    ### there are two methods for simulating light competition:
    if variations.use_height_layers
        light_competition_height_layer!(; container, actual_height)
    else
        light_competition_simple!(; container, above_biomass, actual_height)
    end

    return nothing
end


function light_competition_simple!(; container, above_biomass, actual_height)
    @unpack lais_heightinfluence, LIG, LAIs,
            relative_height = container.calc
    @unpack LAItot = container.calc.com
    @unpack included = container.simp
    @unpack β_LIG_H = container.p

    total_above_biomass = sum(above_biomass)
    relative_height .= actual_height .* above_biomass ./ total_above_biomass
    height_cwm = sum(relative_height)

    @. lais_heightinfluence = LAIs .* (actual_height / height_cwm) ^ β_LIG_H
    LIG .= lais_heightinfluence ./ sum(lais_heightinfluence)

    return nothing
end

function light_competition_height_layer!(; container, actual_height)
    @unpack LAIs, LIG, min_height_layer, max_height_layer,
            LAIs_layer, LAItot_layer, cumLAItot_above,
            Intensity_layer, fPAR_layer = container.calc
    @unpack LAItot = container.calc.com
    @unpack included, nspecies = container.simp
    @unpack γ_RUE_k = container.p

    nlayers = length(LAItot_layer)

    ## calculate the LAI of each species in each layer
    LAIs_layer .= 0.0
    for s in 1:nspecies
        for l in 1:nlayers
            if min_height_layer[l] < actual_height[s] <= max_height_layer[l]
                proportion_upper_layer = (actual_height[s] - min_height_layer[l]) / actual_height[s]
                nlowerlayer = l - 1
                proportion_lower_layer = (1 - proportion_upper_layer) / nlowerlayer
                LAIs_layer[s, l] = proportion_upper_layer * LAIs[s]
                for n in 1:nlowerlayer
                    LAIs_layer[s, n] = proportion_lower_layer * LAIs[s]
                end
            end
        end
    end

    ## calculate the total LAI in each layer
    LAItot_layer .= 0.0
    for s in 1:nspecies
        for l in 1:nlayers
            LAItot_layer[l] += LAIs_layer[s, l]
        end
    end

    ## calculate the total LAI of all layers above the layer
    cumLAItot_above .= 0.0
    for l in 1:nlayers
        for n in 1:nlayers
            if n > l
                cumLAItot_above[l] += LAItot_layer[n]
            end
        end
    end

    ## calculate the fraction of the light that reaches each layer
    for l in 1:nlayers
        Intensity_layer[l] = exp(-γ_RUE_k * cumLAItot_above[l])
    end

    ## calculate for each species in each layer the fraction of light intercepted
    fPAR_layer .= 0.0
    for l in 1:nlayers
        if ! iszero(LAItot_layer[l])
            fPAR = Intensity_layer[l] * (1 - exp(-γ_RUE_k * LAItot_layer[l]))
            for s in 1:nspecies
                fPAR_layer[s, l] = LAIs_layer[s, l] / LAItot_layer[l] * fPAR
            end
        end
    end

    ## calculate the sum of light intercepted for each species
    LIG .= 0.0
    for s in 1:nspecies
        for l in 1:nlayers
            LIG[s] += fPAR_layer[s, l]
        end
    end

    ## divide by community LIE to get the proportion of each species
    comLIE = (1 - exp(-γ_RUE_k * LAItot))
    for s in 1:nspecies
        LIG[s] /= comLIE
    end

    return nothing
end

function plot_height_influence(; θ = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; θ)

    height_strength_exps = LinRange(0.0, 1.5, 40)
    above_biomass = fill(50, nspecies)u"kg / ha"
    ymat = Array{Float64}(undef, nspecies, length(height_strength_exps))
    orig_β_LIG_H = container.p.β_LIG_H

    ### otherwise the function won't be calculated
    ### the LAI is not used in the hieght influence function
    container.calc.com.LAItot = 0.2 * nspecies

    for (i, β_LIG_H) in enumerate(height_strength_exps)
        @reset container.p.β_LIG_H = β_LIG_H
        LIG!(; container, above_biomass,
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
        xlabel = "Influence strength of the plant height (β_LIG_H)",
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
    # vlines!(orig_β_LIG_H)
    Colorbar(fig[1, 2]; colormap, colorrange, label = "Plant height [m]")

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
