function predictive_check(; sol, valid_data)
    p = sol.p

    # ------------------------ biomass ------------------------
    date_filter = sol.date .∈ Ref(timestamp(valid_data.measured_biomass))
    t_biomass = sol.ts[date_filter]
    biomass_filtered = sol.o.biomass[t_biomass, :, :]
    meanbiomass_per_patch = mean(biomass_filtered; dims = 2)
    sim_biomass = ustrip.(vec(sum(meanbiomass_per_patch; dims = 3)))
    biomass_d = truncated.(Laplace.(sim_biomass, p.b_biomass); lower = 0.0)
    biomass = rand.(biomass_d)

    # ------------------------ soilwater ------------------------
    t_soilwater = valid_data.soilmoisture.t
    sim_water = ustrip.(vec(mean(sol.o.water[t_soilwater, :]; dims = 2)))
    soilwater_d = Laplace.(sim_water, p.b_soilmoisture)
    soilwater = rand.(soilwater_d)

    return (; t_biomass, t_soilwater, biomass, soilwater)
end
