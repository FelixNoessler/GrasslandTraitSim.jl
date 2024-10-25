function calc_cut_biomass!(; container)
    @unpack cutting_height, biomass_cutting_t, cut_biomass = container.valid
    @unpack species_mean_above_biomass, species_mean_actual_height, species_cut_biomass,
            proportion_mown = container.calc
    @unpack output = container
    @unpack nspecies = container.simp

    for i in eachindex(biomass_cutting_t)
        t = biomass_cutting_t[i]
        for s in 1:nspecies
            vec_view = @view output.above_biomass[t, :, :, s]
            species_mean_above_biomass[s] = mean(vec_view)

            vec_height_view = @view output.height[t, :, :, s]
            species_mean_actual_height[s] = mean(vec_height_view)
        end

        # --------- proportion of plant height that is mown
        proportion_mown .= max.(species_mean_actual_height .- cutting_height[i] * u"m", 0.0u"m") ./
        (species_mean_actual_height .+ 0.0001u"m")

        species_cut_biomass .= proportion_mown .* species_mean_above_biomass
        cut_biomass[i] = sum(species_cut_biomass)
    end
end
