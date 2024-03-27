function calc_cut_biomass!(; container)
    @unpack cutting_height, biomass_cutting_t = container.valid
    @unpack biomass = container.output
    @unpack mean_biomass = container.calc
    @unpack nspecies = container.simp

    for i in eachindex(biomass_cutting_t)
        t = biomass_cutting_t[i]
        for s in 1:nspecies
            vec_view = @view biomass[t, :, :, s]
            mean_biomass[s] = mean(vec_view)
        end

        cut_biomass!(; ch = cutting_height[i], container, biomass = mean_biomass,
                     cut_index = i)
    end
end

function cut_biomass!(; cut_index, ch, container, biomass)
    @unpack cutting_height, biomass_cutting_t, cut_biomass = container.valid
    @unpack height = container.traits
    @unpack species_cut_biomass = container.calc
    @unpack proportion_mown = container.calc
    @unpack included = container.simp
    @unpack mowing = container.daily_input


    # TODO: ignore low biomass correction?

    # --------- proportion of plant height that is mown
    proportion_mown .= max.(height .- ch * u"m", 0.0u"m") ./ height
    species_cut_biomass .= proportion_mown .* biomass
    cut_biomass_sum = sum(species_cut_biomass)
    cut_biomass[cut_index] = cut_biomass_sum

    return nothing
end
