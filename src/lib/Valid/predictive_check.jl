function predictive_check(; sol, valid_data)
    p = sol.p

    # ------------------------ biomass ------------------------
    date_filter = sol.date .∈ Ref(LookupArrays.index(valid_data.biomass, :time))
    t_biomass = sol.ts[date_filter]
    biomass_filtered = sol.output.biomass[time = At(t_biomass)]
    meanbiomass_per_patch = mean(biomass_filtered; dims = 2)
    sim_biomass = ustrip.(vec(sum(meanbiomass_per_patch; dims = 3)))
    biomass_d = truncated.(Laplace.(sim_biomass, p.b_biomass); lower = 0.0)
    biomass = rand.(biomass_d)

    return (; t_biomass, biomass)
end
