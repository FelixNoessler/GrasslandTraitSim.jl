function calc_cut_biomass!(; container)
    @unpack cutting_height, biomass_cutting_t, cut_biomass = container.valid
    @unpack species_mean_biomass, species_mean_height, species_cut_biomass,
            proportion_mown, actual_height = container.calc
    @unpack output = container
    @unpack nspecies = container.simp
    @unpack height, abp = container.traits

    for i in eachindex(biomass_cutting_t)
        t = biomass_cutting_t[i]
        for s in 1:nspecies
            vec_view = @view output.biomass[t, :, :, s]
            species_mean_biomass[s] = mean(vec_view)

            vec_height_view = @view output.height[t, :, :, s]
            species_mean_height[s] = mean(vec_height_view)
        end

        actual_height!(; container, biomass = species_mean_biomass,
                       state_height = species_mean_height)
        @unpack actual_height, above_biomass = container.calc

        # --------- proportion of plant height that is mown
        proportion_mown .= max.(actual_height .- cutting_height[i] * u"m", 0.0u"m") ./
                           actual_height

        species_cut_biomass .= proportion_mown .* above_biomass
        cut_biomass[i] = sum(species_cut_biomass)
    end
end
