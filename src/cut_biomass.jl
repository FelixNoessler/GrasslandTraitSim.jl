function calc_cut_biomass!(; container)
    @unpack cutting_height, biomass_cutting_t = container.calc
    @unpack biomass = container.output
    @unpack mean_biomass = container.calc
    @unpack nspecies = container.simp

    for i in eachindex(biomass_cutting_t)
        t = biomass_cutting_t[i]
        for s in 1:nspecies
            vec_view = @view biomass[t, :, :, s]
            mean_biomass[s] = mean(vec_view)
        end

        cut_biomass!(; t, ch = cutting_height[i], container, biomass = mean_biomass,
                     cut_index = i)
    end
end

function cut_biomass!(; cut_index, t, ch, container, biomass)
    @unpack cutting_height, biomass_cutting_t = container.calc
    @unpack cut_biomass = container
    @unpack height = container.traits
    @unpack species_cut_biomass = container.calc
    @unpack proportion_mown = container.calc
    @unpack included = container.simp
    @unpack mowing = container.daily_input

    days_since_last_mowing = 200
    mowing_mid_days = 0.0
    mowfactor_β = 0.0

    ## if mowing is not included, cutted biomass shouldn't raise an error
    if included.mowing
        @unpack mowing_mid_days, mowfactor_β = container.p

        tstart = t - 200 < 1 ? 1 : t - 200
        mowing_last200 = @view mowing[t-1:-1:tstart]

        for i in eachindex(mowing_last200)
            if i == 1
                continue
            end

            if !isnan(mowing_last200[i]) && !iszero(mowing_last200[i])
                days_since_last_mowing = i
                break
            end
        end
    end

    # --------- proportion of plant height that is mown
    proportion_mown .= max.(height .- ch * u"m", 0.0u"m") ./ height

    # --------- if meadow is too often mown, less biomass is removed
    ## the 'mowing_mid_days' is the day where the plants are grown
    ## back to their normal size/2
    mow_factor = 1.0 / (1.0 + exp(-mowfactor_β * (days_since_last_mowing - mowing_mid_days)))

    species_cut_biomass .= mow_factor .* proportion_mown .* biomass
    cut_biomass_sum = sum(species_cut_biomass)

    cut_biomass[cut_index] = cut_biomass_sum

    return nothing
end
