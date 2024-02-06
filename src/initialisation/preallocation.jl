function preallocate_vectors(; input_obj, T = Float64)
    @unpack nspecies, patch_xdim, patch_ydim, ntimesteps = input_obj.simp
    @unpack initbiomass = input_obj.site
    TNaN = T(NaN)

    ############# output variables
    biomass = DimArray(
        fill(TNaN, ntimesteps, patch_xdim, patch_ydim, nspecies)u"kg/ha",
        (time = input_obj.date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :biomass)
    mown = DimArray(
        fill(TNaN, ntimesteps, patch_xdim, patch_ydim, nspecies)u"kg/ha",
        (time = input_obj.date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :mown)
    grazed = DimArray(
        fill(TNaN, ntimesteps, patch_xdim, patch_ydim, nspecies)u"kg/ha",
        (time = input_obj.date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :grazed)
    water = DimArray(fill(TNaN, ntimesteps, patch_xdim, patch_ydim)u"mm",
                     (time = input_obj.date, x = 1:patch_xdim, y = 1:patch_ydim),
                     name = :water)
    output = (; biomass, mown, grazed, water)

    ############# change and state variables
    du_biomass = DimArray(
        fill(TNaN, patch_xdim, patch_ydim, nspecies)u"kg / (ha * d)",
        (x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :du_biomass)
    du_water = DimArray(
        fill(TNaN, patch_xdim, patch_ydim)u"mm / d",
        (x = 1:patch_xdim, y = 1:patch_ydim), name = :du_water)
    u_biomass = DimArray(
        fill(TNaN, patch_xdim, patch_ydim, nspecies)u"kg / ha",
        (x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :u_biomass)
    u_water = DimArray(
        fill(TNaN, patch_xdim, patch_ydim)u"mm",
        (x = 1:patch_xdim, y = 1:patch_ydim),
        name = :u_water)
    u = (; du_biomass, du_water, u_biomass, u_water)

    ############# patch variables
    WHC = DimArray(
        fill(TNaN, patch_xdim, patch_ydim,)u"mm",
        (x = 1:patch_xdim, y = 1:patch_ydim), name = :WHC)
    PWP = DimArray(
        fill(TNaN, patch_xdim, patch_ydim,)u"mm",
        (x = 1:patch_xdim, y = 1:patch_ydim), name = :PWP)
    nutrients = DimArray(
        fill(TNaN, patch_xdim, patch_ydim),
        (x = 1:patch_xdim, y = 1:patch_ydim), name = :nutrients)
    patch_variables = (; WHC, PWP, nutrients)

    ############# Traits
    traits = (;
        amc = Array{T}(undef, nspecies),
        height = fill(TNaN, nspecies)u"m",
        lmpm = Array{T}(undef, nspecies),
        lncm = fill(TNaN, nspecies)u"mg/g",
        sla = fill(TNaN, nspecies)u"m^2 / g",
        rsa_above = fill(TNaN, nspecies)u"m^2 / g",
        ampm = Array{T}(undef, nspecies),
        leaflifespan = fill(TNaN, nspecies)u"d",
        μ = fill(TNaN, nspecies)u"d^-1",
        TS = fill(TNaN, nspecies, nspecies))

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
        potgrowth = fill(TNaN, nspecies)u"kg / (ha * d)",
        act_growth = fill(TNaN, nspecies)u"kg / (ha * d)",
        defoliation = fill(TNaN, nspecies)u"kg / (ha * d)",
        sen = zeros(T, nspecies)u"kg / (ha * d)",
        species_specific_red = fill(TNaN, nspecies),
        LAIs = fill(TNaN, nspecies),
        biomass_per_patch = fill(TNaN, patch_xdim, patch_ydim)u"kg / ha",
        relbiomass = fill(1.0, patch_xdim, patch_ydim),

        ## warnings, debugging, avoid numerical errors
        very_low_biomass = fill(false, nspecies),
        nan_biomass = fill(false, nspecies),
        neg_act_growth = fill(false, nspecies),

        ## cutted biomass
        mean_biomass = fill(TNaN, nspecies)u"kg / ha",
        species_cutted_biomass = fill(TNaN, nspecies)u"kg / ha",

        ## functional response helper variables
        K_prep = Array{T}(undef, nspecies),
        denominator = Array{T}(undef, nspecies),

        ## helper variables for generation of traits
        traitmat = Matrix{T}(undef, 7, nspecies),
        similarity_matprep = Array{T}(undef, nspecies, nspecies),
        amc_resid = Array{T}(undef, nspecies),
        rsa_above_resid = Array{T}(undef, nspecies),

        ## below ground competition
        biomass_density_factor = fill(TNaN, nspecies),
        TS_biomass = fill(TNaN, nspecies)u"kg / ha",

        ## height influence
        heightinfluence = fill(TNaN, nspecies),
        relative_height = fill(TNaN, nspecies)u"m",

        # leaf nitrogen (palatability) --> grazing
        relative_lncm = fill(TNaN, nspecies)u"mg/g",
        ρ = Array{T}(undef, nspecies),

        ## nutrient reducer function
        nutrients_splitted = fill(TNaN, nspecies),
        Nutred = fill(TNaN, nspecies),
        amc_nut = fill(TNaN, nspecies),
        rsa_above_nut = fill(TNaN, nspecies),

        ## water reducer function
        Wp = fill(TNaN, nspecies),
        Waterred = fill(TNaN, nspecies),
        W_sla = fill(TNaN, nspecies),
        W_rsa = fill(TNaN, nspecies),

        ## mowing, grazing, trampling
        mown_height = fill(TNaN, nspecies)u"m",
        proportion_mown = fill(TNaN, nspecies),
        grazed_share = fill(TNaN, nspecies),
        trampling_proportion = fill(TNaN, nspecies),
        trampled_biomass = fill(TNaN, nspecies)u"kg / ha",

        ## clonal growth
        clonalgrowth = fill(TNaN, patch_xdim, patch_ydim, nspecies)u"kg / ha",

        ## sla transpiration effect
        relative_sla = fill(TNaN, nspecies)u"m^2 / g")

    return (; u, patch_variables, calc, traits, transfer_function, output)
end
