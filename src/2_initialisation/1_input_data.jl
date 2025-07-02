species_data = DataFrame()
input_data = NamedTuple()
plot_data = DataFrame()

function load_data(inputdata_path = joinpath(DEFAULT_ARTIFACTS_DIR, "Input_data"))
    load_species(inputdata_path)
    load_input_data(inputdata_path)
end

function load_species(inputdata_path)
    global species_data = CSV.read("$inputdata_path/Species.csv", DataFrame)
    return nothing
end

function load_input_data(input_data_path)
    @info "Load input data from: $input_data_path"
    ########## Base information
    global plot_data = CSV.read(joinpath(input_data_path, "Plots.csv"), DataFrame)
    plotIDs = plot_data.plotID
    nplots = length(plotIDs)
    start_dates = plot_data.startDate
    end_dates = plot_data.endDate
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
            i == 1 && @info "Using plot-specific management"
            man = leftjoin(man, @subset(man_input, :plotID .== p),
                           on = :t, order = :left)
        else
            i == 1 && @info "Using the same management for all plots (for plot-specific management, supply Management.csv with a plotID column)"
            man = leftjoin(man, man_input, on = :t, order = :left)
        end

        CUTdim = DimArray(man.CUT .* u"m", (; t = ts_plot), name = "CUT_mowing")
        LDdim = DimArray(man.LD .* u"ha^-1", (; t = ts_plot), name = "LD_grazing")

        ########## Soil data
        soil_yearly = DataFrame(year = years_plot)
        if !isnothing(soil_input)
            if "plotID" ∈ names(soil_input)
                i == 1 && @info "Using plot-specific soil data"
                soil_yearly = @orderby(crossjoin(soil_yearly,
                                                 @subset(soil_input, :plotID .== p)),
                                       :year)
            else
                i == 1 && @info "Using the same soil data for all plots (for plot-specific soil data, supply Soil.csv with a plotID column)"
                soil_yearly = @orderby(crossjoin(soil_yearly, soil_input),
                                       :year)
            end
        end
        if !isnothing(soil_yearly_input)
            if "plotID" ∈ names(soil_yearly_input)
                i == 1 && @info "Using plot-specific yearly soil data"
                soil_yearly = leftjoin(soil_yearly,
                                       @subset(soil_yearly_input, :plotID .== p),
                                       on = :year, order = :left, makeunique = true)
            else
                i == 1 && @info "Using the same yearly soil data for all plots (for plot-specific yearly soil data, supply Soil_yearly.csv with a plotID column)"
                soil_yearly = leftjoin(soil_yearly, soil_yearly_input,
                                       on = :year, order = :left)
            end
        end
        if "fertilization" ∉ names(soil_yearly)
            i == 1 && @info "No fertilization data given, set fertilization to 0.0"
            @transform! soil_yearly :fertilization = 0.0
        end

        sanddim = DimArray(soil_yearly.sand, (; year = years_plot), name = "sand")
        siltdim = DimArray(soil_yearly.silt, (; year = years_plot), name = "silt")
        claydim = DimArray(soil_yearly.clay, (; year = years_plot), name = "clay")
        organicdim = DimArray(soil_yearly.organic, (; year = years_plot), name = "organic")
        bulkdim = DimArray(soil_yearly.bulk * u"g/cm^3", (; year = years_plot), name = "bulk")
        rootdepthdim = DimArray(soil_yearly.rootdepth * u"mm", (; year = years_plot), name = "rootdepth")
        totalNdim = DimArray(soil_yearly.totalN * u"g/kg", (; year = years_plot), name = "totalN")
        fertilizationdim = DimArray(soil_yearly.fertilization * u"kg/ha", (; year = years_plot), name = "fertilization")

        ########## Climate data
        clim = DataFrame(t = ts_plot)
        if "plotID" ∈ names(clim_input)
            i == 1 && @info "Using plot-specific climate data"
            clim = leftjoin(clim, @subset(clim_input, :plotID .== p),
                            on = :t, order = :left)
        else
            i == 1 && @info "Using the same climate data for all plots (for plot-specific climate data, supply Climate.csv with a plotID column)"
            clim = leftjoin(clim, clim_input, on = :t, order = :left)
        end

        temperaturedim = DimArray(clim.temperature .* u"°C", (; t = ts_plot), name = "temperature")
        temperature_sumdim = DimArray(clim.temperature_sum .* u"°C", (; t = ts_plot), name = "temperature_sum")
        precipitationdim = DimArray(clim.precipitation .* u"mm", (; t = ts_plot), name = "precipitation")
        PETdim = DimArray(clim.PET .* u"mm", (; t = ts_plot), name = "PET")
        PET_sumdim = DimArray(clim.PET .* u"mm", (; t = ts_plot), name = "PET_sum")
        PARdim = DimArray(clim.PAR .* u"MJ/ha", (; t = ts_plot), name = "PAR")
        PAR_sumdim = DimArray(clim.PAR .* u"MJ/ha", (; t = ts_plot), name = "PAR_sum")

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
    println() # print empty line / looks better

    global input_data = NamedTuple(inputs)

    return nothing
end

####################################################################
#####################################################################
function create_input(plotID; included = (;))
    included = create_included(included)
    input_data_plot = input_data[Symbol(plotID)]
    init_plot = initial_conditions(plotID)
    traits_plot = input_traits(plotID)

    #### input date
    input_date_range = LookupArrays.index(input_data_plot, :t)
    time_step_days = input_date_range[2] - input_date_range[1]
    # exact_input_date = input_date_range .+ Dates.Hour(time_step_days) ÷ 2

    ### output date
    start_date = input_date_range[1]
    end_date = input_date_range[end] + time_step_days
    output_date_range = start_date:time_step_days:end_date

    ntimesteps = length(output_date_range) - 1
    years = unique(Dates.year.(input_date_range))
    nyears = length(years)

    return (
        simp = (;
            output_date = output_date_range,
            output_date_num = to_numeric.(output_date_range),
            mean_input_date = input_date_range,
            mean_input_year = Dates.year.(input_date_range),
            mean_input_date_num = to_numeric.(input_date_range),
            ts = Base.OneTo(ntimesteps),
            years,
            ntimesteps,
            nyears,
            nspecies = length(traits_plot.sla),
            time_step_days,
            included),
        input = input_data_plot,
        traits = traits_plot,
        init = init_plot)
end

function input_traits(plotID = nothing)
    species_data_sub = species_data

    if "plotID" ∈ names(species_data)
        species_data_sub = @subset(species_data, :plotID .== String(plotID))
    end

    return (;
        amc = species_data_sub.amc,
        sla = species_data_sub.sla * u"m^2/g",
        maxheight = species_data_sub.maxheight * u"m",
        rsa = species_data_sub.rsa * u"m^2/g",
        abp = species_data_sub.abp,
        lbp = species_data_sub.lbp,
        lnc = species_data_sub.lnc * u"mg/g");

end

function initial_conditions(plotID)
    species_data_sub = species_data
    if "plotID" ∈ names(species_data)
        species_data_sub = @subset(deepcopy(species_data), :plotID .== String(plotID))
    end

    plot_data_sub = @subset(deepcopy(plot_data), :plotID .== String(plotID))

    return (;
        AbovegroundBiomass = species_data_sub.initAbovegroundBiomass * u"kg/ha",
        BelowgroundBiomass = species_data_sub.initBelowgroundBiomass * u"kg/ha",
        Height = species_data_sub.initHeight * u"m",
        Soilwater = plot_data_sub.initSoilwater[1] * u"mm",
    );
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
