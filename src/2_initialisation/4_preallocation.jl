function preallocate_vectors(; input_obj, T = Float64)
    @unpack output_date, mean_input_date, included, nspecies,
            patch_xdim, patch_ydim, ntimesteps, years, nyears = input_obj.simp

    ############# output variables
    #### State variables
    biomass = DimArray(
        Array{T}(undef, ntimesteps + 1, patch_xdim, patch_ydim, nspecies)u"kg/ha",
        (time = output_date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :state_biomass)
    above_biomass = DimArray(
        Array{T}(undef, ntimesteps + 1, patch_xdim, patch_ydim, nspecies)u"kg/ha",
        (time = output_date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :state_above_biomass)
    below_biomass = DimArray(
        Array{T}(undef, ntimesteps + 1, patch_xdim, patch_ydim, nspecies)u"kg/ha",
        (time = output_date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :state_below_biomass)
    water = DimArray(Array{T}(undef, ntimesteps + 1, patch_xdim, patch_ydim)u"mm",
        (time = output_date, x = 1:patch_xdim, y = 1:patch_ydim),
        name = :state_water)
    height = DimArray(
        Array{T}(undef, ntimesteps + 1, patch_xdim, patch_ydim, nspecies)u"m",
        (time = output_date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :state_height)

    #### Species-specfic output variables
    mown = DimArray(
        Array{T}(undef, ntimesteps, patch_xdim, patch_ydim, nspecies)u"kg/ha",
        (time = mean_input_date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :mown)
    grazed = DimArray(
        Array{T}(undef, ntimesteps, patch_xdim, patch_ydim, nspecies)u"kg/ha",
        (time = mean_input_date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :grazed)
    senescence = DimArray(
        Array{T}(undef, ntimesteps, patch_xdim, patch_ydim, nspecies)u"kg/ha",
        (time = mean_input_date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :senescence)
    growth_act = DimArray(
        Array{T}(undef, ntimesteps,  patch_xdim, patch_ydim, nspecies)u"kg/ha",
        (time = mean_input_date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :growth_act)
    light_growth = DimArray(
        Array{T}(undef, ntimesteps,  patch_xdim, patch_ydim, nspecies),
        (time = mean_input_date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :light_growth)
    nutrient_growth = DimArray(
        Array{T}(undef, ntimesteps,  patch_xdim, patch_ydim, nspecies),
        (time = mean_input_date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :nutrient_growth)
    water_growth = DimArray(
        Array{T}(undef, ntimesteps,  patch_xdim, patch_ydim, nspecies),
        (time = mean_input_date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :water_growth)
    root_invest = DimArray(
        Array{T}(undef, ntimesteps,  patch_xdim, patch_ydim, nspecies),
        (time = mean_input_date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :root_invest)

    #### Community-level output variables
    community_pot_growth = DimArray(
        Array{T}(undef, ntimesteps, patch_xdim, patch_ydim)u"kg/ha",
        (time = mean_input_date, x = 1:patch_xdim, y = 1:patch_ydim),
        name = :community_pot_growth)
    community_height_reducer = DimArray(
        Array{T}(undef, ntimesteps, patch_xdim, patch_ydim),
        (time = mean_input_date, x = 1:patch_xdim, y = 1:patch_ydim),
        name = :community_height_reducer)
    radiation_reducer = DimArray(
        Array{T}(undef, ntimesteps,  patch_xdim, patch_ydim),
        (time = mean_input_date, x = 1:patch_xdim, y = 1:patch_ydim),
        name = :radiation_reducer)
    temperature_reducer = DimArray(
        Array{T}(undef, ntimesteps,  patch_xdim, patch_ydim),
        (time = mean_input_date, x = 1:patch_xdim, y = 1:patch_ydim),
        name = :temperature_reducer)
    seasonal_growth = DimArray(
        Array{T}(undef, ntimesteps,  patch_xdim, patch_ydim),
        (time = mean_input_date, x = 1:patch_xdim, y = 1:patch_ydim),
        name = :seasonal_growth)
    seasonal_senescence = DimArray(
        Array{T}(undef, ntimesteps,  patch_xdim, patch_ydim),
        (time = mean_input_date, x = 1:patch_xdim, y = 1:patch_ydim),
        name = :seasonal_senescence)
    fodder_supply = DimArray(
        Array{T}(undef, ntimesteps,  patch_xdim, patch_ydim)u"kg/ha",
        (time = mean_input_date, x = 1:patch_xdim, y = 1:patch_ydim),
        name = :fodder_supply)

    output = (; biomass, above_biomass, below_biomass, water, height,
              mown, grazed, senescence, community_pot_growth, community_height_reducer,
              growth_act, radiation_reducer, seasonal_growth, temperature_reducer,
              seasonal_senescence, fodder_supply, light_growth,
              water_growth, nutrient_growth, root_invest)

    ############# change and state variables
    du_biomass = DimArray(
        Array{T}(undef, patch_xdim, patch_ydim, nspecies)u"kg / ha",
        (x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :du_biomass)
    du_above_biomass = DimArray(
        Array{T}(undef, patch_xdim, patch_ydim, nspecies)u"kg / ha",
        (x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :du_above_biomass)
    du_below_biomass = DimArray(
        Array{T}(undef, patch_xdim, patch_ydim, nspecies)u"kg / ha",
        (x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :du_below_biomass)
    du_water = DimArray(
        Array{T}(undef, patch_xdim, patch_ydim)u"mm",
        (x = 1:patch_xdim, y = 1:patch_ydim), name = :du_water)
    du_height = DimArray(
        Array{T}(undef, patch_xdim, patch_ydim, nspecies)u"m",
        (x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :du_height)
    u_biomass = DimArray(
        Array{T}(undef, patch_xdim, patch_ydim, nspecies)u"kg / ha",
        (x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :u_biomass)
    u_above_biomass = DimArray(
        Array{T}(undef, patch_xdim, patch_ydim, nspecies)u"kg / ha",
        (x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :u_above_biomass)
    u_below_biomass = DimArray(
        Array{T}(undef, patch_xdim, patch_ydim, nspecies)u"kg / ha",
        (x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :u_below_biomass)
    u_water = DimArray(
        Array{T}(undef, patch_xdim, patch_ydim)u"mm",
        (x = 1:patch_xdim, y = 1:patch_ydim),
        name = :u_water)
    u_height = DimArray(
        Array{T}(undef, patch_xdim, patch_ydim, nspecies)u"m",
        (x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :u_height)

    u = (; du_biomass, du_above_biomass, du_below_biomass, du_water, du_height,
         u_biomass, u_above_biomass, u_below_biomass, u_water, u_height)

    ############# patch variables
    WHC = DimArray(
        Array{T}(undef, nyears, patch_xdim, patch_ydim)u"mm",
        (year = years, x = 1:patch_xdim, y = 1:patch_ydim), name = :WHC)
    PWP = DimArray(
        Array{T}(undef, nyears, patch_xdim, patch_ydim)u"mm",
        (year = years, x = 1:patch_xdim, y = 1:patch_ydim), name = :PWP)
    nutrients = DimArray(
        Array{T}(undef, nyears, patch_xdim, patch_ydim),
        (year = years, x = 1:patch_xdim, y = 1:patch_ydim), name = :nutrients)
    patch_variables = (; WHC, PWP, nutrients)

    ############# Traits
    traits = (;
        amc = Array{T}(undef, nspecies),
        maxheight = Array{T}(undef, nspecies)u"m",
        lbp = Array{T}(undef, nspecies),
        lnc = Array{T}(undef, nspecies)u"mg/g",
        sla = Array{T}(undef, nspecies)u"m^2 / g",
        rsa = Array{T}(undef, nspecies)u"m^2 / g",
        abp = Array{T}(undef, nspecies))

    ############# Transfer function
    transfer_function = (;
        R_05 = Array{T}(undef, nspecies),
        x0 = Array{T}(undef, nspecies))

    max_height = 2.0u"m"
    Δheightlayer = 0.05u"m"
    nheight_layers = ceil(Int64, max_height / Δheightlayer)

    calc = (;
        com = CommunityLevel(),

        ############ preallaocated vectors that are used in the calculations
        LIG = Array{T}(undef, nspecies),
        growth_act = Array{T}(undef, nspecies)u"kg / ha",
        senescence = Array{T}(undef, nspecies)u"kg / ha",
        defoliation = Array{T}(undef, nspecies)u"kg / ha",
        species_specific_red = Array{T}(undef, nspecies),
        LAIs = Array{T}(undef, nspecies),
        height_gain = Array{T}(undef, nspecies)u"m",
        height_loss_mowing = Array{T}(undef, nspecies)u"m",
        height_loss_grazing = Array{T}(undef, nspecies)u"m",
        allocation_above = Array{T}(undef, nspecies),
        above_proportion = Array{T}(undef, nspecies),

        ## cut biomass
        species_mean_above_biomass = Array{T}(undef, nspecies)u"kg / ha",
        species_mean_actual_height = Array{T}(undef, nspecies)u"m",
        species_cut_biomass = Array{T}(undef, nspecies)u"kg / ha",

        ## functional response helper variables
        K_prep = Array{T}(undef, nspecies),
        denominator = Array{T}(undef, nspecies),

        ## helper variables for generation of traits
        traitmat = Matrix{T}(undef, 7, nspecies),
        amc_resid = Array{T}(undef, nspecies),
        rsa_resid = Array{T}(undef, nspecies),

        ## below ground competition
        nutrients_adj_factor = Array{T}(undef, nspecies),
        TS_biomass = Array{T}(undef, nspecies)u"kg / ha",
        TS = Array{T}(undef, nspecies, nspecies),

        ## height influence
        lais_heightinfluence = Array{T}(undef, nspecies),
        heightinfluence = Array{T}(undef, nspecies),
        relative_height = Array{T}(undef, nspecies)u"m",

        # leaf nitrogen (palatability) --> grazing
        relative_lnc = Array{T}(undef, nspecies)u"mg/g",
        lncinfluence = Array{T}(undef, nspecies),
        biomass_scaled = Array{T}(undef, nspecies)u"kg / ha",

        ## investment to roots
        ROOT = Array{T}(undef, nspecies),
        root_invest_srsa = Array{T}(undef, nspecies),
        root_invest_amc = Array{T}(undef, nspecies),

        ## nutrient reducer function
        nutrients_splitted = Array{T}(undef, nspecies),
        NUT = Array{T}(undef, nspecies),
        N_amc = Array{T}(undef, nspecies),
        N_rsa = Array{T}(undef, nspecies),

        ## water reducer function
        WAT = Array{T}(undef, nspecies),

        ## mowing and grazing
        feedible_biomass = Array{T}(undef, nspecies)u"kg / ha",
        mown_height = Array{T}(undef, nspecies)u"m",
        proportion_mown = Array{T}(undef, nspecies),
        grazed_share = Array{T}(undef, nspecies),
        mown = Array{T}(undef, nspecies)u"kg / ha",
        grazed = Array{T}(undef, nspecies)u"kg / ha",
        trampled = Array{T}(undef, nspecies)u"kg / ha",

        ## senescence
        senescence_rate = Array{T}(undef, nspecies),
        senescence_sla = Array{T}(undef, nspecies),

        ## height layers
        min_height_layer = collect(0.0u"m":Δheightlayer:nheight_layers*Δheightlayer-Δheightlayer),
        max_height_layer = collect(Δheightlayer:Δheightlayer:nheight_layers*Δheightlayer),
        LAIs_layer = Array{T}(undef, nspecies, nheight_layers),
        LAItot_layer = Array{T}(undef, nheight_layers),
        cumLAItot_above = Array{T}(undef, nheight_layers),
        Intensity_layer = Array{T}(undef, nheight_layers),
        fPAR_layer = Array{T}(undef, nspecies, nheight_layers)
    )

    return (; u, patch_variables, calc, traits, transfer_function, output)
end

@kwdef mutable struct CommunityLevel{T, Qkg_ha}
    LAItot::T = 0.0
    growth_pot_total::Qkg_ha = 0.0u"kg/ha"
    RUE_community_height::T = 1.0
    RAD::T = 1.0
    SEA::T = 1.0
    TEMP::T = 1.0
    SEN_season::T = 1.0
    fodder_supply::Qkg_ha = 0.0u"kg/ha"
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
