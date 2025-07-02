function preallocate_vectors(; input_obj)
    @unpack output_date, mean_input_date, included, nspecies,
            ntimesteps, years, nyears = input_obj.simp

    ############# output variables
    #### State variables
    biomass = DimArray(
        Array{Float64}(undef, ntimesteps + 1, nspecies)u"kg/ha",
        (; time = output_date, species = 1:nspecies),
        name = :state_biomass)
    above_biomass = DimArray(
        Array{Float64}(undef, ntimesteps + 1, nspecies)u"kg/ha",
        (; time = output_date, species = 1:nspecies),
        name = :state_above_biomass)
    below_biomass = DimArray(
        Array{Float64}(undef, ntimesteps + 1, nspecies)u"kg/ha",
        (; time = output_date, species = 1:nspecies),
        name = :state_below_biomass)
    water = DimArray(Array{Float64}(undef, ntimesteps + 1)u"mm",
        (; time = output_date),
        name = :state_water)
    height = DimArray(
        Array{Float64}(undef, ntimesteps + 1, nspecies)u"m",
        (; time = output_date, species = 1:nspecies),
        name = :state_height)

    #### Species-specfic output variables
    mown = DimArray(
        Array{Float64}(undef, ntimesteps, nspecies)u"kg/ha",
        (; time = mean_input_date, species = 1:nspecies),
        name = :mown)
    grazed = DimArray(
        Array{Float64}(undef, ntimesteps, nspecies)u"kg/ha",
        (; time = mean_input_date, species = 1:nspecies),
        name = :grazed)
    senescence = DimArray(
        Array{Float64}(undef, ntimesteps, nspecies)u"kg/ha",
        (; time = mean_input_date, species = 1:nspecies),
        name = :senescence)
    growth_act = DimArray(
        Array{Float64}(undef, ntimesteps, nspecies)u"kg/ha",
        (; time = mean_input_date, species = 1:nspecies),
        name = :growth_act)
    light_growth = DimArray(
        Array{Float64}(undef, ntimesteps, nspecies),
        (; time = mean_input_date, species = 1:nspecies),
        name = :light_growth)
    nutrient_growth = DimArray(
        Array{Float64}(undef, ntimesteps, nspecies),
        (; time = mean_input_date, species = 1:nspecies),
        name = :nutrient_growth)
    nutrient_growth_rsa = DimArray(
        Array{Float64}(undef, ntimesteps, nspecies),
        (; time = mean_input_date, species = 1:nspecies),
        name = :nutrient_growth_rsa)
    nutrient_growth_amc = DimArray(
        Array{Float64}(undef, ntimesteps, nspecies),
        (; time = mean_input_date, species = 1:nspecies),
        name = :nutrient_growth_amc)
    water_growth = DimArray(
        Array{Float64}(undef, ntimesteps, nspecies),
        (; time = mean_input_date, species = 1:nspecies),
        name = :water_growth)
    root_invest = DimArray(
        Array{Float64}(undef, ntimesteps, nspecies),
        (; time = mean_input_date, species = 1:nspecies),
        name = :root_invest)
    nutrients_splitted = DimArray(
        Array{Float64}(undef, ntimesteps, nspecies),
        (; time = mean_input_date, species = 1:nspecies),
        name = :nutrients_splitted)

    #### Community-level output variables
    community_pot_growth = DimArray(
        Array{Float64}(undef, ntimesteps)u"kg/ha",
        (; time = mean_input_date),
        name = :community_pot_growth)
    community_height_reducer = DimArray(
        Array{Float64}(undef, ntimesteps),
        (; time = mean_input_date),
        name = :community_height_reducer)
    radiation_reducer = DimArray(
        Array{Float64}(undef, ntimesteps),
        (; time = mean_input_date),
        name = :radiation_reducer)
    temperature_reducer = DimArray(
        Array{Float64}(undef, ntimesteps),
        (; time = mean_input_date),
        name = :temperature_reducer)
    seasonal_growth = DimArray(
        Array{Float64}(undef, ntimesteps),
        (; time = mean_input_date),
        name = :seasonal_growth)
    seasonal_senescence = DimArray(
        Array{Float64}(undef, ntimesteps),
        (; time = mean_input_date),
        name = :seasonal_senescence)
    fodder_supply = DimArray(
        Array{Float64}(undef, ntimesteps)u"kg/ha",
        (; time = mean_input_date),
        name = :fodder_supply)
    mean_nutrient_index = DimArray(
        Array{Float64}(undef, ntimesteps),
        (; time = mean_input_date),
        name = :mean_nutrient_index)

    output = (; biomass, above_biomass, below_biomass, water, height,
              mown, grazed, senescence, light_growth, growth_act, water_growth,
              nutrient_growth, nutrient_growth_rsa, nutrient_growth_amc,
              root_invest, nutrients_splitted,
              community_pot_growth, community_height_reducer,
              radiation_reducer, temperature_reducer, seasonal_growth,
              seasonal_senescence, fodder_supply, mean_nutrient_index)

    ############# change and state variables
    du_biomass = DimArray(
        Array{Float64}(undef, nspecies)u"kg / ha",
        (; species = 1:nspecies),
        name = :du_biomass)
    du_above_biomass = DimArray(
        Array{Float64}(undef, nspecies)u"kg / ha",
        (; species = 1:nspecies),
        name = :du_above_biomass)
    du_below_biomass = DimArray(
        Array{Float64}(undef, nspecies)u"kg / ha",
        (; species = 1:nspecies),
        name = :du_below_biomass)
    du_height = DimArray(
        Array{Float64}(undef, nspecies)u"m",
        (; species = 1:nspecies),
        name = :du_height)
    u_biomass = DimArray(
        Array{Float64}(undef, nspecies)u"kg / ha",
        (; species = 1:nspecies),
        name = :u_biomass)
    u_above_biomass = DimArray(
        Array{Float64}(undef, nspecies)u"kg / ha",
        (; species = 1:nspecies),
        name = :u_above_biomass)
    u_below_biomass = DimArray(
        Array{Float64}(undef, nspecies)u"kg / ha",
        (; species = 1:nspecies),
        name = :u_below_biomass)
    u_height = DimArray(
        Array{Float64}(undef, nspecies)u"m",
        (; species = 1:nspecies),
        name = :u_height)

    u = (; du_biomass, du_above_biomass, du_below_biomass, du_height,
           u_biomass, u_above_biomass, u_below_biomass, u_height)

    ############# patch variables
    WHC = DimArray(
        Array{Float64}(undef, nyears)u"mm",
        (; year = years), name = :WHC)
    PWP = DimArray(
        Array{Float64}(undef, nyears)u"mm",
        (; year = years), name = :PWP)
    nutrients = DimArray(
        Array{Float64}(undef, nyears),
        (; year = years), name = :nutrients)
    soil_variables = (; WHC, PWP, nutrients)

    ############# Transfer function
    transfer_function = (;
        R_05 = Array{Float64}(undef, nspecies),
        x0 = Array{Float64}(undef, nspecies))

    max_height = 2.0u"m"
    Δheightlayer = 0.05u"m"
    nheight_layers = ceil(Int64, max_height / Δheightlayer)

    calc = (;
        com = CommunityLevel(),

        ############ preallaocated vectors that are used in the calculations
        LIG = Array{Float64}(undef, nspecies),
        growth_act = Array{Float64}(undef, nspecies)u"kg / ha",
        senescence = Array{Float64}(undef, nspecies)u"kg / ha",
        defoliation = Array{Float64}(undef, nspecies)u"kg / ha",
        species_specific_red = Array{Float64}(undef, nspecies),
        LAIs = Array{Float64}(undef, nspecies),
        height_gain = Array{Float64}(undef, nspecies)u"m",
        height_loss_mowing = Array{Float64}(undef, nspecies)u"m",
        height_loss_grazing = Array{Float64}(undef, nspecies)u"m",
        allocation_above = Array{Float64}(undef, nspecies),
        above_proportion = Array{Float64}(undef, nspecies),
        above_divided_below = Array{Float64}(undef, nspecies),

        ## cut biomass
        species_mean_above_biomass = Array{Float64}(undef, nspecies)u"kg / ha",
        species_mean_actual_height = Array{Float64}(undef, nspecies)u"m",
        species_cut_biomass = Array{Float64}(undef, nspecies)u"kg / ha",

        ## functional response helper variables
        K_prep = Array{Float64}(undef, nspecies),
        denominator = Array{Float64}(undef, nspecies),

        ## helper variables for generation of traits
        traitmat = Matrix{Float64}(undef, 7, nspecies),
        amc_resid = Array{Float64}(undef, nspecies),
        rsa_resid = Array{Float64}(undef, nspecies),

        ## below ground competition
        nutrients_adj_factor = Array{Float64}(undef, nspecies),
        TS_biomass = Array{Float64}(undef, nspecies)u"kg / ha",
        TS = Array{Float64}(undef, nspecies, nspecies),

        ## height influence
        lais_heightinfluence = Array{Float64}(undef, nspecies),
        heightinfluence = Array{Float64}(undef, nspecies),
        relative_height = Array{Float64}(undef, nspecies)u"m",

        # leaf nitrogen (palatability) --> grazing
        relative_lnc = Array{Float64}(undef, nspecies)u"mg/g",
        lncinfluence = Array{Float64}(undef, nspecies),
        biomass_scaled = Array{Float64}(undef, nspecies)u"kg / ha",

        ## investment to roots
        ROOT = Array{Float64}(undef, nspecies),
        root_invest_srsa = Array{Float64}(undef, nspecies),
        root_invest_amc = Array{Float64}(undef, nspecies),

        ## nutrient reducer function
        nutrients_splitted = Array{Float64}(undef, nspecies),
        NUT = Array{Float64}(undef, nspecies),
        N_amc = Array{Float64}(undef, nspecies),
        N_rsa = Array{Float64}(undef, nspecies),

        ## water reducer function
        WAT = Array{Float64}(undef, nspecies),

        ## mowing and grazing
        feedible_biomass = Array{Float64}(undef, nspecies)u"kg / ha",
        mown_height = Array{Float64}(undef, nspecies)u"m",
        proportion_mown = Array{Float64}(undef, nspecies),
        grazed_share = Array{Float64}(undef, nspecies),
        mown = Array{Float64}(undef, nspecies)u"kg / ha",
        grazed = Array{Float64}(undef, nspecies)u"kg / ha",
        trampled = Array{Float64}(undef, nspecies)u"kg / ha",

        ## senescence
        senescence_rate = Array{Float64}(undef, nspecies),
        senescence_sla = Array{Float64}(undef, nspecies),

        ## height layers
        min_height_layer = collect(0.0u"m":Δheightlayer:nheight_layers*Δheightlayer-Δheightlayer),
        max_height_layer = collect(Δheightlayer:Δheightlayer:nheight_layers*Δheightlayer),
        LAIs_layer = Array{Float64}(undef, nspecies, nheight_layers),
        LAItot_layer = Array{Float64}(undef, nheight_layers),
        cumLAItot_above = Array{Float64}(undef, nheight_layers),
        Intensity_layer = Array{Float64}(undef, nheight_layers),
        fPAR_layer = Array{Float64}(undef, nspecies, nheight_layers)
    )

    return (; u, state_water = StateWater(),
            soil_variables, calc,
            transfer_function, output)
end

@kwdef mutable struct CommunityLevel{Qkg_ha}
    LAItot::Float64 = 0.0
    growth_pot_total::Qkg_ha = 0.0u"kg/ha"
    RUE_community_height::Float64 = 1.0
    RAD::Float64 = 1.0
    SEA::Float64 = 1.0
    TEMP::Float64 = 1.0
    SEN_season::Float64 = 1.0
    fodder_supply::Qkg_ha = 0.0u"kg/ha"
end

@kwdef mutable struct StateWater{Qmm}
    du_water::Qmm = 0.0u"mm"
    u_water::Qmm = 0.0u"mm"
end

struct PreallocCache
    cache::Vector{Any}
end

function PreallocCache(nplots::Int)
    return PreallocCache(fill(nothing, nplots))
end

function get_buffer(c::PreallocCache, plot_id; input_obj)
    if isnothing(c.cache[plot_id])
        c.cache[plot_id] = preallocate_vectors(; input_obj)
    end
    return c.cache[plot_id]
end

struct PreallocCache2
    cache::Vector{Vector{Any}}
end

function PreallocCache2(nthreads::Int, nplots::Int)
    return PreallocCache2(fill(fill(nothing, nplots), nthreads))
end

function get_buffer(c::PreallocCache2, thread_id, plot_id; input_obj)
    if isnothing(c.cache[thread_id][plot_id])
        c.cache[thread_id][plot_id] = preallocate_vectors(; input_obj)
    end
    return c.cache[thread_id][plot_id]
end
