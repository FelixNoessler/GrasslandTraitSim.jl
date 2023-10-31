function get_validation_data_plots(; plotIDs, startyear)
    valid_data = Dict()

    for plotID in plotIDs
        valid_data[plotID] = get_validation_data(; plotID, startyear)
    end

    return valid_data
end

function get_validation_data(; plotID, startyear)
    measuredbiomass_sub = @subset data.valid.measuredbiomass :plotID .==
                                                             plotID.&&
    Dates.year.(:date) .<= 2021
    measured_biomass = TimeArray((;
            biomass = measuredbiomass_sub.biomass,
            numeric_date = to_numeric.(measuredbiomass_sub.date),
            date = measuredbiomass_sub.date),
        timestamp = :date)

    ##############
    ##############
    ### soil moisture
    soilmoisture_sub = @subset data.valid.soilmoisture :plotID .==
                                                       plotID.&&Dates.year.(:date) .<= 2021
    soilmoisture = (;
        val = soilmoisture_sub.soilmoisture,
        t = Dates.value.(soilmoisture_sub.date .- Dates.Date(startyear)) .+ 1,
        num_t = to_numeric.(soilmoisture_sub.date))

    ##############
    ##############
    ### traits
    f = plotID .== data.valid.traits.plotID
    traits = (;
        cwm = data.valid.traits.cwm[f, :],
        cwv = data.valid.traits.cwv[f, :],
        t = Dates.value.(data.valid.traits.t[f] .- Dates.Date(startyear)) .+ 1,
        num_t = data.valid.traits.num_t[f],
        dim = data.valid.traits.dim)

    return (;
        soilmoisture,
        traits,
        measured_biomass)
end
