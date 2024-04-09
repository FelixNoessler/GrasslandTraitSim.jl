function preallocate_vectors(; input_obj, T = Float64)
    @unpack included, nspecies, patch_xdim, patch_ydim, ntimesteps = input_obj.simp
    @unpack initbiomass = input_obj.site

    ############# output variables
    biomass = DimArray(
        Array{T}(undef, ntimesteps, patch_xdim, patch_ydim, nspecies)u"kg/ha",
        (time = input_obj.date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :biomass)
    mown = DimArray(
        Array{T}(undef, ntimesteps, patch_xdim, patch_ydim, nspecies)u"kg/ha",
        (time = input_obj.date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :mown)
    grazed = DimArray(
        Array{T}(undef, ntimesteps, patch_xdim, patch_ydim, nspecies)u"kg/ha",
        (time = input_obj.date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :grazed)
    water = DimArray(Array{T}(undef, ntimesteps, patch_xdim, patch_ydim)u"mm",
                     (time = input_obj.date, x = 1:patch_xdim, y = 1:patch_ydim),
                     name = :water)
    output = (; biomass, mown, grazed, water)

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
        lmpm = Array{T}(undef, nspecies),
        lncm = Array{T}(undef, nspecies)u"mg/g",
        sla = Array{T}(undef, nspecies)u"m^2 / g",
        rsa_above = Array{T}(undef, nspecies)u"m^2 / g",
        ampm = Array{T}(undef, nspecies))

    ############# Transfer function
    transfer_function = (;
        K_amc = Array{T}(undef, nspecies),
        A_amc = Array{T}(undef, nspecies),
        K_wrsa = Array{T}(undef, nspecies),
        K_nrsa = Array{T}(undef, nspecies),
        A_wrsa = Array{T}(undef, nspecies),
        A_nrsa = Array{T}(undef, nspecies),
        A_sla = Array{T}(undef, nspecies))

    calc = (;
        com = CommunityLevel(),

        negbiomass = fill(false, ntimesteps, patch_xdim, patch_ydim, nspecies),

        ############ preallaocated vectors that are used in the calculations
        light_competition = Array{T}(undef, nspecies),
        act_growth = Array{T}(undef, nspecies)u"kg / ha",
        senescence = Array{T}(undef, nspecies)u"kg / ha",
        defoliation = Array{T}(undef, nspecies)u"kg / ha",
        species_specific_red = Array{T}(undef, nspecies),
        LAIs = Array{T}(undef, nspecies),
        lowbiomass_correction = Array{T}(undef, nspecies),

        ## cutted biomass
        mean_biomass = Array{T}(undef, nspecies)u"kg / ha",
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
        relative_lncm = Array{T}(undef, nspecies)u"mg/g",
        ρ = Array{T}(undef, nspecies),
        low_ρ_biomass = Array{T}(undef, nspecies)u"kg / ha",

        ## nutrient reducer function
        nutrients_splitted = Array{T}(undef, nspecies),
        Nutred = Array{T}(undef, nspecies),
        N_amc = Array{T}(undef, nspecies),
        N_rsa = Array{T}(undef, nspecies),

        ## water reducer function
        W_p = Array{T}(undef, nspecies),
        Waterred = Array{T}(undef, nspecies),
        W_sla = Array{T}(undef, nspecies),
        W_rsa = Array{T}(undef, nspecies),

        ## mowing, grazing, trampling
        mown_height = Array{T}(undef, nspecies)u"m",
        proportion_mown = Array{T}(undef, nspecies),
        grazed_share = Array{T}(undef, nspecies),
        trampled_biomass = Array{T}(undef, nspecies)u"kg / ha",
        trampled_share = Array{T}(undef, nspecies),

        ## clonal growth
        clonalgrowth = Array{T}(undef, patch_xdim, patch_ydim, nspecies)u"kg / ha",

        ## sla transpiration effect
        relative_sla = Array{T}(undef, nspecies)u"m^2 / g",

        ## based on traits
        leaflifespan = Array{T}(undef, nspecies)u"d",
        μ = Array{T}(undef, nspecies),
        TS = Array{T}(undef, nspecies, nspecies))

    return (; u, patch_variables, calc, traits, transfer_function, output)
end

@with_kw mutable struct CommunityLevel{T, Q} @deftype T
    LAItot = 0.0
    potgrowth_total::Q = 0.0u"kg/ha"
    comH_reduction = 1.0
    RAD = 1.0
    SEA = 1.0
    TEMP = 1.0
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

function preallocate(; input_obj, Tdiff = nothing)
    normal = preallocate_vectors(; input_obj, T = Float64)

    if isnothing(Tdiff)
        return (; normal)
    end

    diff = preallocate_vectors(; input_obj, T = Tdiff)

    return (; normal, diff)
end

function preallocate_specific(; input_obj, Tdiff = nothing)
    normal = preallocate_specific_vectors(; input_obj, T = Float64)

    if isnothing(Tdiff)
        return (; normal)
    end
    diff = preallocate_specific_vectors(; input_obj, T = Tdiff)

    return (; normal, diff)
end


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
