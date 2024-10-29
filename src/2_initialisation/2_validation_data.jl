function get_validation_data_plots(; plotIDs, kwargs...)
    valid_data = Dict()
    for plotID in plotIDs
        valid_data[Symbol(plotID)] = get_validation_data(; plotID, kwargs...)
    end

    return NamedTuple(valid_data)
end

function get_validation_data(; plotID, biomass_stats = nothing, mean_input_date = nothing)
    # ---------------------------- biomass
    biomass_sub = @subset data.valid.measuredbiomass :plotID .== plotID .&&
        Dates.year.(:date) .<= 2021

    if !isnothing(biomass_stats)
        biomass_sub = @subset biomass_sub :stat .∈ Ref(biomass_stats)
    end

    biomass = DimArray(biomass_sub.biomass,
        (; time = date_to_solt(biomass_sub.date; mean_input_date)))
    biomass_type = biomass_sub.stat

    # ---------------------------- traits
    f = plotID .== data.valid.traits.plotID
    cwm = data.valid.traits.cwm[f, :]

    traits = DimArray(cwm,
            (time = date_to_solt(data.valid.traits.t[f]; mean_input_date),
            trait = data.valid.traits.dim))

    # ---------------------------- functional dispersion
    f = plotID .== data.valid.fun_diversity.plotID
    fun_diversity = (; fdis = data.valid.fun_diversity.fdis[f],
                        num_t = data.valid.fun_diversity.num_t[f],
                        date = data.valid.fun_diversity.t[f],
                        time = date_to_solt(data.valid.fun_diversity.t[f]; mean_input_date))


    # ---------------------------- measured height
    height_sub = @subset data.valid.measuredheight :plotID .== plotID .&&
        Dates.year.(:date) .<= 2021
    height = DimArray(height_sub.height,
        (; time = date_to_solt(height_sub.date; mean_input_date)))


    return (; traits, biomass, biomass_type, height, fun_diversity)
end

function date_to_solt(calibration_dates; mean_input_date)
    if isnothing(mean_input_date)
        return Dates.value.(calibration_dates .- Dates.Date(2006)) .+ 1
    end

    output_index = Array{Int64}(undef, length(calibration_dates))
    for i in eachindex(calibration_dates)
        output_index[i] = findfirst(mean_input_date .>= calibration_dates[i]) + 1
    end
    return output_index
end
