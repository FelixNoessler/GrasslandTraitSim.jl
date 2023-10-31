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

    ### do we need this line (from calling julia from R)?
    inf_p = (; inf_p...)
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
    simbiomass = TimeArray((;
            biomass = vec(sum(ustrip.(sol.o.biomass[:, selected_patch, :]); dims = 2)),
            date = sol.date), timestamp = :date)

    ## select the dates on which measured biomass values
    ## are available
    simbiomass_sub = simbiomass[timestamp(data.measured_biomass)]
    simbiomass_vals = values(simbiomass_sub.biomass)

    if any(isnan.(simbiomass_vals))
        @warn "Biomass NaN, parameters:"
        display(plotID)
        @show sol.p

        # display(sol.o.biomass)
        return -Inf
    end

    ### calculate the likelihood
    biomass_d = Product(truncated.(Laplace.(simbiomass_vals, sol.p.b_biomass); lower = 0.0))
    ll_biomass = logpdf(biomass_d, values(data.measured_biomass.biomass))

    ########################################################################
    ################## soil moisture
    ########################################################################
    ll_soilmoisture = 0
    if include_soilmoisture
        #### downweight the likelihood because there are many observations
        weight = length(data.soilmoisture.t) / 13
        sim_soilwater = ustrip.(sol.o.water[data.soilmoisture.t, selected_patch])
        transformed_data = @. sol.p.moistureconv_alpha +
                              sol.p.moistureconv_beta * data.soilmoisture.val *
                              sol.site.rootdepth

        soilmoisture_d = Product(Laplace.(sim_soilwater, sol.p.b_soilmoisture))
        ll_soilmoisture += logpdf(soilmoisture_d, transformed_data) / weight
    end

    ########################################################################
    ################## cwm/cwv trait likelihood
    ########################################################################
    ll_trait = 0.0
    ll_trait_var = 0.0

    if include_traits
        ########## prepare biomass for CWM calculation
        patch = 1
        biomass_vals = ustrip.(sol.o.biomass[data.traits.t, patch, :])
        total_biomass = sum(biomass_vals, dims = 2)

        ## cannot calculate cwm trait for zero biomass
        if any(iszero.(total_biomass))
            if return_seperate
                return (;
                    biomass = ll_biomass,
                    trait = -Inf,
                    trait_var = -Inf,
                    soilmoisture = ll_soilmoisture)
            end

            return -Inf
        end

        relative_biomass = biomass_vals ./ total_biomass
        ntraits = length(data.traits.dim)

        for trait_name in data.traits.dim
            ### calculate CWM
            trait_vals = ustrip.(sol.traits[trait_name])
            weighted_trait = trait_vals .* relative_biomass'
            sim_cwm_trait = vec(sum(weighted_trait; dims = 1))

            ### calculate cwv
            trait_diff = (trait_vals' .- sim_cwm_trait) .^ 2
            weighted_trait_diff = trait_diff .* relative_biomass
            sim_cwv_trait = vec(sum(weighted_trait_diff; dims = 2))

            ### "measured" traits (calculated cwm from observed vegetation)
            measured_cwm = vec(data.traits.cwm[:, trait_name .== data.traits.dim])
            measured_cwv = vec(data.traits.cwv[:, trait_name .== data.traits.dim])

            ### CWM Likelihood
            cwm_traitscale = Symbol(:b_, trait_name)
            cwmtrait_d = Product(Laplace.(sim_cwm_trait, sol.p[cwm_traitscale]))
            ll = logpdf(cwmtrait_d, measured_cwm)
            ll_trait += ll / ntraits

            ### CWV Likelihood
            cwv_traitscale = Symbol(:b_var_, trait_name)
            cwvtrait_d = Product(Laplace.(sim_cwv_trait, sol.p[cwv_traitscale]))
            ll = logpdf(cwvtrait_d, measured_cwv)
            ll_trait_var += ll / ntraits
        end
    end

    ########################################################################
    ################## total likelihood
    ########################################################################
    # ll = ll_biomass + ll_trait + ll_trait_var + ll_soilmoisture
    ll = ll_biomass + ll_trait + ll_soilmoisture

    ########################################################################
    ################## printing
    ########################################################################
    if pretty_print
        bl, tl, tlv = round(ll_biomass), round(ll_trait), round(ll_trait_var)
        sl, pl = round(ll_soilmoisture)
        @info "biomass: $(bl) trait cwm, cwv: $tl, $tlv moi: $(sl)" maxlog=1000
    end

    if return_seperate
        return (; biomass = ll_biomass, trait = ll_trait, trait_var = ll_trait_var,
            soilmoisture = ll_soilmoisture)
    end

    return ll
end
