function get_validation_data_plots(; plotIDs, startyear)
    valid_data = Dict()

    for plotID in plotIDs
        valid_data[plotID] = get_validation_data(; plotID, startyear)
    end

    return valid_data
end

function date_to_solt(d; startyear)
    Dates.value(d - Dates.Date(startyear)) + 1
end

function get_validation_data(; plotID, startyear)
    # ---------------------------- biomass
    biomass_sub = @subset data.valid.measuredbiomass :plotID .==
                                                     plotID.&&
    Dates.year.(:date) .<= 2021

    biomass = DimArray(biomass_sub.biomass,
        (; time = date_to_solt.(biomass_sub.date; startyear)))

    # ---------------------------- soil moisture
    soilmoisture_sub = @subset data.valid.soilmoisture :plotID .==
                                                       plotID.&&
    Dates.year.(:date) .<= 2021

    soilmoisture = DimArray(soilmoisture_sub.soilmoisture,
        (; time = date_to_solt.(soilmoisture_sub.date; startyear)))

    # ---------------------------- traits
    f = plotID .== data.valid.traits.plotID
    cwm = data.valid.traits.cwm[f, :]
    cwv = data.valid.traits.cwv[f, :]

    mat = Array{Float64, 3}(undef, 2, size(cwm)...)
    mat[1, :, :] = cwm
    mat[2, :, :] = cwv

    traits = DimArray(mat,
        (type = [:cwm, :cwv],
            time = date_to_solt.(data.valid.traits.t[f]; startyear),
            trait = data.valid.traits.dim))

    return (; soilmoisture, traits, biomass)
end
