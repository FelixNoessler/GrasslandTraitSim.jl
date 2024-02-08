function preallocate_vectors(; input_obj, T = Float64)
    @unpack nspecies, patch_xdim, patch_ydim, ntimesteps = input_obj.simp
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
        Array{T}(undef, patch_xdim, patch_ydim, nspecies)u"kg / (ha * d)",
        (x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :du_biomass)
    du_water = DimArray(
        Array{T}(undef, patch_xdim, patch_ydim)u"mm / d",
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
        ampm = Array{T}(undef, nspecies),
        leaflifespan = Array{T}(undef, nspecies)u"d",
        μ = Array{T}(undef, nspecies)u"d^-1",
        TS = Array{T}(undef, nspecies, nspecies))

    ############# Transfer function
    transfer_function = (;
        K_amc = Array{T}(undef, nspecies),
        H_amc = Array{T}(undef, nspecies),
        K_wrsa = Array{T}(undef, nspecies),
        K_nrsa = Array{T}(undef, nspecies),
        H_rsa = Array{T}(undef, nspecies),
        H_sla = Array{T}(undef, nspecies))


    calc = (;
        negbiomass = fill(false, ntimesteps, patch_xdim, patch_ydim, nspecies),

        ############ preallaocated vectors that are used in the calculations
        potgrowth = Array{T}(undef, nspecies)u"kg / (ha * d)",
        act_growth = Array{T}(undef, nspecies)u"kg / (ha * d)",
        defoliation = Array{T}(undef, nspecies)u"kg / (ha * d)",
        sen = zeros(T, nspecies)u"kg / (ha * d)",
        species_specific_red = Array{T}(undef, nspecies),
        LAIs = Array{T}(undef, nspecies),
        biomass_per_patch = Array{T}(undef, patch_xdim, patch_ydim)u"kg / ha",
        relbiomass = Array{T}(undef, patch_xdim, patch_ydim),

        ## warnings, debugging, avoid numerical errors
        very_low_biomass = fill(false, nspecies),
        nan_biomass = fill(false, nspecies),
        neg_act_growth = fill(false, nspecies),

        ## cutted biomass
        mean_biomass = Array{T}(undef, nspecies)u"kg / ha",
        species_cutted_biomass = Array{T}(undef, nspecies)u"kg / ha",

        ## functional response helper variables
        K_prep = Array{T}(undef, nspecies),
        denominator = Array{T}(undef, nspecies),

        ## helper variables for generation of traits
        traitmat = Matrix{T}(undef, 7, nspecies),
        similarity_matprep = Array{T}(undef, nspecies, nspecies),
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

        ## nutrient reducer function
        nutrients_splitted = Array{T}(undef, nspecies),
        Nutred = Array{T}(undef, nspecies),
        amc_nut = Array{T}(undef, nspecies),
        rsa_above_nut = Array{T}(undef, nspecies),

        ## water reducer function
        Wp = Array{T}(undef, nspecies),
        Waterred = Array{T}(undef, nspecies),
        W_sla = Array{T}(undef, nspecies),
        W_rsa = Array{T}(undef, nspecies),

        ## mowing, grazing, trampling
        mown_height = Array{T}(undef, nspecies)u"m",
        proportion_mown = Array{T}(undef, nspecies),
        grazed_share = Array{T}(undef, nspecies),
        trampling_proportion = Array{T}(undef, nspecies),
        trampled_biomass = Array{T}(undef, nspecies)u"kg / ha",

        ## clonal growth
        clonalgrowth = Array{T}(undef, patch_xdim, patch_ydim, nspecies)u"kg / ha",

        ## sla transpiration effect
        relative_sla = Array{T}(undef, nspecies)u"m^2 / g")

    return (; u, patch_variables, calc, traits, transfer_function, output)
end
