function preallocate_vectors(; input_obj, T = Float64)
    @unpack output_date, mean_input_date, included, nspecies,
            patch_xdim, patch_ydim, ntimesteps = input_obj.simp
    @unpack initbiomass = input_obj.site

    ############# output variables
    #### State variables
    biomass = DimArray(
        Array{T}(undef, ntimesteps + 1, patch_xdim, patch_ydim, nspecies)u"kg/ha",
        (time = output_date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :state_biomass)
    water = DimArray(Array{T}(undef, ntimesteps + 1, patch_xdim, patch_ydim)u"mm",
        (time = output_date, x = 1:patch_xdim, y = 1:patch_ydim),
        name = :state_water)

    #### Species-specfic output variables
    mown = DimArray(
        Array{T}(undef, ntimesteps, patch_xdim, patch_ydim, nspecies)u"kg/ha",
        (time = mean_input_date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :mown)
    grazed = DimArray(
        Array{T}(undef, ntimesteps, patch_xdim, patch_ydim, nspecies)u"kg/ha",
        (time = mean_input_date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :grazed)
    trampled = DimArray(
        Array{T}(undef, ntimesteps, patch_xdim, patch_ydim, nspecies)u"kg/ha",
        (time = mean_input_date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :trampled)
    senescence = DimArray(
        Array{T}(undef, ntimesteps, patch_xdim, patch_ydim, nspecies)u"kg/ha",
        (time = mean_input_date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :senescence)
    act_growth = DimArray(
        Array{T}(undef, ntimesteps,  patch_xdim, patch_ydim, nspecies)u"kg/ha",
        (time = mean_input_date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :act_growth)
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

    #### Community-level output variables
    community_pot_growth = DimArray(
        Array{T}(undef, ntimesteps, patch_xdim, patch_ydim)u"kg/ha",
        (time = mean_input_date, x = 1:patch_xdim, y = 1:patch_ydim),
        name = :community_pot_growth)
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

    output = (; biomass, water, mown, grazed, trampled, senescence, community_pot_growth,
              act_growth, radiation_reducer, seasonal_growth, temperature_reducer,
              seasonal_senescence, light_growth, water_growth, nutrient_growth)

    ############# change and state variables
    du_biomass = DimArray(
        Array{T}(undef, patch_xdim, patch_ydim, nspecies)u"kg / ha",
        (x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :du_biomass)
    du_water = DimArray(
        Array{T}(undef, patch_xdim, patch_ydim)u"mm",
        (x = 1:patch_xdim, y = 1:patch_ydim), name = :du_water)
    u_biomass = DimArray(
        Array{T}(undef, patch_xdim, patch_ydim, nspecies)u"kg / ha",
        (x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :u_biomass)
    u_water = DimArray(
        Array{T}(undef, patch_xdim, patch_ydim)u"mm",
        (x = 1:patch_xdim, y = 1:patch_ydim),
        name = :u_water)
    u = (; du_biomass, du_water, u_biomass, u_water)

    ############# patch variables
    WHC = DimArray(
        Array{T}(undef, patch_xdim, patch_ydim)u"mm",
        (x = 1:patch_xdim, y = 1:patch_ydim), name = :WHC)
    PWP = DimArray(
        Array{T}(undef, patch_xdim, patch_ydim)u"mm",
        (x = 1:patch_xdim, y = 1:patch_ydim), name = :PWP)
    nutrients = DimArray(
        Array{T}(undef, patch_xdim, patch_ydim),
        (x = 1:patch_xdim, y = 1:patch_ydim), name = :nutrients)
    patch_variables = (; WHC, PWP, nutrients)

    ############# Traits
    traits = (;
        amc = Array{T}(undef, nspecies),
        height = Array{T}(undef, nspecies)u"m",
        lbp = Array{T}(undef, nspecies),
        lnc = Array{T}(undef, nspecies)u"mg/g",
        sla = Array{T}(undef, nspecies)u"m^2 / g",
        srsa = Array{T}(undef, nspecies)u"m^2 / g",
        abp = Array{T}(undef, nspecies))

    ############# Transfer function
    transfer_function = (;
        K_amc = Array{T}(undef, nspecies),
        A_amc = Array{T}(undef, nspecies),
        A_wrsa = Array{T}(undef, nspecies),
        A_nrsa = Array{T}(undef, nspecies),
        A_sla = Array{T}(undef, nspecies))

    global F = T

    calc = (;
        com = CommunityLevel1(),

        negbiomass = fill(false, ntimesteps + 1, patch_xdim, patch_ydim, nspecies),

        ############ preallaocated vectors that are used in the calculations
        light_competition = Array{T}(undef, nspecies),
        act_growth = Array{T}(undef, nspecies)u"kg / ha",
        senescence = Array{T}(undef, nspecies)u"kg / ha",
        defoliation = Array{T}(undef, nspecies)u"kg / ha",
        species_specific_red = Array{T}(undef, nspecies),
        LAIs = Array{T}(undef, nspecies),
        actual_height = Array{T}(undef, nspecies)u"m",
        above_biomass = Array{T}(undef, nspecies)u"kg / ha",

        ## cutted biomass
        species_mean_biomass = Array{T}(undef, nspecies)u"kg / ha",
        species_cut_biomass = Array{T}(undef, nspecies)u"kg / ha",

        ## functional response helper variables
        K_prep = Array{T}(undef, nspecies),
        denominator = Array{T}(undef, nspecies),

        ## helper variables for generation of traits
        traitmat = Matrix{T}(undef, 7, nspecies),
        amc_resid = Array{T}(undef, nspecies),
        rsa_above_resid = Array{T}(undef, nspecies),

        ## below ground competition
        biomass_density_factor = Array{T}(undef, nspecies),
        TS_biomass = Array{T}(undef, nspecies)u"kg / ha",

        ## height influence
        heightinfluence = Array{T}(undef, nspecies),
        relative_height = Array{T}(undef, nspecies)u"m",

        # leaf nitrogen (palatability) --> grazing
        relative_lnc = Array{T}(undef, nspecies)u"mg/g",
        ρ = Array{T}(undef, nspecies),
        height_ρ_biomass = Array{T}(undef, nspecies)u"m * kg / ha",

        ## investment to roots
        root_invest = Array{T}(undef, nspecies),
        root_invest_srsa = Array{T}(undef, nspecies),
        root_invest_amc = Array{T}(undef, nspecies),

        ## nutrient reducer function
        nutrients_splitted = Array{T}(undef, nspecies),
        Nutred = Array{T}(undef, nspecies),
        N_amc = Array{T}(undef, nspecies),
        N_rsa = Array{T}(undef, nspecies),

        ## water reducer function

        Waterred = Array{T}(undef, nspecies),
        W_sla = Array{T}(undef, nspecies),
        W_rsa = Array{T}(undef, nspecies),

        ## mowing, grazing, trampling
        mown_height = Array{T}(undef, nspecies)u"m",
        proportion_mown = Array{T}(undef, nspecies),
        grazed_share = Array{T}(undef, nspecies),
        height_scaled = Array{T}(undef, nspecies),
        trampled_share = Array{T}(undef, nspecies),
        mown = Array{T}(undef, nspecies)u"kg / ha",
        grazed = Array{T}(undef, nspecies)u"kg / ha",
        trampled = Array{T}(undef, nspecies)u"kg / ha",
        abp_scaled = Array{T}(undef, nspecies),

        ## clonal growth
        clonalgrowth = Array{T}(undef, patch_xdim, patch_ydim, nspecies)u"kg / ha",

        ## sla transpiration effect
        relative_sla = Array{T}(undef, nspecies)u"m^2 / g",

        ## based on traits
        leaflifespan = Array{T}(undef, nspecies)u"d",
        μ = Array{T}(undef, nspecies),
        TS = Array{T}(undef, nspecies, nspecies))

    global F = Float64

    return (; u, patch_variables, calc, traits, transfer_function, output)
end

@with_kw mutable struct CommunityLevel1{T, Q} @deftype T
    LAItot = F(0.0)
    potgrowth_total::Q = F(0.0) * u"kg/ha"
    comH_reduction = F(1.0)
    RAD = F(1.0)
    SEA = F(1.0)
    TEMP = F(1.0)
    SEN_season = F(1.0)
end

function preallocate_specific_vectors(; input_obj, T = Float64)
    biomass_cutting_t = Int64[]
    cutting_height = Float64[]
    biomass_cutting_t = Int64[]
    biomass_cutting_numeric_date = Float64[]
    biomass_cutting_index = Int64[]

    if haskey(input_obj, :output_validation)
        @unpack biomass_cutting_t, biomass_cutting_numeric_date,
                cutting_height, biomass_cutting_index,
                biomass_cutting_t = input_obj.output_validation
    end

    cut_biomass = fill(T(NaN), length(biomass_cutting_t))u"kg/ha"

    return (; valid = (; cut_biomass, biomass_cutting_t, biomass_cutting_numeric_date,
            cut_index = biomass_cutting_index,
            cutting_height = cutting_height))
end

# function preallocate(; input_obj, Tdiff = nothing)
#     normal = preallocate_vectors(; input_obj, T = Float64)

#     if isnothing(Tdiff)
#         return (; normal)
#     end

#     diff = preallocate_vectors(; input_obj, T = Tdiff)

#     return (; normal, diff)
# end

# function preallocate_specific(; input_obj, Tdiff = nothing)
#     normal = preallocate_specific_vectors(; input_obj, T = Float64)

#     if isnothing(Tdiff)
#         return (; normal)
#     end
#     diff = preallocate_specific_vectors(; input_obj, T = Tdiff)

#     return (; normal, diff)
# end


struct PreallocCache
    normal::Vector{Any}
    diff::Vector{Any}
end

function PreallocCache()
    return PreallocCache(fill(nothing, Threads.nthreads()), fill(nothing, Threads.nthreads()))
end

function get_buffer(buffer::PreallocCache, T, id; input_obj)
    if T <: ForwardDiff.Dual
        if isnothing(buffer.diff[id])
            buffer.diff[id] = preallocate_vectors(; input_obj, T)
        end

        return buffer.diff[id]

    elseif T <: Float64
        if isnothing(buffer.normal[id])
            buffer.normal[id] = preallocate_vectors(; input_obj, T)
        end

        return buffer.normal[id]
    end
end


struct PreallocPlotCache
    normal::Matrix{Any}
    diff::Matrix{Any}
end

function PreallocPlotCache(nplots)
    return PreallocPlotCache(fill(nothing, Threads.nthreads(), nplots),
                             fill(nothing, Threads.nthreads(), nplots))
end

function get_buffer(buffer::PreallocPlotCache, T, threadid, plotnum; input_obj)
    if T <: ForwardDiff.Dual
        if isnothing(buffer.diff[threadid, plotnum])
            buffer.diff[threadid, plotnum] = preallocate_specific_vectors(; input_obj, T)
        end

        return buffer.diff[threadid, plotnum]

    elseif T <: Float64
        if isnothing(buffer.normal[threadid, plotnum])
            buffer.normal[threadid, plotnum] = preallocate_specific_vectors(; input_obj, T)
        end

        return buffer.normal[threadid, plotnum]
    end
end