function preallocate_vectors(; input_obj)
    @unpack npatches, nspecies, patch_xdim, patch_ydim, ntimesteps = input_obj.simp
    @unpack initbiomass = input_obj.site

    dtype = Float64
    val = dtype(NaN)


    ############# output variables
    biomass = DimArray(
        fill(val, ntimesteps, npatches, nspecies)u"kg/ha",
        (time = input_obj.date, patch = 1:npatches, species = 1:nspecies),
        name = :biomass)
    mown_biomass = DimArray(
        fill(dtype(0.0), ntimesteps, npatches)u"kg/ha",
        (time = input_obj.date, patch = 1:npatches),
        name = :mown)
    grazed_biomass = DimArray(
        fill(dtype(0.0), ntimesteps, npatches)u"kg/ha",
        (time = input_obj.date, patch = 1:npatches),
        name = :grazed)
    water = DimArray(fill(val, ntimesteps, npatches)u"mm",
                     (time = input_obj.date, patch = 1:npatches),
                     name = :water)
    o = DimStack(biomass, mown_biomass, grazed_biomass, water)

    arraytuple = (;
        patch = (;
            xs = Array{Int64}(undef, npatches),
            ys = Array{Int64}(undef, npatches),
            WHC = fill(val, npatches)u"mm",
            PWP = fill(val, npatches)u"mm",
            nutrients = fill(val, npatches),
            nneighbours = fill(0, npatches),
            neighbours = Matrix{Union{Missing, Int64}}(undef, npatches, 4),
            surroundings = Matrix{Union{Missing, Int64}}(undef, npatches, 5),),
        traits = (;
            ## trait similarity matrix
            TS = fill(val, nspecies, nspecies),
            amc = Array{dtype}(undef, nspecies),
            height = fill(val, nspecies)u"m",
            lmpm = Array{dtype}(undef, nspecies),
            lncm = fill(val, nspecies)u"mg/g",
            sla = fill(val, nspecies)u"m^2 / g",
            rsa_above = fill(val, nspecies)u"m^2 / g",
            ampm = Array{dtype}(undef, nspecies),

            leaflifespan = fill(val, nspecies)u"d",
            μ = fill(val, nspecies)u"d^-1",
            ρ = Array{dtype}(undef, nspecies),),
        funresponse = (;
            amc_nut_upper = Array{dtype}(undef, nspecies),
            amc_nut_midpoint = Array{dtype}(undef, nspecies),
            rsa_above_water_upper = Array{dtype}(undef, nspecies),
            rsa_above_nut_upper = Array{dtype}(undef, nspecies),
            rsa_above_midpoint = Array{dtype}(undef, nspecies),
            sla_water_midpoint = Array{dtype}(undef, nspecies),),
        u = (;
            ############ vectors that store the state variables
            u_biomass = fill(val, npatches, nspecies)u"kg / ha",
            u_water = fill(val, npatches)u"mm",),
        du = (;
            ############ vectors that store the change of the state variables
            du_biomass = zeros(npatches, nspecies)u"kg / (ha * d)",
            # du_water = DimArray(zeros(npatches)u"mm / d", (:patch,)),

            du_water = zeros(npatches)u"mm / d",
            ),
        o = o,
        calc = (;
            negbiomass = fill(false, ntimesteps, npatches, nspecies),

            ############ preallaocated vectors that are used in the calculations
            potgrowth = fill(val, nspecies)u"kg / (ha * d)",
            act_growth = fill(val, nspecies)u"kg / (ha * d)",
            defoliation = fill(val, nspecies)u"kg / (ha * d)",
            sen = zeros(nspecies)u"kg / (ha * d)",
            species_specific_red = fill(val, nspecies),
            LAIs = fill(val, nspecies),
            biomass_per_patch = fill(val, npatches)u"kg / ha",
            relbiomass = fill(1.0, npatches),

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
            clonalgrowth = fill(val, npatches, nspecies)u"kg / ha",

            ## sla transpiration effect
            relative_sla = fill(val, nspecies)u"m^2 / g",),)

    return arraytuple
end
