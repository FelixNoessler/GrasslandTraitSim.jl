function loglikelihood_model(sim::Module;
        inf_p,
        input_objs = nothing,
        valid_data = nothing,
        calc = nothing,
        plotID,
        pretty_print = false,
        return_seperate = false,
        likelihood_included = (;
            biomass = true,
            trait = true),
        data = nothing,
        sol = nothing,
        trait_input = nothing)

    if isnothing(data)
        data = valid_data[plotID]
    end

    if isnothing(sol)
        input_obj = input_objs[plotID]
        sol = sim.solve_prob(; input_obj, inf_p, calc, trait_input)
    end

    p_names = [string(s) for s in keys(sol.p)]
    for p_name in p_names
        if startswith(p_name, "b_") && (sol.p[Symbol(p_name)] <= 0.0)
            @warn "variance parameter <= 0.0 ($p_name)"
            return -Inf
        end
    end

    ########################################################################
    ########################################################################
    ########################## Calculate likelihood

    ########################################################################
    ################## measured biomass
    ########################################################################
    ll_biomass = 0.0

    if likelihood_included.biomass
        simulated_cutted_biomass = vec(ustrip.(sol.output_validation.cutted_biomass))

        ### calculate the likelihood
        biomass_d = Product(
            truncated.(Laplace.(simulated_cutted_biomass,
                                sol.p.b_biomass);
                       lower = 0.0))

        # biomass_d = Product(Normal.(simulated_cutted_biomass, sol.p.b_biomass + 1e-10);)
        ll_biomass = logpdf(biomass_d, vec(data.biomass))
    end

    ########################################################################
    ################## soil moisture
    ########################################################################
    # ll_soilmoisture = 0
    # if likelihood_included.soilmoisture
    #     #### downweight the likelihood because there are many observations
    #     data_soilmoisture_t = LookupArrays.index(data.soilmoisture, :time)
    #     weight = length(data.soilmoisture) / 13

    #     sim_soilwater = dropdims(mean(sol.output.water[data_soilmoisture_t, :, :]; dims = (:x, :y));
    #                              dims = (:x, :y))

    #     μ = vec(sim_soilwater) ./ (sol.site.rootdepth * u"mm")
    #     φ = 1 / sol.p.b_soilmoisture
    #     α = @. μ * φ
    #     β = @. (1.0 - μ) * φ

    #     measured_soilmoisture = vec(data.soilmoisture)

    #     if any(iszero.(α)) || any(iszero.(β))
    #         ll_soilmoisture += -Inf
    #     else
    #         soilmoisture_d = Product(Beta.(α, β))
    #         ll_soilmoisture = logpdf(soilmoisture_d, vec(data.soilmoisture)) / weight
    #     end

    #     if any(measured_soilmoisture .<= 0.0) || any(measured_soilmoisture .>= 1.0)
    #         @info "soil moisture out of range"
    #     end
    # end

    ########################################################################
    ################## cwm trait likelihood
    ########################################################################
    ll_trait = 0.0
    if likelihood_included.trait
        data_trait_t = LookupArrays.index(data.traits, :time)
        species_biomass = dropdims(mean(sol.output.biomass[data_trait_t, :, :, :];
                                        dims = (:x, :y));
                                   dims = (:x, :y))
        species_biomass = ustrip.(species_biomass)
        site_biomass = vec(sum(species_biomass; dims = (:species)))

        ## cannot calculate cwm trait for zero biomass
        if any(iszero.(site_biomass)) || any(isnan.(site_biomass))
            if return_seperate
                return (;
                    biomass = ll_biomass,
                    trait = -Inf,
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
            measured_cwm = data.traits[trait = At(trait_symbol)]

            ### CWM Likelihood
            cwm_traitscale = Symbol(:b_, trait_symbol)
            cwmtrait_d = Product(truncated.(
                Laplace.(sim_cwm_trait, sol.p[cwm_traitscale]);
                lower = 0.0))

            if trait_symbol == :amc
                μ = sim_cwm_trait
                φ = 1 / sol.p.b_amc
                α = @. μ * φ
                β = @. (1.0 - μ) * φ

                if any(iszero.(α)) || any(iszero.(β))
                    ll_trait += -Inf
                    continue
                end

                cwmtrait_d = Product(Beta.(α, β))
            end

            ll = logpdf(cwmtrait_d, measured_cwm)
            ll_trait += ll / ntraits
        end
    end

    ########################################################################
    ################## total likelihood
    ########################################################################
    ll = ll_biomass + ll_trait

    ########################################################################
    ################## printing
    ########################################################################
    if pretty_print
        bl, tl = round(ll_biomass), round(ll_trait)
        @info "biomass: $(bl) trait cwm: $tl" maxlog=1000
    end

    if return_seperate
        return (biomass = ll_biomass, trait = ll_trait)
    end

    return ll
end
