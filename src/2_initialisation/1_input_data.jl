function load_input(path; included = (;), likelihood_included = (;), plotIDs = nothing)
    inputs = load(path)

    for k in keys(inputs)
        @reset inputs[k].simp.included = create_included(included)
        @reset inputs[k].simp.likelihood_included = likelihood_included
    end

    if isnothing(plotIDs)
        plotIDs = keys(inputs)
    end

    inputs = NamedTuple((Symbol(k) => inputs[k] for k in plotIDs))

    return inputs
end

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
        time_step_days = 1,
        nutheterog = 0.0,
        patch_xdim = 1,
        patch_ydim = 1,
        biomass_stats = nothing,
        included = (;),
        likelihood_included = (; biomass = true, trait = true, height = true, fdis = true),
        trait_seed = missing)


    included = create_included(included)

    time_step_days = Dates.Day(time_step_days)
    start_date = Dates.Date(2006, 1, 1)
    end_date = Dates.Date(2021, 12, 31)
    yearrange = Ref(2006:2021)
    date_range_all_days = start_date:end_date
    date_range = start_date:time_step_days:end_date
    ntimesteps = length(date_range) - 1

    ###### daily data
    clim_init = @chain data.input.dwd_clim begin
        @subset first.(:explo) .== first(plotID)
        @select(:date, :temperature, :precipitation)
    end

    clim_sub = @chain data.input.clim begin
        @subset :plotID .== plotID .&& :year .∈ yearrange
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
            :PET_sum = :PET .* u"mm"
            :PAR = :PAR .* u"MJ / ha"
            :PAR_sum = :PAR .* u"MJ / ha"
            :CUT_mowing = prepare_mowing(mow_sub) ./ 100 .* u"m"
            :LD_grazing = prepare_grazing(graz_sub) ./ u"ha"
            :doy = Dates.dayofyear.(:date)
        end
        @orderby :date
    end

    daily_input_df = @select(daily_data_prep,
        :date,
        :temperature,
        :temperature_sum,
        :precipitation, :PET, :PET_sum,
        :PAR, :PAR_sum,
        :CUT_mowing, :LD_grazing)

    ## convert to dimension of the time step
    input = nothing

    if isone(time_step_days.value)
        daily_input_df_sub = @chain daily_input_df begin
            @subset :date .< end_date
            @select Not(:date)
        end
        input = (; zip(Symbol.(names(daily_input_df_sub)), eachcol(daily_input_df_sub))...)
    else
        temperature = Array{eltype(daily_input_df.temperature)}(undef, ntimesteps)
        temperature_sum = Array{eltype(daily_input_df.temperature_sum)}(undef, ntimesteps)
        precipitation = Array{eltype(daily_input_df.precipitation)}(undef, ntimesteps)
        PET = Array{eltype(daily_input_df.PET)}(undef, ntimesteps)
        PET_sum = Array{eltype(daily_input_df.PET)}(undef, ntimesteps)
        par_type = eltype(float(daily_input_df.PAR[1]))
        PAR = Array{par_type}(undef, ntimesteps)
        PAR_sum = Array{par_type}(undef, ntimesteps)
        CUT_mowing = Array{eltype(daily_input_df.CUT_mowing)}(undef, ntimesteps)
        LD_grazing = Array{eltype(daily_input_df.LD_grazing)}(undef, ntimesteps)

        old_T_kelvin = uconvert.(u"K", daily_input_df.temperature)

        for i in Base.OneTo(ntimesteps)
            sub_date = date_range[i]:(date_range[i+1] - Dates.Day(1))
            f = date_range_all_days .∈ Ref(sub_date)

            temperature[i] = uconvert(u"°C", mean(old_T_kelvin[f]))
            temperature_sum[i] = mean(daily_input_df.temperature_sum[f])
            precipitation[i] = sum(daily_input_df.precipitation[f])
            PET[i] = mean(daily_input_df.PET[f])
            PET_sum[i] = sum(daily_input_df.PET[f])
            PAR[i] = mean(daily_input_df.PAR[f])
            PAR_sum[i] = sum(daily_input_df.PAR[f])

            new_mowing_prep = daily_input_df.CUT_mowing[f]
            if all(isnan.(new_mowing_prep))
                CUT_mowing[i] = NaN * u"m"
            else
                mow_index = findfirst(.!isnan.(new_mowing_prep))
                CUT_mowing[i] = new_mowing_prep[mow_index]
            end

            new_grazing_prep = daily_input_df.LD_grazing[f]
            if all(isnan.(new_grazing_prep))
                LD_grazing[i] = NaN / u"ha"
            else
                LD_grazing[i] = sum(new_grazing_prep[.!isnan.(new_grazing_prep)])
            end
        end

        input = (; temperature, temperature_sum, precipitation, PET, PET_sum,
                 PAR, PAR_sum, CUT_mowing, LD_grazing)
    end

    ### ----------------- initial biomass and soilwater content
    initbiomass = 5000.0u"kg / ha"
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
    cutting_height = unique_calc.cutting_height
    biomass_cutting_date = unique_calc.date
    biomass_cutting_numeric_date = to_numeric.(biomass_cutting_date)

    biomass_cutting_t = unique_calc.biomass_cutting_day
    if isone(time_step_days.value)
        biomass_cutting_t = unique_calc.biomass_cutting_day
    else
        biomass_cutting_t = Array{Int64}(undef, length(biomass_cutting_date))
        for i in eachindex(biomass_cutting_date)
            biomass_cutting_t[i] = findfirst(date_range .> biomass_cutting_date[i]) - 2
        end
    end

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
        simp = (;
            output_date = date_range,
            output_date_num = to_numeric.(date_range),
            mean_input_date = date_range[1:end-1] .+ .+ time_step_days ÷ 2,
            mean_input_date_num = to_numeric.(date_range[1:end-1] .+ time_step_days ÷ 2),
            ts = Base.OneTo(ntimesteps),
            ntimesteps = ntimesteps,
            nspecies,
            time_step_days,
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
            input)
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
                if grazing_enddate > days[end]
                    grazing_enddate = days[end]
                end

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
        srsa = trait_df.srsa * u"m^2/g",
        abp = trait_df.abp,
        lbp = trait_df.lbp,
        lnc = trait_df.lnc * u"mg/g");
end


function create_included(included_prep = (;);)
    included = (;
        senescence = true,
        senescence_season = true,   # TODO
        senescence_sla = true,
        potential_growth = true,
        clonalgrowth = true,
        mowing = true,
        grazing = true,
        lowbiomass_avoidance = true,
        belowground_competition = true,
        community_self_shading = true,
        height_competition = true,
        sla_transpiration = true,
        sla_water_growth_reducer = true,
        rsa_water_growth_reducer = true,
        water_growth_reduction = true,
        nutrient_growth_reduction = true,
        root_invest = true,
        temperature_growth_reduction = true,
        seasonal_growth_adjustment = true,   # TODO
        radiation_growth_reduction = true)

    for k in keys(included_prep)
        @reset included[k] = included_prep[k]
    end

    return included
end
