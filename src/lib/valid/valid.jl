include("input_data.jl")
include("validation_data.jl")
include("likelihood.jl")
include("prior.jl")
include("posterior.jl")
include("predictive_check.jl")



function load_data(datapath)
    ########### validation data
    soilmoisture = CSV.read("$datapath/validation/soilmoisture.csv",
        DataFrame)

    evaporation = CSV.read("$datapath/validation/evaporation.csv",
        DataFrame)

    measuredbiomass = CSV.read("$datapath/validation/measured_biomass.csv",
        DataFrame)

    measuredheight = CSV.read("$datapath/validation/measured_height.csv",
        DataFrame)

    mtraits = CSV.read("$datapath/validation/cwm_cwv_traits.csv",
        DataFrame)

    traits = (
        cwm = [mtraits.cwm_sla mtraits.cwm_lncm mtraits.cwm_amc mtraits.cwm_rsa_above mtraits.cwm_height],
        cwv = [mtraits.cwv_sla mtraits.cwv_lncm mtraits.cwv_amc mtraits.cwv_rsa_above mtraits.cwv_height],
        dim = [:sla, :lnc, :amc, :srsa, :height],
        t = mtraits.date,
        num_t = mtraits.numeric_date,
        plotID = mtraits.plotID)

    valid = (;
        soilmoisture,
        evaporation,
        traits,
        measuredbiomass,
        measuredheight)

    ########### input data
    ## time dependent 2009-2022
    clim = CSV.read("$datapath/input/temperature_precipitation.csv",
        DataFrame)

    ## time dependent 2006-2008, temperature & precipitation
    dwd_clim = CSV.read("$datapath/input/dwd_temperature_precipitation.csv",
        DataFrame)

    ## time dependent 2006-2022
    pet = CSV.read("$datapath/input/PET.csv",
        DataFrame)

    ## time dependent 2006-2022
    par = CSV.read("$datapath/input/par.csv",
        DataFrame)

    ### mean index from 2011, 2014, 20117, 2021
    nut = CSV.read("$datapath/input/soilnutrients.csv",
        DataFrame)

    ## constant WHC & PWP
    soil = CSV.read("$datapath/input/soilwater.csv",
        DataFrame)

    ## time dependent 2006 - 2021
    mow = CSV.read("$datapath/input/mowing.csv",
        DataFrame)

    ## time dependent 2006 - 2021
    graz = CSV.read("$datapath/input/grazing.csv",
        DataFrame)

    input_traits = CSV.read("$datapath/input/traits.csv",
        DataFrame)
    input_traits.lbp = 0.8 .* input_traits.abp

    input = (;
        traits = input_traits,
        clim,
        dwd_clim,
        pet,
        par,
        nut,
        soil,
        mow,
        graz)

    global data = (;
        input,
        valid)

    return nothing
end

function get_plottingdata(sim::Module;
        input_objs,
        inf_p,
        plotID)

    ########################## Run model
    sol = sim.solve_prob(; input_obj = input_objs[plotID], inf_p)

    ########################## Measured data
    ## I shouldn't call this function each time...
    data = get_validation_data(; plotID)

    return data, sol
end
