module GrasslandTraitSim

import CSV
import Dates
import Random

using Accessors
using DataFrames
using DataFramesMeta
using DimensionalData
using Distributions
using DocStringExtensions
using JLD2
using LinearAlgebra
using PrettyTables
using Statistics
using StatsBase
using Unitful
using UnPack

@template (FUNCTIONS, METHODS) =
    """
    $(SIGNATURES)
    $(DOCSTRING)
    """

include("main_functions.jl")
include("one_day.jl")

include("1_parameter/1_parameter.jl")

include("2_initialisation/1_input_data.jl")
include("2_initialisation/2_validation_data.jl")
include("2_initialisation/3_initialisation.jl")
include("2_initialisation/4_preallocation.jl")
include("2_initialisation/5_traits.jl")

include("3_biomass/1_growth/1_growth.jl")
include("3_biomass/2_senescence/1_senescence.jl")
include("3_biomass/3_management/1_grazing.jl")
include("3_biomass/3_management/2_mowing.jl")
include("3_biomass/3_management/3_cut_biomass_for_likelihood.jl")

include("4_height/height.jl")

include("5_water/water.jl")


const ASSETS_DIR = joinpath(@__DIR__, "..", "assets")
assetpath(files...) = normpath(joinpath(ASSETS_DIR, files...))

function __init__()
    datapath = assetpath("data")
    load_gm(datapath)
    load_data(datapath)

    return nothing
end

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

    mtraits = CSV.read("$datapath/validation/cwm_traits.csv",
        DataFrame)

    traits = (
        cwm = [mtraits.rsa mtraits.amc mtraits.abp mtraits.sla mtraits.maxheight mtraits.lnc],
        dim = [:rsa, :amc, :abp, :sla, :maxheight, :lnc],
        t = mtraits.date,
        num_t = mtraits.numeric_date,
        plotID = mtraits.plotID)

    fun_diversity = (;
        fdis = mtraits.fdis,
        t = mtraits.date,
        num_t = mtraits.numeric_date,
        plotID = mtraits.plotID
    )

    valid = (;
        soilmoisture,
        evaporation,
        traits,
        fun_diversity,
        measuredbiomass,
        measuredheight)

    ########### input data
    ## time dependent 2009-2022
    clim = CSV.read("$datapath/input/temperature_precipitation.csv",
        DataFrame)

    ## time dependent 2006-2008, temperature & precipitation
    dwd_clim = CSV.read("$datapath/input/temperature_precipitation_dwd.csv",
        DataFrame)

    ## time dependent 2006-2022
    pet = CSV.read("$datapath/input/pet.csv",
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
    supplementary_feeding = CSV.read("$datapath/input/supplementary_feeding.csv",
        DataFrame)

    ## constant approx coordinates (mainly for selecting calibration / validation sites)
    coord = CSV.read(
        "$datapath/input/approx_coordinates.csv",
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
        graz,
        supplementary_feeding,
        coord)

    global data = (;
        input,
        valid)

    return nothing
end

function load_optim_result()
    return load(assetpath("data/optim.jld2"), "θ");
end


function optim_parameter()
    θ = load_optim_result()
    return SimulationParameter(; θ...)
end

# see extension for the implementation
function dashboard end

end
