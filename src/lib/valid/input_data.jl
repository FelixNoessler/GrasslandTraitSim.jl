function validation_input_plots(; plotIDs, kwargs...)
    static_inputs = Dict()

    for plotID in plotIDs
        static_inputs[Symbol(plotID)] = validation_input(; plotID, kwargs...)
    end

    return NamedTuple(static_inputs)
end

function validation_input(;
        plotID,
        nspecies,
        nutheterog = 0.0,
        patch_xdim = 1,
        patch_ydim = 1,
        biomass_stats = nothing,
        included = (;
            senescence = true,
            senescence_season = true,
            potential_growth = true,
            clonalgrowth = true,
            mowing = true,
            trampling = true,
            grazing = true,
            lowbiomass_avoidance = true,
            belowground_competition = true,
            community_height_red = true,
            height_competition = true,
            pet_growth_reduction = true,
            sla_transpiration = true,
            water_growth_reduction = true,
            nutrient_growth_reduction = true,
            temperature_growth_reduction = true,
            season_red = true,
            radiation_red = true),
        likelihood_included = (; biomass = true, trait = true),
        trait_seed = missing)

    start_date = Dates.Date(2006, 1, 1)
    end_date = Dates.Date(2021, 12, 31)
    yearrange = Ref(2006:2021)

    ###### daily data
    clim_init = @chain data.input.dwd_clim begin
        @subset first.(:explo) .== first(plotID)
        @select(:date, :temperature, :precipitation)
    end

    clim_sub = @chain data.input.clim begin
        @subset :plotID .== plotID .&&:year .∈ yearrange
        @select(:date, :temperature, :precipitation)
    end

    pet_sub = @subset data.input.pet first.(:explo) .== first(plotID) .&& :year .∈ yearrange
    par_sub = @subset data.input.par first.(:explo) .== first(plotID) .&& :year .∈ yearrange
    mow_sub = @subset data.input.mow :plotID .== plotID .&& :year .∈ yearrange
    graz_sub = @subset data.input.graz :plotID .== plotID .&& :year .∈ yearrange

    daily_data_prep = @chain vcat(clim_init, clim_sub)  begin
        innerjoin(_, pet_sub, on = :date, makeunique = true)
        innerjoin(_, par_sub, on = :date, makeunique = true)
        @transform begin
            :temperature = :temperature .* u"°C"
            :temperature_sum = cumulative_temperature(:temperature .* u"°C", Dates.year.(:date))
            :precipitation = :precipitation .* u"mm"
            :PET = :PET .* u"mm"
            :PAR = :PAR .* 10000 .* u"MJ / ha"
            :CUT_mowing = prepare_mowing(mow_sub) ./ 100 .* u"m"
            :LD_grazing = prepare_grazing(graz_sub) ./ u"ha"
            :doy = Dates.dayofyear.(:date)
        end
        @orderby :date
    end

    daily_input_df = @select(daily_data_prep,
        :temperature,
        :temperature_sum,
        :precipitation, :PET,
        :PAR,
        :CUT_mowing, :LD_grazing)
    daily_input = (; zip(Symbol.(names(daily_input_df)), eachcol(daily_input_df))...)

    ### ----------------- initial biomass and soilwater content
    initbiomass = 1500u"kg / ha"
    initsoilwater = 180.0u"mm"

    ### ----------------- dates when biomass was cut (for creating output for validation)
    df_cutting_day = @chain data.valid.measuredbiomass begin
        @subset :plotID .== plotID
        @subset :date .<= end_date
        @transform :biomass_cutting_day = Dates.value.(:date - start_date)
        @select :date :biomass_cutting_day :cutting_height :stat
    end

    if !isnothing(biomass_stats)
        df_cutting_day = @subset df_cutting_day :stat .∈ Ref(biomass_stats)
    end

    ##### what to calculate
    unique_calc = unique(df_cutting_day, [:date, :cutting_height])
    biomass_cutting_t = unique_calc.biomass_cutting_day
    cutting_height = unique_calc.cutting_height
    biomass_cutting_date = unique_calc.date
    biomass_cutting_numeric_date = to_numeric.(biomass_cutting_date)

    ###### how to index to get final result
    cutting_t_prep = df_cutting_day.biomass_cutting_day
    cutting_height_prep = df_cutting_day.cutting_height
    biomass_cutting_index = Int64[]
    current_index = 0
    for i in eachindex(cutting_t_prep)
        if i == 1
            current_index += 1
            push!(biomass_cutting_index, current_index)
            continue
        end

        if cutting_t_prep[i] != cutting_t_prep[i-1] ||
            cutting_height_prep[i] != cutting_height_prep[i-1]
            current_index += 1
        end

        push!(biomass_cutting_index, current_index)
    end

    ### ----------------- abiotic
    nut_sub = @subset data.input.nut :plotID .== plotID
    totalN = nut_sub.totalN[1] * u"g / kg"

    soil_sub = @subset data.input.soil :plotID .== plotID
    clay = soil_sub.clay[1] / 100
    silt = soil_sub.silt[1] / 100
    sand = soil_sub.sand[1] / 100
    organic = soil_sub.organic[1] / 100
    bulk = soil_sub.bulk[1] * u"g / cm^3"
    rootdepth = soil_sub.rootdepth[1] * u"mm"

    return (
        doy = daily_data_prep.doy,
        date = daily_data_prep.date[1]:daily_data_prep.date[end],
        numeric_date = to_numeric.(daily_data_prep.date),
        ts = Base.OneTo(nrow(daily_data_prep)),
        simp = (;
            nspecies,
            ntimesteps = nrow(daily_data_prep),
            plotID,
            npatches = patch_xdim * patch_ydim,
            patch_xdim,
            patch_ydim,
            nutheterog,
            trait_seed,
            included,
            likelihood_included),
        site = (;
            initbiomass,
            initsoilwater,
            totalN,
            clay,
            silt,
            sand,
            organic,
            bulk,
            rootdepth),
        output_validation = (;
            biomass_cutting_index,
            biomass_cutting_t,
            biomass_cutting_date,
            biomass_cutting_numeric_date,
            cutting_height),
        daily_input)
end

function to_numeric(d)
    daysinyear = Dates.daysinyear(Dates.year(d))
    return Dates.year(d) + (Dates.dayofyear(d) - 1) / daysinyear
end

# function yearly_temp_cumsum(data, date)
#     all_years = Dates.year.(date)
#     unqiue_years = unique(all_years)
#     yearly_cumsum = Float64[]
#     temperature_filter = data .> 0

#     for y in unqiue_years
#         f = all_years .== y
#         append!(yearly_cumsum, cumsum(data[f .&& temperature_filter]))
#     end

#     return yearly_cumsum
# end

function cumulative_temperature(temperature, year)
    temperature_diff = temperature .- 0.0u"°C"
    temperature_sum = eltype(temperature_diff)[]
    temperature_diff[temperature_diff .< 0u"K"] .= 0u"K"

    for y in unique(year)
        year_filter = y .== year
        append!(temperature_sum, cumsum(temperature_diff[year_filter]))
    end

    return temperature_sum
end


function prepare_mowing(d::DataFrame)
    startyear = minimum(d.year)
    endyear = maximum(d.year)

    days = Dates.Date(startyear):Dates.lastdayofyear(Dates.Date(endyear))
    t = TimeArray((date = days,
            index = 1:length(days)),
        timestamp = :date)

    cutheights = d.CutHeight_cm1[.!ismissing.(d.CutHeight_cm1)]
    mean_cutheight = 7.0
    if !isempty(cutheights)
        mean_cutheight = Statistics.mean(cutheights)
    end

    cutHeight_vec = Array{Float64}(undef, length(days))
    cutHeight_vec .= NaN

    for row in eachrow(d)
        y = row.year
        for i in 1:5
            if !ismissing.(row["MowingDay$i"])
                mowing_date = Dates.Date(y) + Dates.Day(row["MowingDay$i"])
                cH = row["CutHeight_cm$i"]
                if ismissing(cH)
                    cH = mean_cutheight
                end

                index = values(t[mowing_date].index)[1]
                cutHeight_vec[index] = cH
            end
        end
    end

    return cutHeight_vec
end

function prepare_grazing(d::DataFrame)
    startyear = minimum(d.year)
    endyear = maximum(d.year)

    days = Dates.Date(startyear):Dates.lastdayofyear(Dates.Date(endyear))
    t = TimeArray((date = days,
            index = 1:length(days)),
        timestamp = :date)

    grazing_vec = Array{Float64}(undef, length(days))
    grazing_vec .= NaN

    for row in eachrow(d)
        y = row.year
        for i in 1:4
            if !ismissing.(row["start_graz$i"])
                grazing_startdate = row["start_graz$i"]
                grazing_enddate = row["end_graz$i"]
                grazing_intensity = row["inten_graz$i"]

                # if isnan(grazing_intensity)
                #     @warn "Grazing intensity NaN"
                #     @show grazing_startdate, grazing_enddate, d.plotID[1]
                # end
                start_index = values(t[grazing_startdate].index)[1]
                end_index = values(t[grazing_enddate].index)[1]
                grazing_vec[start_index:end_index] .= grazing_intensity
            end
        end
    end
    return grazing_vec
end


function input_traits()
    trait_df = data.input.traits;
    trait_input = (;
        amc = trait_df.amc,
        sla = trait_df.sla * u"m^2/g",
        height = trait_df.height * u"m",
        rsa_above = trait_df.rsa_above * u"m^2/g",
        ampm = trait_df.ampm,
        lmpm = trait_df.lmpm,
        lncm = trait_df.lncm * u"mg/g");
end
