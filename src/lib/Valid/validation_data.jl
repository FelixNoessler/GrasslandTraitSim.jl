function get_validation_data_plots(; plotIDs, biomass_stats = nothing)
    valid_data = Dict()

    for plotID in plotIDs
        valid_data[Symbol(plotID)] = get_validation_data(; plotID, biomass_stats)
    end

    return NamedTuple(valid_data)
end

function date_to_solt(d; )
    Dates.value(d - Dates.Date(2006)) + 1
end

function get_validation_data(; plotID, biomass_stats = nothing)
    # ---------------------------- biomass
    biomass_sub =
        @subset data.valid.measuredbiomass :plotID .== plotID.&&
            Dates.year.(:date) .<= 2021

    if !isnothing(biomass_stats)
        biomass_sub = @subset biomass_sub :stat .∈ Ref(biomass_stats)
    end

    biomass = DimArray(biomass_sub.biomass,
        (; time = date_to_solt.(biomass_sub.date; )))
    biomass_type = biomass_sub.stat

    # ---------------------------- soil moisture
    soilmoisture_sub = @subset data.valid.soilmoisture :plotID .==
                                                       plotID.&&
    Dates.year.(:date) .<= 2021

    soilmoisture = DimArray(soilmoisture_sub.soilmoisture,
        (; time = date_to_solt.(soilmoisture_sub.date;)))

    # ---------------------------- traits
    f = plotID .== data.valid.traits.plotID
    cwm = data.valid.traits.cwm[f, :]
    # cwv = data.valid.traits.cwv[f, :]
    # mat = Array{Float64, 3}(undef, 2, size(cwm)...)
    # mat[1, :, :] = cwm
    # mat[2, :, :] = cwv

    traits = DimArray(cwm,
            (time = date_to_solt.(data.valid.traits.t[f]; ),
            trait = data.valid.traits.dim))

    return (; soilmoisture, traits, biomass, biomass_type)
end
