function loglikelihood_model(sim::Module;
        p = nothing,
        input_objs = nothing,
        valid_data = nothing,
        prealloc = nothing,
        prealloc_specific = nothing,
        plotID,
        pretty_print = false,
        return_seperate = false,
        data = nothing,
        sol = nothing,
        trait_input = nothing)

    if isnothing(data)
        data = valid_data[Symbol(plotID)]
    end


    if isnothing(sol)
        input_obj = input_objs[Symbol(plotID)]
        sol = sim.solve_prob(; input_obj, p, prealloc, prealloc_specific, trait_input)
    end

    #######################################################################
    #######################################################################
    ######################### Calculate likelihood

    #######################################################################
    ################# measured biomass
    #######################################################################
    ll_biomass = 0.0

    if sol.simp.likelihood_included.biomass
        @unpack cut_biomass, cut_index = sol.output_validation
        @unpack simulated_cutted_biomass = sol.likelihood_calc

        # n = length(cut_index)

        # for i in 1:n

        # end

        simulated_cutted_biomass .= ustrip.(cut_biomass)[cut_index]
        ### calculate the likelihood
        biomass_d = Product(Normal.(simulated_cutted_biomass,
                                sol.p.b_biomass);)
        ll_biomass = logpdf(biomass_d, vec(data.biomass))
    end


    ########################################################################
    ################## cwm trait likelihood
    ########################################################################
    ll_trait = 0.0
    if sol.simp.likelihood_included.trait
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
                    trait = -Inf)
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
            cwmtrait_d = Product(Laplace.(sim_cwm_trait, sol.p[cwm_traitscale]);)

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
            ll_trait += ll -log(ntraits)
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
