function loglikelihood_model(sim::Module;
        inf_p,
        input_objs = nothing,
        valid_data = nothing,
        calc = nothing,
        plotID,
        pretty_print = false,
        return_seperate = false,
        include_traits = true,
        include_soilmoisture = true,
        data = nothing,
        sol = nothing)
    if isnothing(data)
        data = valid_data[plotID]
    end

    if isnothing(sol)
        input_obj = input_objs[plotID]
        sol = sim.solve_prob(; input_obj, inf_p, calc)
    end

    selected_patch = 1

    ########################################################################
    ########################################################################
    ########################## Calculate likelihood

    ########################################################################
    ################## measured biomass
    ########################################################################
    data_biomass_t = LookupArrays.index(data.biomass, :time)
    species_biomass = dropdims(mean(sol.o.biomass[data_biomass_t, :, :]; dims = 2);
        dims = 2)
    species_biomass = ustrip.(species_biomass)
    site_biomass = vec(sum(species_biomass; dims = 2))

    if any(isnan.(species_biomass))
        @warn "Biomass NaN, parameters:"
        display(plotID)
        @show sol.p
        return -Inf
    end

    ### calculate the likelihood
    biomass_d = Product(truncated.(Laplace.(site_biomass, sol.p.b_biomass); lower = 0.0))
    ll_biomass = logpdf(biomass_d, vec(data.biomass))

    ########################################################################
    ################## soil moisture
    ########################################################################
    ll_soilmoisture = 0
    if include_soilmoisture
        #### downweight the likelihood because there are many observations
        data_soilmoisture_t = LookupArrays.index(data.soilmoisture, :time)
        weight = length(data.soilmoisture) / 13

        sim_soilwater = dropdims(mean(sol.o.water[data_soilmoisture_t, :]; dims = 2);
            dims = 2)
        sim_soilwater = ustrip.(sim_soilwater)

        transformed_data = @. sol.site.rootdepth * (sol.p.moistureconv_alpha +
                               sol.p.moistureconv_beta * data.soilmoisture)

        soilmoisture_d = Product(truncated.(Laplace.(sim_soilwater, sol.p.b_soilmoisture);
            lower = 0.0))
        ll_soilmoisture += logpdf(soilmoisture_d, transformed_data) / weight
    end

    ########################################################################
    ################## cwm/cwv trait likelihood
    ########################################################################
    ll_trait = 0.0
    ll_trait_var = 0.0
    data_trait_t = LookupArrays.index(data.traits, :time)
    species_biomass = dropdims(mean(sol.o.biomass[data_trait_t, :, :]; dims = 2); dims = 2)
    species_biomass = ustrip.(species_biomass)
    site_biomass = vec(sum(species_biomass; dims = 2))

    if include_traits
        ## cannot calculate cwm trait for zero biomass
        if any(iszero.(site_biomass))
            if return_seperate
                return (;
                    biomass = ll_biomass,
                    trait = -Inf,
                    trait_var = -Inf,
                    soilmoisture = ll_soilmoisture)
            end

            return -Inf
        end

        relative_biomass = species_biomass ./ site_biomass
        ntraits = size(data.traits, :trait)

        trait_symbols = LookupArrays.index(data.traits, :trait)

        for trait_symbol in trait_symbols
            ### calculate CWM
            trait_vals = ustrip.(sol.traits[trait_symbol])
            weighted_trait = trait_vals .* relative_biomass'
            sim_cwm_trait = vec(sum(weighted_trait; dims = 1))

            ### calculate cwv
            trait_diff = (trait_vals' .- sim_cwm_trait) .^ 2
            weighted_trait_diff = trait_diff .* relative_biomass
            sim_cwv_trait = vec(sum(weighted_trait_diff; dims = 2))

            ### "measured" traits (calculated cwm from observed vegetation)
            measured_cwm = data.traits[trait = At(trait_symbol), type = At(:cwm)]
            measured_cwv = data.traits[trait = At(trait_symbol), type = At(:cwv)]

            ### CWM Likelihood
            cwm_traitscale = Symbol(:b_, trait_symbol)
            cwmtrait_d = Product(truncated.(Laplace.(sim_cwm_trait, sol.p[cwm_traitscale]);
                lower = 0.0))
            ll = logpdf(cwmtrait_d, measured_cwm)
            ll_trait += ll / ntraits

            ### CWV Likelihood
            cwv_traitscale = Symbol(:b_var_, trait_symbol)
            cwvtrait_d = Product(truncated.(Laplace.(sim_cwv_trait, sol.p[cwv_traitscale]);
                lower = 0.0))
            ll = logpdf(cwvtrait_d, measured_cwv)
            ll_trait_var += ll / ntraits
        end
    end

    ########################################################################
    ################## total likelihood
    ########################################################################
    ll = ll_biomass + ll_trait + ll_trait_var + ll_soilmoisture
    # ll = ll_trait_var

    ########################################################################
    ################## printing
    ########################################################################
    if pretty_print
        bl, tl, tlv = round(ll_biomass), round(ll_trait), round(ll_trait_var)
        sl = round(ll_soilmoisture)
        @info "biomass: $(bl) trait cwm, cwv: $tl, $tlv moi: $(sl)" maxlog=1000
    end

    if return_seperate
        return (; biomass = ll_biomass, trait = ll_trait, trait_var = ll_trait_var,
            soilmoisture = ll_soilmoisture)
    end

    return ll
end
