function create_axes_paneD(layout)
    axes = Dict()
    axes[:functional_dispersion] = Axis(layout[1, 1]; alignmode = Inside(),
                                        ylabel = "Functional dispersion [-]",
                                        xlabel = "Time [year]")
    return axes
end

function update_plots_paneD(; kwargs...)
    functional_dispersion_plot(; kwargs...)
end

function functional_dispersion_plot(; plot_obj, sol, valid_data, kwargs...)
    ax = clear_plotobj_axes(plot_obj, :functional_dispersion)

    traits = (; rsa = sol.traits.rsa, amc = sol.traits.amc,
               abp = sol.traits.abp, sla = sol.traits.sla,
               maxheight = sol.traits.maxheight,  lnc = sol.traits.lnc)

    fdis = functional_dispersion(traits, sol.output.biomass; )
    lines!(ax, sol.simp.output_date_num, fdis; color = :red)


    return nothing
end

function traits_to_matrix(trait_data; std_traits = true)
    trait_names = keys(trait_data)
    ntraits = length(trait_names)
    nspecies = length(trait_data[trait_names[1]])
    m = Matrix{Float64}(undef, nspecies, ntraits)

    for i in eachindex(trait_names)

        if std_traits
            m[:, i] = trait_data[trait_names[i]] ./ mean(trait_data[trait_names[i]])
        else
            m[:, i] = ustrip.(trait_data[trait_names[i]])
        end
    end

    return m
end

function functional_dispersion(trait_data, biomass_data; kwargs...)
    # Laliberté & Legendre 2010, checked results with fundiversity R package

    ntimesteps = size(biomass_data, :time)
    nspecies = size(biomass_data, :species)
    ntraits = length(trait_data)
    fdis = Vector{Float64}(undef, ntimesteps)

    trait_m = traits_to_matrix(trait_data; kwargs...)

    for t in 1:ntimesteps
        relative_biomass = biomass_data[t, :] / sum(biomass_data[t, :])

        z_squarred = zeros(nspecies)
        for t in 1:ntraits
            weighted_trait = trait_m[:, t] .* relative_biomass
            cwm = sum(weighted_trait)
            z_squarred .+= (trait_m[:, t] .- cwm) .^ 2
        end

        z = sqrt.(z_squarred)
        fdis[t] = sum(z .* relative_biomass)
    end

    return fdis
end
