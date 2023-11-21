function loglikelihood_model(sim::Module;
        inf_p,
        input_objs = nothing,
        valid_data = nothing,
        calc = nothing,
        plotID,
        pretty_print = false,
        return_seperate = false,
        use_likelihood_biomass = true,
        use_likelihood_traits = true,
        use_likelihood_soilwater = true,
        data = nothing,
        sol = nothing)

    if isnothing(data)
        data = valid_data[plotID]
    end

    if isnothing(sol)
        input_obj = input_objs[plotID]
        sol = sim.solve_prob(; input_obj, inf_p, calc)
    end

    ########################################################################
    ########################################################################
    ########################## Calculate likelihood

    ########################################################################
    ################## measured biomass
    ########################################################################
    ll_biomass = 0.0

    if use_likelihood_biomass
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
    end

    ########################################################################
    ################## soil moisture
    ########################################################################
    ll_soilmoisture = 0
    if use_likelihood_soilwater
        #### downweight the likelihood because there are many observations
        data_soilmoisture_t = LookupArrays.index(data.soilmoisture, :time)
        weight = length(data.soilmoisture) / 13

        sim_soilwater = dropdims(mean(sol.o.water[data_soilmoisture_t, :]; dims = 2);
                                 dims = 2)
        sim_soilwater = min.(sim_soilwater ./ mean(sol.patch.WHC), 1.0)

        x = @. sol.p.moistureconv_alpha + sol.p.moistureconv_beta * sim_soilwater
        μ = @. exp(x)/(1+exp(x))
        φ = sol.p.b_soilmoisture
        α = @. μ * φ
        β = @. (1.0 - μ) * φ

        if any(iszero.(α)) || any(iszero.(β))
            ll_soilmoisture += -Inf
        else
            soilmoisture_d = Product(Beta.(α, β))
            ll_soilmoisture += logpdf(soilmoisture_d, vec(data.soilmoisture)) / weight
        end
    end

    ########################################################################
    ################## cwm/cwv trait likelihood
    ########################################################################
    ll_trait = 0.0
    data_trait_t = LookupArrays.index(data.traits, :time)
    species_biomass = dropdims(mean(sol.o.biomass[data_trait_t, :, :]; dims = 2); dims = 2)
    species_biomass = ustrip.(species_biomass)
    site_biomass = vec(sum(species_biomass; dims = 2))

    if use_likelihood_traits
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

            ### "measured" traits (calculated cwm from observed vegetation)
            measured_cwm = data.traits[trait = At(trait_symbol), type = At(:cwm)]

            ### CWM Likelihood
            cwm_traitscale = Symbol(:b_, trait_symbol)
            cwmtrait_d = Product(truncated.(Laplace.(sim_cwm_trait, sol.p[cwm_traitscale]);
                lower = 0.0))
            ll = logpdf(cwmtrait_d, measured_cwm)
            ll_trait += ll / ntraits
        end
    end

    ########################################################################
    ################## total likelihood
    ########################################################################
    ll = ll_biomass + ll_trait + ll_soilmoisture

    ########################################################################
    ################## printing
    ########################################################################
    if pretty_print
        bl, tl = round(ll_biomass), round(ll_trait)
        sl = round(ll_soilmoisture)
        @info "biomass: $(bl) trait cwm: $tl moi: $(sl)" maxlog=1000
    end

    if return_seperate
        return (biomass = ll_biomass, trait = ll_trait,
                soilmoisture = ll_soilmoisture)
    end

    return ll
end
