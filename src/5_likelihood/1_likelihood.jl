include("2_gradient.jl")
include("3_prior.jl")
include("4_posterior.jl")

function loglikelihood_model(;
        p = nothing,
        input_obj = nothing,
        input_objs = nothing,
        prealloc = nothing,
        prealloc_specific = nothing,
        θ_type = Float64,
        plotID,
        pretty_print = false,
        return_seperate = false,
        valid_data = nothing,
        data = nothing,
        sol = nothing,
        trait_input = nothing)

    if isnothing(data)
        data = valid_data[Symbol(plotID)]
    end


    if isnothing(sol)
        if isnothing(input_obj)
            input_obj = input_objs[Symbol(plotID)]
        end
        sol = solve_prob(; input_obj, p, prealloc, prealloc_specific, trait_input,
                           θ_type)
    end

    #######################################################################
    #######################################################################
    ######################### Calculate likelihood

    #######################################################################
    ################# measured biomass
    #######################################################################
    ll_biomass = 0.0

    if sol.simp.likelihood_included.biomass
        @unpack cut_index, cut_biomass = sol.valid
        @unpack b_biomass = sol.p

        simulated_cutted_biomass = ustrip.(cut_biomass)[cut_index]
        biomass_d = Product(Normal.(simulated_cutted_biomass, b_biomass))

        ll_biomass = logpdf(biomass_d, vec(data.biomass))
    end

    ########################################################################
    ################## cwm trait likelihood
    ########################################################################
    ll_trait = 0.0
    if sol.simp.likelihood_included.trait
        @unpack npatches, patch_xdim, patch_ydim, nspecies = sol.simp
        @unpack biomass = sol.output

        data_trait_t = LookupArrays.index(data.traits, :time)
        species_biomass = dropdims(mean(@view sol.output.biomass[data_trait_t, :, :, :];
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
            cwmtrait_d = Product(Normal.(sim_cwm_trait, sol.p[cwm_traitscale]);)

            # if trait_symbol == :amc
            #     μ = sim_cwm_trait
            #     φ = 1 / sol.p.b_amc
            #     α = @. μ * φ
            #     β = @. (1.0 - μ) * φ
            #     if any(iszero.(α)) || any(iszero.(β))
            #         ll_trait += -Inf
            #         continue
            #     end
            #     cwmtrait_d = Product(Beta.(α, β))
            # end

            ll = logpdf(cwmtrait_d, measured_cwm)
            ll_trait += ll #-log(ntraits)
        end
    end


    ########################################################################
    ################## Community height
    ########################################################################
    ll_height = 0.0
    if sol.simp.likelihood_included.height
        height_t = LookupArrays.index(data.height, :time)
        measured_height = ustrip.(data.height)
        sim_height = ustrip.(sol.output.height[height_t])
        height_d = Product(Normal.(sim_height, sol.p[:b_simheight]);)
        ll_height = logpdf(height_d, measured_height)
    end

    ########################################################################
    ################## Functional dispersion
    ########################################################################
    ll_fdis = 0.0
    if sol.simp.likelihood_included.fdis
        fdis_t = data.fun_diversity.time
        measured_fdis = data.fun_diversity.fdis
        traits = (; height = sol.traits.height, sla = sol.traits.sla, lnc = sol.traits.lnc)
        biomass = dropdims(
            mean(ustrip.(sol.output.biomass); dims = (:x, :y)); dims =(:x, :y))[fdis_t, :]
        sim_fdis = functional_dispersion(traits, biomass; )
        fdis_d = Product(Normal.(sim_fdis, sol.p[:b_fdis]);)
        ll_fdis = logpdf(fdis_d, measured_fdis)
    end

    ########################################################################
    ################## total likelihood
    ########################################################################
    ll = ll_biomass + ll_trait + ll_height + ll_fdis

    ########################################################################
    ################## printing
    ########################################################################
    if pretty_print
        bl, tl, hl, fl = round(ll_biomass), round(ll_trait), round(ll_height), round(ll_fdis)
        println("biomass: $(bl) trait cwm: $tl, height: $hl, fdis: $fl")
    end

    if return_seperate
        return (biomass = ll_biomass, trait = ll_trait, height = ll_height, fdis = ll_fdis)
    end

    return ll
end
