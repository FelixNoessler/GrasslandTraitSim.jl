function preallocate_vectors(; input_obj, dtype = Float64)
    @unpack nspecies, patch_xdim, patch_ydim, ntimesteps = input_obj.simp
    @unpack initbiomass = input_obj.site

    val = dtype(NaN)

    ############# output variables
    biomass = DimArray(
        fill(val, ntimesteps, patch_xdim, patch_ydim, nspecies)u"kg/ha",
        (time = input_obj.date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :biomass)
    mown = DimArray(
        fill(val, ntimesteps, patch_xdim, patch_ydim, nspecies)u"kg/ha",
        (time = input_obj.date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :mown)
    grazed = DimArray(
        fill(val, ntimesteps, patch_xdim, patch_ydim, nspecies)u"kg/ha",
        (time = input_obj.date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :grazed)
    water = DimArray(fill(val, ntimesteps, patch_xdim, patch_ydim)u"mm",
                     (time = input_obj.date, x = 1:patch_xdim, y = 1:patch_ydim),
                     name = :water)

    ############# change and state variables
    du_biomass = DimArray(
        fill(val, patch_xdim, patch_ydim, nspecies)u"kg / (ha * d)",
        (x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :du_biomass)
    du_water = DimArray(
        fill(val, patch_xdim, patch_ydim)u"mm / d",
        (x = 1:patch_xdim, y = 1:patch_ydim), name = :du_water)
    u_biomass = DimArray(
        fill(val, patch_xdim, patch_ydim, nspecies)u"kg / ha",
        (x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
        name = :u_biomass)
    u_water = DimArray(
        fill(val, patch_xdim, patch_ydim)u"mm",
        (x = 1:patch_xdim, y = 1:patch_ydim),
        name = :u_water)

    ############# patch variables
    WHC = DimArray(
        fill(val, patch_xdim, patch_ydim,)u"mm",
        (x = 1:patch_xdim, y = 1:patch_ydim), name = :WHC)
    PWP = DimArray(
        fill(val, patch_xdim, patch_ydim,)u"mm",
        (x = 1:patch_xdim, y = 1:patch_ydim), name = :PWP)
    nutrients = DimArray(
        fill(val, patch_xdim, patch_ydim),
        (x = 1:patch_xdim, y = 1:patch_ydim), name = :nutrients)


    u = (; biomass, mown, grazed, water, du_biomass, du_water,
                 u_biomass, u_water, WHC, PWP, nutrients)

    arraytuple = (;
        u = u,
        traits = (;
            amc = Array{dtype}(undef, nspecies),
            height = fill(val, nspecies)u"m",
            lmpm = Array{dtype}(undef, nspecies),
            lncm = fill(val, nspecies)u"mg/g",
            sla = fill(val, nspecies)u"m^2 / g",
            rsa_above = fill(val, nspecies)u"m^2 / g",
            ampm = Array{dtype}(undef, nspecies),
            leaflifespan = fill(val, nspecies)u"d",
            μ = fill(val, nspecies)u"d^-1",
            TS = fill(val, nspecies, nspecies),),
        funresponse = (;
            amc_nut_upper = Array{dtype}(undef, nspecies),
            amc_nut_midpoint = Array{dtype}(undef, nspecies),
            rsa_above_water_upper = Array{dtype}(undef, nspecies),
            rsa_above_nut_upper = Array{dtype}(undef, nspecies),
            rsa_above_midpoint = Array{dtype}(undef, nspecies),
            sla_water_midpoint = Array{dtype}(undef, nspecies),),
        calc = (;
            negbiomass = fill(false, ntimesteps, patch_xdim, patch_ydim, nspecies),

            ############ preallaocated vectors that are used in the calculations
            potgrowth = fill(val, nspecies)u"kg / (ha * d)",
            act_growth = fill(val, nspecies)u"kg / (ha * d)",
            defoliation = fill(val, nspecies)u"kg / (ha * d)",
            sen = zeros(nspecies)u"kg / (ha * d)",
            species_specific_red = fill(val, nspecies),
            LAIs = fill(val, nspecies),
            biomass_per_patch = fill(val, patch_xdim, patch_ydim)u"kg / ha",
            relbiomass = fill(1.0, patch_xdim, patch_ydim),

            ## warnings, debugging, avoid numerical errors
            very_low_biomass = fill(false, nspecies),
            nan_biomass = fill(false, nspecies),
            neg_act_growth = fill(false, nspecies),

            ## functional response helper variables
            K_prep = Array{dtype}(undef, nspecies),
            denominator = Array{dtype}(undef, nspecies),

            ## helper variables for generation of traits
            traitmat = Matrix{dtype}(undef, 7, nspecies),
            similarity_matprep = Array{dtype}(undef, nspecies, nspecies),
            amc_resid = Array{dtype}(undef, nspecies),
            rsa_above_resid = Array{dtype}(undef, nspecies),

            ## helper variables for patch input
            nutgradient = Matrix{dtype}(undef, patch_xdim, patch_ydim),

            ## below ground competition
            biomass_density_factor = fill(val, nspecies),
            TS_biomass = fill(val, nspecies)u"kg / ha",

            ## height influence
            heightinfluence = fill(val, nspecies),
            relative_height = fill(val, nspecies)u"m",

            # leaf nitrogen (palatability) --> grazing
            relative_lncm = fill(val, nspecies)u"mg/g",
            ρ = Array{dtype}(undef, nspecies),

            ## nutrient reducer function
            nutrients_splitted = fill(val, nspecies),
            Nutred = fill(val, nspecies),
            amc_nut = fill(val, nspecies),
            rsa_above_nut = fill(val, nspecies),

            ## water reducer function
            water_splitted = fill(val, nspecies),
            Waterred = fill(val, nspecies),
            sla_water = fill(val, nspecies),
            rsa_above_water = fill(val, nspecies),

            ## mowing
            mown_height = fill(val, nspecies)u"m",
            mowing_λ = fill(val, nspecies),

            ## grazing
            biomass_ρ = fill(val, nspecies)u"kg / ha",
            grazed_share = fill(val, nspecies),

            ## trampling
            trampling_proportion = fill(val, nspecies),
            trampled_biomass = fill(val, nspecies)u"kg / ha",

            ## clonal growth
            clonalgrowth = fill(val, patch_xdim, patch_ydim, nspecies)u"kg / ha",

            ## sla transpiration effect
            relative_sla = fill(val, nspecies)u"m^2 / g",))

    return arraytuple
end
