function calc_cut_biomass!(; container)
    @unpack cutting_height, biomass_cutting_t, cut_biomass = container.valid
    @unpack species_mean_biomass, species_cut_biomass,
            proportion_mown, lowbiomass_correction = container.calc
    @unpack α_lowB, β_lowB = container.p
    @unpack biomass = container.output
    @unpack nspecies, included = container.simp
    @unpack height = container.traits

    for i in eachindex(biomass_cutting_t)
        t = biomass_cutting_t[i]
        for s in 1:nspecies
            vec_view = @view biomass[t, :, :, s]
            species_mean_biomass[s] = mean(vec_view)
        end

        # --------- proportion of plant height that is mown
        proportion_mown .= max.(height .- cutting_height[i] * u"m", 0.0u"m") ./ height

        # --------- if low species biomass, the plant height is low -> less biomass is mown
        if !haskey(included, :lowbiomass_avoidance) || included.lowbiomass_avoidance
            @. lowbiomass_correction =  1.0 / (1.0 + exp(β_lowB * (α_lowB - species_mean_biomass)))
        else
            lowbiomass_correction .= 1.0
        end

        species_cut_biomass .= lowbiomass_correction .* proportion_mown .* species_mean_biomass
        cut_biomass[i] = sum(species_cut_biomass)
    end
end
