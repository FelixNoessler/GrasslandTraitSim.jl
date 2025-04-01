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
    ########## Base information
    info = CSV.read(joinpath(input_data_path, "Plots.csv"), DataFrame)
    plotIDs = info.plotID
    nplots = length(plotIDs)
    start_dates = info.startDate
    end_dates = info.endDate
    ts = [start_dates[i]:Dates.Day(1):end_dates[i] for i in 1:nplots]
    years = [Dates.year(start_dates[i]):1:Dates.year(end_dates[i]) for i in 1:nplots]

    ########## Management data (Management.csv)
    ##### can be plot specific or the same for all plots
    man_input = CSV.read(joinpath(input_data_path, "Management.csv"), DataFrame)

    ########## Soil data (Soil.csv, Soil_yearly.csv)
    ##### over the whole time frame in Soil.csv
    ##### or yearly in Soil_yearly.csv
    ##### for both files: can be plot specific or the same for all plots
    soil_input = nothing
    if isfile(joinpath(input_data_path, "Soil.csv"))
        soil_input = CSV.read(joinpath(input_data_path, "Soil.csv"), DataFrame)
    end

    soil_yearly_input = nothing
    if isfile(joinpath(input_data_path, "Soil_yearly.csv"))
        soil_yearly_input = CSV.read(joinpath(input_data_path, "Soil_yearly.csv"), DataFrame)
    end

    if isnothing(soil_input) && isnothing(soil_yearly_input)
        error("No soil data given, supply either Soil.csv or Soil_yearly.csv")
    end

    ########## Climate data (Climate.csv)
    ##### can be plot specific or the same for all plots
    clim_input = CSV.read(joinpath(input_data_path, "Climate.csv"), DataFrame)

    inputs = Dict()

    for (i,p) in enumerate(plotIDs)
        nt = length(ts[i])
        nyears = length(years[i])
        ts_plot = ts[i]
        years_plot = years[i]

        ########## Management data
        man = DataFrame(t = ts_plot)
        if "plotID" ∈ names(man_input)
            @info "Using plot-specific management" maxlog=1
            man = leftjoin(man, @subset(man_input, :plotID .== p),
                           on = :t, order = :left)
        else
            @info "Using the same management for all plots (for plot-specific management, supply Management.csv with a plotID column)" maxlog=1
            man = leftjoin(man, man_input, on = :t, order = :left)
        end

        CUT = Array{Union{typeof(missing), typeof(1.0u"m")}}(undef, nt)
        LD = Array{Union{typeof(missing), typeof(1.0u"ha^-1")}}(undef, nt)

        CUT .= man.CUT .* u"m"
        LD .= man.LD .* u"ha^-1"

        CUTdim = DimArray(CUT, (; t = ts_plot), name = "CUT_mowing")
        LDdim = DimArray(LD, (; t = ts_plot), name = "LD_grazing")

        ########## Soil data
        soil_yearly = DataFrame(year = years_plot)
        if !isnothing(soil_input)
            if "plotID" ∈ names(soil_input)
                @info "Using plot-specific soil data" maxlog=1
                soil_yearly = @orderby(crossjoin(soil_yearly,
                                                 @subset(soil_input, :plotID .== p)),
                                       :year)
            else
                @info "Using the same soil data for all plots (for plot-specific soil data, supply Soil.csv with a plotID column)" maxlog=1
                soil_yearly = @orderby(crossjoin(soil_yearly, soil_input),
                                       :year)
            end
        end
        if !isnothing(soil_yearly_input)
            if "plotID" ∈ names(soil_yearly_input)
                @info "Using plot-specific yearly soil data" maxlog=1
                soil_yearly = leftjoin(soil_yearly,
                                       @subset(soil_yearly_input, :plotID .== p),
                                       on = :year, order = :left, makeunique = true)
            else
                @info "Using the same yearly soil data for all plots (for plot-specific yearly soil data, supply Soil_yearly.csv with a plotID column)" maxlog=1
                soil_yearly = leftjoin(soil_yearly, soil_yearly_input,
                                       on = :year, order = :left)
            end
        end
        if "fertilization" ∉ names(soil_yearly)
            @info "No fertilization data given, set fertilization to 0.0"
            @transform! soil_yearly :fertilization = 0.0
        end

        sand = Array{Float64}(undef, nyears)
        silt = Array{Float64}(undef, nyears)
        clay = Array{Float64}(undef, nyears)
        organic = Array{Float64}(undef, nyears)
        bulk = Array{typeof(1.0u"g/cm^3")}(undef, nyears)
        rootdepth = Array{typeof(1.0u"mm")}(undef, nyears)
        totalN = Array{typeof(1.0u"g/kg")}(undef, nyears)
        fertilization = Array{typeof(1.0u"kg/ha")}(undef, nyears)

        sand .= soil_yearly.sand
        silt .= soil_yearly.silt
        clay .= soil_yearly.clay
        organic .= soil_yearly.organic
        bulk .= soil_yearly.bulk * u"g/cm^3"
        rootdepth .= soil_yearly.rootdepth * u"mm"
        totalN .= soil_yearly.totalN * u"g/kg"
        fertilization .= soil_yearly.fertilization * u"kg/ha"

        sanddim = DimArray(sand, (; year = years_plot), name = "sand")
        siltdim = DimArray(silt, (; year = years_plot), name = "silt")
        claydim = DimArray(clay, (; year = years_plot), name = "clay")
        organicdim = DimArray(organic, (; year = years_plot), name = "organic")
        bulkdim = DimArray(bulk, (; year = years_plot), name = "bulk")
        rootdepthdim = DimArray(rootdepth, (; year = years_plot), name = "rootdepth")
        totalNdim = DimArray(totalN, (; year = years_plot), name = "totalN")
        fertilizationdim = DimArray(fertilization, (; year = years_plot), name = "fertilization")

        ########## Climate data
        clim = DataFrame(t = ts_plot)
        if "plotID" ∈ names(clim_input)
            @info "Using plot-specific climate data" maxlog=1
            clim = leftjoin(clim, @subset(clim_input, :plotID .== p),
                            on = :t, order = :left)
        else
            @info "Using the same climate data for all plots (for plot-specific climate data, supply Climate.csv with a plotID column)" maxlog=1
            clim = leftjoin(clim, clim_input, on = :t, order = :left)
        end

        temperature = Array{typeof(1.0u"°C")}(undef, nt)
        temperature_sum = Array{typeof(1.0u"°C")}(undef, nt)
        precipitation = Array{typeof(1.0u"mm")}(undef, nt)
        PET = Array{typeof(1.0u"mm")}(undef, nt)
        PET_sum = Array{typeof(1.0u"mm")}(undef, nt)
        PAR = Array{typeof(1.0u"MJ/ha")}(undef, nt)
        PAR_sum = Array{typeof(1.0u"MJ/ha")}(undef, nt)

        temperature .= clim.temperature .* u"°C"
        temperature_sum .= clim.temperature_sum .* u"°C"
        precipitation .= clim.precipitation .* u"mm"
        PET .= clim.PET .* u"mm"
        PET_sum .= clim.PET .* u"mm"
        PAR .= clim.PAR .* u"MJ/ha"
        PAR_sum .= clim.PAR .* u"MJ/ha"

        temperaturedim = DimArray(temperature, (; t = ts_plot), name = "temperature")
        temperature_sumdim = DimArray(temperature_sum, (; t = ts_plot), name = "temperature_sum")
        precipitationdim = DimArray(precipitation, (; t = ts_plot), name = "precipitation")
        PETdim = DimArray(PET, (; t = ts_plot), name = "PET")
        PET_sumdim = DimArray(PET_sum, (; t = ts_plot), name = "PET_sum")
        PARdim = DimArray(PAR, (; t = ts_plot), name = "PAR")
        PAR_sumdim = DimArray(PAR_sum, (; t = ts_plot), name = "PAR_sum")

        ########## Combine all data
        inputs[Symbol(p)] = DimStack(
            sanddim, siltdim, claydim,
            organicdim, bulkdim, rootdepthdim,
            totalNdim, fertilizationdim,
            temperaturedim, temperature_sumdim,
            precipitationdim,
            PETdim, PET_sumdim, PARdim, PAR_sumdim,
            CUTdim, LDdim
        )
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
