# struct SimulationObject
#     simp
#     output
#     u
#     patch_variables
#     traits
#     transfer_function
#     calc

#     function SimulationObject(; input_obj, dtype = Float64)
#         @unpack nspecies, patch_xdim, patch_ydim, ntimesteps = input_obj.simp

#         simp = input_obj.simp
#         output = Output(input_obj = input_obj, dtype = dtype)
#         u = StateVariables(input_obj = input_obj, dtype = dtype)
#         patch_variables = PatchVariables(input_obj = input_obj, dtype = dtype)
#         traits = Traits(input_obj = input_obj, dtype = dtype)
#         transfer_function = TransferFunction(nspecies = nspecies, dtype = dtype)
#         calc = Calculation(input_obj = input_obj, dtype = dtype)

#         return new(simp, output, u, patch_variables, traits,
#                    transfer_function, calc)
#     end
# end

# Base.broadcastable(x::SimulationObject7) = Ref(x)

# struct Output
#     biomass
#     mown
#     grazed
#     water
#     cutted_biomass

#     function Output(; input_obj, dtype = Float64)
#         @unpack nspecies, patch_xdim, patch_ydim, ntimesteps = input_obj.simp
#         @unpack biomass_cutting_t = input_obj.output_validation

#         val = dtype(NaN)

#         biomass = DimArray(
#             fill(val, ntimesteps, patch_xdim, patch_ydim, nspecies)u"kg/ha",
#             (time = input_obj.date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
#             name = :biomass)
#         mown = DimArray(
#             fill(val, ntimesteps, patch_xdim, patch_ydim, nspecies)u"kg/ha",
#             (time = input_obj.date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
#             name = :mown)
#         grazed = DimArray(
#             fill(val, ntimesteps, patch_xdim, patch_ydim, nspecies)u"kg/ha",
#             (time = input_obj.date, x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
#             name = :grazed)
#         water = DimArray(fill(val, ntimesteps, patch_xdim, patch_ydim)u"mm",
#                             (time = input_obj.date, x = 1:patch_xdim, y = 1:patch_ydim),
#                             name = :water)
#         cutted_biomass = DimArray(
#             fill(val, length(biomass_cutting_t))u"kg/ha",
#             (; t = biomass_cutting_t),
#             name = :cutted_biomass)

#         return new(biomass, mown, grazed, water,
#                    cutted_biomass)
#     end
# end


# struct StateVariables
#     u_biomass
#     u_water
#     du_biomass
#     du_water

#     function StateVariables(; input_obj, dtype = Float64)
#         @unpack patch_xdim, patch_ydim, nspecies = input_obj.simp

#         val = dtype(NaN)

#         du_biomass = DimArray(
#             fill(val, patch_xdim, patch_ydim, nspecies)u"kg / (ha * d)",
#             (x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
#             name = :du_biomass)
#         du_water = DimArray(
#             fill(val, patch_xdim, patch_ydim)u"mm / d",
#             (x = 1:patch_xdim, y = 1:patch_ydim), name = :du_water)
#         u_biomass = DimArray(
#             fill(val, patch_xdim, patch_ydim, nspecies)u"kg / ha",
#             (x = 1:patch_xdim, y = 1:patch_ydim, species = 1:nspecies),
#             name = :u_biomass)
#         u_water = DimArray(
#             fill(val, patch_xdim, patch_ydim)u"mm",
#             (x = 1:patch_xdim, y = 1:patch_ydim),
#             name = :u_water)

#         return new(u_biomass, u_water, du_biomass, du_water)
#     end
# end


# struct PatchVariables
#     WHC
#     PWP
#     nutrients

#     function PatchVariables(; input_obj, dtype = Float64)
#         @unpack patch_xdim, patch_ydim = input_obj.simp

#         val = dtype(NaN)

#         WHC = DimArray(
#             fill(val, patch_xdim, patch_ydim,)u"mm",
#             (x = 1:patch_xdim, y = 1:patch_ydim), name = :WHC)
#         PWP = DimArray(
#             fill(val, patch_xdim, patch_ydim,)u"mm",
#             (x = 1:patch_xdim, y = 1:patch_ydim), name = :PWP)
#         nutrients = DimArray(
#             fill(val, patch_xdim, patch_ydim),
#             (x = 1:patch_xdim, y = 1:patch_ydim), name = :nutrients)

#         return new(WHC, PWP, nutrients)
#     end
# end


# struct Traits
#     amc
#     height
#     lmpm
#     lncm
#     sla
#     rsa_above
#     ampm
#     leaflifespan
#     μ
#     TS

#     function Traits(; input_obj, dtype = Float64)
#         @unpack nspecies = input_obj.simp

#         val = dtype(NaN)

#         amc = Array{dtype}(undef, nspecies)
#         height = fill(val, nspecies)u"m"
#         lmpm = Array{dtype}(undef, nspecies)
#         lncm = fill(val, nspecies)u"mg/g"
#         sla = fill(val, nspecies)u"m^2 / g"
#         rsa_above = fill(val, nspecies)u"m^2 / g"
#         ampm = Array{dtype}(undef, nspecies)
#         leaflifespan = fill(val, nspecies)u"d"
#         μ = fill(val, nspecies)u"d^-1"
#         TS = fill(val, nspecies, nspecies)

#         return new(amc, height, lmpm, lncm, sla, rsa_above, ampm, leaflifespan, μ, TS)
#     end
# end

# struct TransferFunction
#     K_amc
#     H_amc
#     K_wrsa
#     K_nrsa
#     H_rsa
#     H_sla

#     function TransferFunction(; nspecies, dtype = Float64)
#         val = dtype(NaN)

#         K_amc = Array{dtype}(undef, nspecies)
#         H_amc = Array{dtype}(undef, nspecies)
#         K_wrsa = Array{dtype}(undef, nspecies)
#         K_nrsa = Array{dtype}(undef, nspecies)
#         H_rsa = Array{dtype}(undef, nspecies)
#         H_sla = Array{dtype}(undef, nspecies)

#         return new(K_amc, H_amc, K_wrsa, K_nrsa, H_rsa, H_sla)
#     end
# end


# struct Calculation
#     negbiomass

#     potgrowth
#     act_growth
#     defoliation
#     sen
#     species_specific_red
#     LAIs
#     biomass_per_patch
#     relbiomass

#     very_low_biomass
#     nan_biomass
#     neg_act_growth

#     K_prep
#     denominator

#     traitmat
#     similarity_matprep
#     amc_resid
#     rsa_above_resid

#     biomass_density_factor
#     TS_biomass

#     heightinfluence
#     relative_height

#     relative_lncm
#     ρ

#     nutrients_splitted
#     Nutred
#     amc_nut
#     rsa_above_nut

#     Wp
#     Waterred
#     W_sla
#     W_rsa

#     mown_height
#     mowing_λ

#     biomass_ρ
#     grazed_share

#     trampling_proportion
#     trampled_biomass

#     clonalgrowth

#     relative_sla

#     function Calculation(; input_obj, dtype = Float64)
#         @unpack nspecies, patch_xdim, patch_ydim, ntimesteps = input_obj.simp

#         val = dtype(NaN)

#         negbiomass = fill(false, ntimesteps, patch_xdim, patch_ydim, nspecies)

#         potgrowth = fill(val, nspecies)u"kg / (ha * d)"
#         act_growth = fill(val, nspecies)u"kg / (ha * d)"
#         defoliation = fill(val, nspecies)u"kg / (ha * d)"
#         sen = zeros(nspecies)u"kg / (ha * d)"
#         species_specific_red = fill(val, nspecies)
#         LAIs = fill(val, nspecies)
#         biomass_per_patch = fill(val, patch_xdim, patch_ydim)u"kg / ha"
#         relbiomass = fill(1.0, patch_xdim, patch_ydim)

#         very_low_biomass = fill(false, nspecies)
#         nan_biomass = fill(false, nspecies)
#         neg_act_growth = fill(false, nspecies)

#         K_prep = Array{dtype}(undef, nspecies)
#         denominator = Array{dtype}(undef, nspecies)

#         traitmat = Matrix{dtype}(undef, 7, nspecies)
#         similarity_matprep = Array{dtype}(undef, nspecies, nspecies)
#         amc_resid = Array{dtype}(undef, nspecies)
#         rsa_above_resid = Array{dtype}(undef, nspecies)

#         biomass_density_factor = fill(val, nspecies)
#         TS_biomass = fill(val, nspecies)u"kg / ha"

#         heightinfluence = fill(val, nspecies)
#         relative_height = fill(val, nspecies)u"m"

#         relative_lncm = fill(val, nspecies)u"mg/g"
#         ρ = Array{dtype}(undef, nspecies)

#         nutrients_splitted = fill(val, nspecies)
#         Nutred = fill(val, nspecies)
#         amc_nut = fill(val, nspecies)
#         rsa_above_nut = fill(val, nspecies)

#         Wp = fill(val, nspecies)
#         Waterred = fill(val, nspecies)
#         W_sla = fill(val, nspecies)
#         W_rsa = fill(val, nspecies)

#         mown_height = fill(val, nspecies)u"m"
#         mowing_λ = fill(val, nspecies)

#         biomass_ρ = fill(val, nspecies)u"kg / ha"
#         grazed_share = fill(val, nspecies)

#         trampling_proportion = fill(val, nspecies)
#         trampled_biomass = fill(val, nspecies)u"kg / ha"

#         clonalgrowth = fill(val, patch_xdim, patch_ydim, nspecies)u"kg / ha"
#         relative_sla = fill(val, nspecies)u"m^2 / g"

#         new(negbiomass, potgrowth, act_growth, defoliation, sen, species_specific_red,
#             LAIs, biomass_per_patch, relbiomass, very_low_biomass, nan_biomass,
#             neg_act_growth, K_prep, denominator, traitmat, similarity_matprep,
#             amc_resid, rsa_above_resid, biomass_density_factor, TS_biomass,
#             heightinfluence, relative_height, relative_lncm, ρ, nutrients_splitted,
#             Nutred, amc_nut, rsa_above_nut, Wp, Waterred, W_sla, W_rsa, mown_height,
#             mowing_λ, biomass_ρ, grazed_share, trampling_proportion, trampled_biomass,
#             clonalgrowth, relative_sla)

#     end
# end
