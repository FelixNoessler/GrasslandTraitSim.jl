function load_traits(inputdata_path = joinpath(DEFAULT_ARTIFACTS_DIR, "Input_data"))
    global trait_data = CSV.read("$inputdata_path/Traits.csv", DataFrame)
    return nothing
end

function input_traits()
    ## unfortunately, this is slower:
    # nspecies = nrow(traits)
    # amcdim = DimArray(traits.amc, (; species = 1:nspecies), name = "amc")
    # sladim = DimArray(traits.sla * u"m^2/g", (; species = 1:nspecies), name = "sla")
    # maxheightdim = DimArray(traits.maxheight * u"m", (; species = 1:nspecies), name = "maxheight")
    # rsadim = DimArray(traits.rsa * u"m^2/g", (; species = 1:nspecies), name = "rsa")
    # abpdim = DimArray(traits.abp, (; species = 1:nspecies), name = "abp")
    # lbpdim = DimArray(traits.lbp, (; species = 1:nspecies), name = "lbp")
    # lncdim = DimArray(traits.lnc * u"mg/g", (; species = 1:nspecies), name = "lnc")
    # return DimStack(amcdim, sladim, maxheightdim, rsadim, abpdim, lbpdim, lncdim)

    return (;
        amc = trait_data.amc,
        sla = trait_data.sla * u"m^2/g",
        maxheight = trait_data.maxheight * u"m",
        rsa = trait_data.rsa * u"m^2/g",
        abp = trait_data.abp,
        lbp = trait_data.lbp,
        lnc = trait_data.lnc * u"mg/g");
end

function load_input_data(input_data_path = joinpath(DEFAULT_ARTIFACTS_DIR, "Input_data"))
    ########## Climate data
    clim = CSV.read(joinpath(input_data_path, "Climate.csv"), DataFrame)
    plotIDs = unique(clim.plotID)
    xs, ys = unique(clim.x), unique(clim.y)
    ts, years = unique(clim.t), unique(Dates.year.(clim.t))

    ########## Management data - join with all combinations of plotID, t, x, y
    man = allcombinations(DataFrame, plotID = plotIDs, t = ts, x = ys, y = ys)
    man = leftjoin(man,
                   CSV.read(joinpath(input_data_path, "Management.csv"), DataFrame),
                   on = [:plotID, :t, :x, :y])

    ########## Soil data - can be given...
    ##### over the whole time frame in Soil.csv
    ##### or yearly in Soil_yearly.csv
    soil_yearly = allcombinations(DataFrame, plotID = plotIDs, x = xs, y = ys, year = years)
    soil_yearly = leftjoin(soil_yearly, DataFrame(year = years), on = :year)

    if isfile(joinpath(input_data_path, "Soil.csv"))
        whole_period_soil_input = CSV.read(joinpath(input_data_path, "Soil.csv"), DataFrame)
        soil_yearly = leftjoin(soil_yearly, whole_period_soil_input, on = [:plotID, :x, :y])
    end

    if isfile(joinpath(input_data_path, "Soil_yearly.csv"))
        yearly_soil_input = CSV.read(joinpath(input_data_path, "Soil_yearly.csv"), DataFrame)
        soil_yearly = leftjoin(soil_yearly, yearly_soil_input,
                               on = [:plotID, :x, :y, :year])
        disallowmissing!(soil_yearly)
    end

    ## if no fertilization data is given, we set fertilization to 0.0
    if :fertilization ∉ names(soil_yearly)
        @transform! soil_yearly :fertilization = 0.0
    end

    inputs = Dict()

    for p in plotIDs
        nx = length(unique(clim.x[p .== clim.plotID]))
        ny = length(unique(clim.y[p .== clim.plotID]))
        nt = length(clim.t[p .== clim.plotID])
        nyears = length(unique(Dates.year.(clim.t[p .== clim.plotID])))

        ts = clim.t[p .== clim.plotID]
        years = unique(Dates.year.(ts))

        ########## Soil data
        soil_yearly_sub = @chain soil_yearly begin
            @subset :plotID .== p
            @subset :year .∈ Ref(years)
            @orderby :year
        end

        sand = Array{Float64}(undef, nyears, nx, ny)
        silt = Array{Float64}(undef, nyears, nx, ny)
        clay = Array{Float64}(undef, nyears, nx, ny)
        organic = Array{Float64}(undef, nyears, nx, ny)
        bulk = Array{typeof(1.0u"g/cm^3")}(undef, nyears, nx, ny)
        rootdepth = Array{typeof(1.0u"mm")}(undef, nyears, nx, ny)
        totalN = Array{typeof(1.0u"g/kg")}(undef, nyears, nx, ny)
        fertilization = Array{typeof(1.0u"kg/ha")}(undef, nyears, nx, ny)

        for (i,r) in enumerate(eachrow(soil_yearly_sub))
            sand[i, r.x, r.y] = r.sand
            silt[i, r.x, r.y] = r.silt
            clay[i, r.x, r.y] = r.clay
            organic[i, r.x, r.y] = r.organic
            bulk[i, r.x, r.y] = r.bulk * u"g/cm^3"
            rootdepth[i, r.x, r.y] = r.rootdepth * u"mm"
            totalN[i, r.x, r.y] = r.totalN * u"g/kg"
            fertilization[i, r.x, r.y] = r.fertilization * u"kg/ha"
        end

        sanddim = DimArray(sand, (; year = years, x = 1:nx, y = 1:ny), name = "sand")
        siltdim = DimArray(silt, (; year = years, x = 1:nx, y = 1:ny), name = "silt")
        claydim = DimArray(clay, (; year = years, x = 1:nx, y = 1:ny), name = "clay")
        organicdim = DimArray(organic, (; year = years, x = 1:nx, y = 1:ny), name = "organic")
        bulkdim = DimArray(bulk, (; year = years, x = 1:nx, y = 1:ny), name = "bulk")
        rootdepthdim = DimArray(rootdepth, (; year = years, x = 1:nx, y = 1:ny), name = "rootdepth")
        totalNdim = DimArray(totalN, (; year = years, x = 1:nx, y = 1:ny), name = "totalN")
        fertilizationdim = DimArray(fertilization, (; year = years, x = 1:nx, y = 1:ny), name = "fertilization")

        ########## Climate data
        clim_sub = @chain clim begin
            @subset :plotID .== p
            @orderby :t
        end

        temperature = Array{typeof(1.0u"°C")}(undef, nt, nx, ny)
        temperature_sum = Array{typeof(1.0u"°C")}(undef, nt, nx, ny)
        precipitation = Array{typeof(1.0u"mm")}(undef, nt, nx, ny)
        PET = Array{typeof(1.0u"mm")}(undef, nt, nx, ny)
        PET_sum = Array{typeof(1.0u"mm")}(undef, nt, nx, ny)
        PAR = Array{typeof(1.0u"MJ/ha")}(undef, nt, nx, ny)
        PAR_sum = Array{typeof(1.0u"MJ/ha")}(undef, nt, nx, ny)

        for (i,r) in enumerate(eachrow(clim_sub))
            temperature[i, r.x, r.y] = r.temperature * u"°C"
            temperature_sum[i, r.x, r.y] = r.temperature_sum * u"°C"
            precipitation[i, r.x, r.y] = r.precipitation * u"mm"
            PET[i, r.x, r.y] = r.PET * u"mm"
            PET_sum[i, r.x, r.y] = r.PET * u"mm"
            PAR[i, r.x, r.y] = r.PAR * u"MJ/ha"
            PAR_sum[i, r.x, r.y] = r.PAR * u"MJ/ha"
        end

        temperaturedim = DimArray(temperature, (; t = ts, x = 1:nx, y = 1:ny), name = "temperature")
        temperature_sumdim = DimArray(temperature_sum, (; t = ts, x = 1:nx, y = 1:ny), name = "temperature_sum")
        precipitationdim = DimArray(precipitation, (; t = ts, x = 1:nx, y = 1:ny), name = "precipitation")
        PETdim = DimArray(PET, (; t = ts, x = 1:nx, y = 1:ny), name = "PET")
        PET_sumdim = DimArray(PET_sum, (; t = ts, x = 1:nx, y = 1:ny), name = "PET_sum")
        PARdim = DimArray(PAR, (; t = ts, x = 1:nx, y = 1:ny), name = "PAR")
        PAR_sumdim = DimArray(PAR_sum, (; t = ts, x = 1:nx, y = 1:ny), name = "PAR_sum")

        ########## Management data
        man_sub = @chain copy(man) begin
            @subset :plotID .== p
            @subset :t .∈ Ref(ts)
            @orderby :t
        end

        CUT = Array{Union{typeof(missing), typeof(1.0u"m")}}(undef, nt, nx, ny)
        LD = Array{Union{typeof(missing), typeof(1.0u"ha^-1")}}(undef, nt, nx, ny)

        for (i,r) in enumerate(eachrow(man_sub))
            CUT[i, r.x, r.y] = r.CUT * u"m"
            LD[i, r.x, r.y] = r.LD * u"ha^-1"
        end

        CUTdim = DimArray(CUT, (; t = ts, x = 1:nx, y = 1:ny), name = "CUT_mowing")
        LDdim = DimArray(LD, (; t = ts, x = 1:nx, y = 1:ny), name = "LD_grazing")

        inputs[Symbol(p)] = DimStack(sanddim, siltdim, claydim,
                    organicdim, bulkdim, rootdepthdim,
                    totalNdim, fertilizationdim,
                    temperaturedim, temperature_sumdim,
                    precipitationdim,
                    PETdim, PET_sumdim, PARdim, PAR_sumdim,
                    CUTdim, LDdim)
    end

    global input_data = NamedTuple(inputs)

    return nothing
end

validation_input(plotID::Union{String, Symbol}; kwargs...) = validation_input(input_data[Symbol(plotID)]; kwargs...)

function validation_input(input_data; included = (;),
        use_height_layers = true,
        nspecies = nothing, trait_seed = missing,
        initbiomass = 5000.0u"kg/ha",
        initsoilwater = 100.0u"mm")

    included = create_included(included)

    if isnothing(nspecies)
        nspecies = length(input_traits().sla)
    end

    #### input date
    input_date_range = LookupArrays.index(input_data, :t)
    time_step_days = input_date_range[2] - input_date_range[1]
    time_step_hours = Dates.Hour(time_step_days)
    # exact_input_date = input_date_range .+ time_step_hours ÷ 2

    ### output date
    start_date = input_date_range[1]
    end_date = input_date_range[end] + time_step_days
    output_date_range = start_date:time_step_days:end_date

    ntimesteps = length(output_date_range) - 1
    years = unique(Dates.year.(input_date_range))
    nyears = length(years)
    patch_xdim = LookupArrays.index(input_data, :x)[end]
    patch_ydim = LookupArrays.index(input_data, :y)[end]

    return (
        simp = (;
            variations = (; use_height_layers),
            output_date = output_date_range,
            output_date_num = to_numeric.(output_date_range),
            mean_input_date = input_date_range,
            mean_input_year = Dates.year.(input_date_range),
            mean_input_date_num = to_numeric.(input_date_range),
            ts = Base.OneTo(ntimesteps),
            years,
            ntimesteps,
            nyears,
            nspecies,
            time_step_days,
            patch_xdim,
            patch_ydim,
            npatches = patch_xdim * patch_ydim,
            trait_seed,
            included,
            initbiomass,
            initsoilwater),
        input = input_data)
end

function create_included(included_prep = (;);)
    included = (;
        senescence = true,
        senescence_season = true,
        senescence_sla = true,
        potential_growth = true,
        mowing = true,
        grazing = true,
        belowground_competition = true,
        community_self_shading = true,
        height_competition = true,
        water_growth_reduction = true,
        nutrient_growth_reduction = true,
        root_invest = true,
        temperature_growth_reduction = true,
        seasonal_growth_adjustment = true,
        radiation_growth_reduction = true)

    for k in keys(included_prep)
        @reset included[k] = included_prep[k]
    end

    return included
end

function cumulative_temperature(temperature::Vector{Float64}, years)
    temperature_sum = []
    temperature = deepcopy(temperature)
    temperature[temperature .< 0] .= 0

    for y in unique(years)
        year_filter = y .== years
        append!(temperature_sum, cumsum(temperature[year_filter]))
    end

    return temperature_sum
end

function cumulative_temperature(temperature::Vector{typeof(1.0u"°C")}, years)
    temperature_sum = []
    temperature = deepcopy(temperature)
    temperature[temperature .< 0u"°C"] .= 0u"°C"

    for y in unique(years)
        year_filter = y .== years
        append!(temperature_sum, cumsum(temperature[year_filter]))
    end

    return temperature_sum
end


function scale_input(input; time_step_days = 14)
    input = deepcopy(input)

    old_date_range = LookupArrays.index(input, :t)
    time_step_days = Dates.Day(time_step_days)
    start_date = old_date_range[1]
    end_date = old_date_range[end]
    date_range = start_date:time_step_days:end_date

    ntimesteps = length(date_range) - 1

    nx = LookupArrays.index(input, :x)[end]
    ny = LookupArrays.index(input, :y)[end]

    temperature = Array{eltype(input.temperature)}(undef, ntimesteps, nx, ny)
    temperature_sum = Array{eltype(input.temperature_sum)}(undef, ntimesteps, nx, ny)
    precipitation = Array{eltype(input.precipitation)}(undef, ntimesteps, nx, ny)
    PET = Array{eltype(input.PET)}(undef, ntimesteps, nx, ny)
    PET_sum = Array{eltype(input.PET)}(undef, ntimesteps, nx, ny)
    par_type = eltype(float(input.PAR[1]))
    PAR = Array{par_type}(undef, ntimesteps, nx, ny)
    PAR_sum = Array{par_type}(undef, ntimesteps, nx, ny)
    CUT_mowing = Array{eltype(input.CUT_mowing)}(undef, ntimesteps, nx, ny)
    LD_grazing = Array{eltype(input.LD_grazing)}(undef, ntimesteps, nx, ny)


    for i in Base.OneTo(ntimesteps)
        sub_date = date_range[i]:(date_range[i+1] - Dates.Day(1))
        f = old_date_range .∈ Ref(sub_date)

        for x in 1:nx
            for y in 1:ny
                temperature[i, x, y] = mean(vec(input.temperature[f, x, y]))
                temperature_sum[i, x, y] = mean(vec(input.temperature_sum[f, x, y]))
                precipitation[i, x, y] = sum(input.precipitation[f, x, y])
                PET[i, x, y] = mean(input.PET[f, x, y])
                PET_sum[i, x, y] = sum(input.PET[f, x, y])
                PAR[i, x, y] = mean(input.PAR[f, x, y])
                PAR_sum[i, x, y] = sum(input.PAR[f, x, y])

                new_mowing_prep = input.CUT_mowing[f, x, y]
                if all(ismissing.(new_mowing_prep))
                    CUT_mowing[i, x, y] = missing
                else
                    mow_index = findfirst(.!ismissing.(new_mowing_prep))
                    CUT_mowing[i, x, y] = new_mowing_prep[mow_index]
                end

                new_grazing_prep = input.LD_grazing[f, x, y]
                if all(ismissing.(new_grazing_prep))
                    LD_grazing[i, x, y] = missing
                else
                    LD_grazing[i, x, y] = sum(new_grazing_prep[.!ismissing.(new_grazing_prep)])
                end
            end
        end
    end

    ts = date_range[1:end-1] .+ time_step_days ÷ 2
    temperaturedim = DimArray(temperature, (; t = ts, x = 1:nx, y = 1:ny), name = "temperature")
    temperature_sumdim = DimArray(temperature_sum, (; t = ts, x = 1:nx, y = 1:ny), name = "temperature_sum")
    precipitationdim = DimArray(precipitation, (; t = ts, x = 1:nx, y = 1:ny), name = "precipitation")
    PETdim = DimArray(PET, (; t = ts, x = 1:nx, y = 1:ny), name = "PET")
    PET_sumdim = DimArray(PET_sum, (; t = ts, x = 1:nx, y = 1:ny), name = "PET_sum")
    PARdim = DimArray(PAR, (; t = ts, x = 1:nx, y = 1:ny), name = "PAR")
    PAR_sumdim = DimArray(PAR_sum, (; t = ts, x = 1:nx, y = 1:ny), name = "PAR_sum")
    CUTdim = DimArray(CUT_mowing, (; t = ts, x = 1:nx, y = 1:ny), name = "CUT_mowing")
    LDdim = DimArray(LD_grazing, (; t = ts, x = 1:nx, y = 1:ny), name = "LD_grazing")

    return DimStack(input.sand, input.silt,input.clay, input.organic, input.bulk,
        input.rootdepth, input.totalN, input.fertilization,
        temperaturedim, temperature_sumdim, precipitationdim, PETdim, PET_sumdim,
        PARdim, PAR_sumdim, CUTdim, LDdim)
end
