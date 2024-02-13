```@meta
CurrentModule = GrasslandTraitSim
```

# Model Parameter

## Simulation settings

| Parameter    | Description                                                                    | used in                    |
| ------------ | ------------------------------------------------------------------------------ | -------------------------- |
| `nspecies`   | number of species (plant functional types)                                     | -                          |
| `npatches`   | number of quadratic patches within one site                                    | -                          |
| `trait_seed` | seed for the generation of traits, if `missing` then seed is selected randomly | [`random_traits!`](@ref)   |
| `nutheterog` | heterogeneity of the nutrient availability within one site, only applicable if more than one patch is simulated per site | [`input_nutrients!`](@ref) |

## Calibrated parameter

| Parameter  | Description    | used in  | 
| ---------- | -------------- | -------- | 
| `α_sen` | α value of a linear equation that relate the leaf life span to the senescence rate | [`senescence_rate!`](@ref)  | 
| `sla_tr` | reference community weighted mean specific leaf area, if the community weighted mean specific leaf area is equal to `sla_tr` then transpiration will not increase or decrease | [`transpiration`](@ref) | 
| `sla_tr_exponent` | controls how strongly a community mean specific leaf area that deviates from `sla_tr` is affecting the transpiration  | [`transpiration`](@ref) | 
| `biomass_dens` | if the matrix multiplication between the trait similarity matrix and the biomass equals `biomass_dens` the available water and nutrients for growth are not in- or decreased | [`below_ground_competition!`](@ref) | 
| `belowground_density_efffect`| controls how strongly the available water and nutrients are in- or decreased if the matrix multiplication between the trait similarity matrix and the biomass of the species is above or below of `biomass_dens` | [`below_ground_competition!`](@ref) | 
| `height_strength` | controls how strongly taller plants gets more light for growth | [`height_influence!`](@ref) | 
| `leafnitrogen_graz_exp` | controls how strongly grazers prefer plant species with high leaf nitrogen content | [`grazing!`](@ref) |       |
| `grazing_half_factor` | total biomass  [kg ha⁻¹] when the daily consumption by grazers reaches half of their maximal consumption defined by κ $\cdot$ livestock density | [`grazing!`](@ref) | 
| `trampling_factor` | defines together with the height of the plants and the livestock density the proportion of biomass that is trampled $\cdot 10^{-3}$ [ha m⁻¹] | [`trampling!`](@ref) | 
| `mowing_mid_days` | number of days after a mowing event when the plants are grown back to half of their normal size | [`mowing!`](@ref) | 
| `δ_wrsa` | maximal reduction of the plant-available water linked to the trait root surface area / aboveground biomass | [`init_transfer_functions!`](@ref) | 
| `δ_sla` | maximal reduction of the plant-available water linked to the trait specific leaf area | [`init_transfer_functions!`](@ref) | 
| `δ_amc` | maximal reduction of the plant-available nutrients linked to the trait arbuscular mycorrhizal colonisation rate | [`init_transfer_functions!`](@ref) | 
| `δ_nrsa` | maximal reduction of the plant-available nutrients linked to the trait root surface area / aboveground biomass | [`init_transfer_functions!`](@ref) | 
| `β_sen` | slope of a linear equation that relates the leaf life span to the senescence rate |  [`senescence_rate!`](@ref)  | 
| `totalN_β` | slope parameter for total N in logistic function to calculate nutrient index | [`input_nutrients!`](@ref) |  |
| `CN_β` | slope parameter for the inverse of the CN ratio in logistic function to calculate nutrient index  | [`input_nutrients!`](@ref) |  |

## Fixed parameter

| Parameter  | Value | Description    | used in  | reference |
| ---------- | ------ | -------- | -------- | --------------------- |
| `mintotalN` | 0.0 [g kg⁻¹] | factor to rescale total N values | [`input_nutrients!`](@ref) | based on the minimum total N of ≈ 1.25 [g kg⁻¹] in the data from the Biodiversity Exploratories [explo14446v19](@cite)[explo18787v6](@cite)[explo23846v10](@cite)[explo31210v6](@cite)  |
| `maxtotalN` | 50.0 [g kg⁻¹] | factor to rescale total N values | [`input_nutrients!`](@ref) | based on the maximum total N of ≈ 30.63 [g kg⁻¹] in the data from the Biodiversity Exploratories [explo14446v19](@cite)[explo18787v6](@cite)[explo23846v10](@cite)[explo31210v6](@cite)   |
| `minCNratio` | 5.0 [-] | factor to rescale CN values | [`input_nutrients!`](@ref) | based on the minimum CN ratio of ≈ 9.05 [-] in the data from the Biodiversity Exploratories [explo14446v19](@cite)[explo18787v6](@cite)[explo23846v10](@cite)[explo31210v6](@cite)  |
| `maxCNratio` | 25.0 [-] | factor to rescale CN values | [`input_nutrients!`](@ref) | based on the maximum CN ratio of ≈ 13.60 [-] in the data from the Biodiversity Exploratories [explo14446v19](@cite)[explo18787v6](@cite)[explo23846v10](@cite)[explo31210v6](@cite)  |
| `α` | extinction coefficient | [`potential_growth!`](@ref) |  |
| `RUE_max` | maximum radiation use efficiency | [`potential_growth!`](@ref) |  |
| `γ1` |  | [`radiation_reduction`](@ref) |  |
| `γ2` |   | [`radiation_reduction`](@ref) |  |
| `T₀` |   | [`temperature_reduction`](@ref) |  |
| `T₁` |   | [`temperature_reduction`](@ref) |  |
| `T₂` |   | [`temperature_reduction`](@ref) |  |
| `T₃` |   | [`temperature_reduction`](@ref) |  |
| `PETₘₐₓ` |   | [`water_reduction!`](@ref) |  |
| `β₁` |   | [`water_reduction!`](@ref) |  |
| `β₂` |   | [`water_reduction!`](@ref) |  |
| `SEAₘᵢₙ` |   | [`seasonal_reduction`](@ref) |  |
| `SEAₘₐₓ` |   | [`seasonal_reduction`](@ref) |  |
| `ST₁` |   | [`seasonal_reduction`](@ref) |  |
| `ST₂` |   | [`seasonal_reduction`](@ref) |  |
| `SENₘᵢₙ` | | [`seasonal_component_senescence`](@ref) |  |
| `SENₘₐₓ` | | [`seasonal_component_senescence`](@ref) |  |
| `Ψ₁` | | [`seasonal_component_senescence`](@ref) |  |
| `Ψ₂` | | [`seasonal_component_senescence`](@ref) |  |
| `κ` | 22 [kg d⁻¹] | consumption of a livestock unit per day | [`grazing!`](@ref)  |  |

In addition, regression equation by [Reich1992](@cite) used to calculate the leaf life span from the specific leaf area (see [`senescence_rate!`](@ref)). Regression equation from [Gupta1979](@cite) used to derive
the water holding capacity and the permanent wilting point (see [`input_WHC_PWP!`](@ref))




## Scale parameter for calibration

| Parameter            | Description |
| -------------------- | ----------- |
| `b_biomass`          |             |
| `b_sla`              |             |
| `b_lncm`             |             |
| `b_amc`              |             |
| `b_height`           |             |
| `b_rsa_above`        |             |

