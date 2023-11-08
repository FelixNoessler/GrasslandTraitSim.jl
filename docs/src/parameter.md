```@meta
CurrentModule = GrasslandTraitSim
```

# Model Parameter

| Parameter                     | Description                                 | used in                             | calibrated, reference |
| ----------------------------- | ------------------------------------------- | ----------------------------------- | --------------------- |
| `nspecies`                    | number of species (plant functional types)  | e.g. [`random_traits!`](@ref)       | fixed                 |
| `npatches`                    | number of quadratic patches within one site |                                     | fixed                 |
| `mintotal_N`  |   | [`input_nutrients!`](@ref) | fixed |
| `maxtotal_N`  |   | [`input_nutrients!`](@ref) | fixed |
| `minCN_ratio`  |  | [`input_nutrients!`](@ref) | fixed |
| `maxCN_ratio`  |  | [`input_nutrients!`](@ref) | fixed |
| `totalN_β`  |     | [`input_nutrients!`](@ref) | fixed |
| `CN_β`  |         | [`input_nutrients!`](@ref) | fixed |
| `nutheterog`  |   | [`input_nutrients!`](@ref) | fixed |
| `α`  |  extinction coefficient | [`potential_growth!`](@ref) | fixed |
| `RUE_max`  | maximum radiation use efficiency  | [`potential_growth!`](@ref) | fixed |
| `γ1`  |  | [`radiation_reduction`](@ref) | fixed |
| `γ2`  |   | [`radiation_reduction`](@ref) | fixed |
| `T₀`  |   | [`temperature_reduction`](@ref) | fixed |
| `T₁`  |   | [`temperature_reduction`](@ref) | fixed |
| `T₂`  |   | [`temperature_reduction`](@ref) | fixed |
| `T₃`  |   | [`temperature_reduction`](@ref) | fixed |
| `PETₘₐₓ`  |   | [`water_reduction!`](@ref) | fixed |
| `β₁`  |   | [`water_reduction!`](@ref) | fixed |
| `β₂`  |   | [`water_reduction!`](@ref) | fixed |
| `SEAₘᵢₙ`  |   | [`seasonal_reduction`](@ref) | fixed |
| `SEAₘₐₓ`  |   | [`seasonal_reduction`](@ref) | fixed |
| `ST₁`  |   | [`seasonal_reduction`](@ref) | fixed |
| `ST₂`  |   | [`seasonal_reduction`](@ref) | fixed |
| `sen_α` | α value of a linear equation that relate the leaf life span to the senescence rate | [`senescence_rate!`](@ref)  | ☑                      |
| `sen_leaflifespan` | slope of a linear equation that relates the leaf life span to the senescence rate |  [`senescence_rate!`](@ref)  | ☑                      |
| `SENₘᵢₙ`  | | [`seasonal_component_senescence`](@ref) |  fixed|
| `SENₘₐₓ`  | | [`seasonal_component_senescence`](@ref) |  fixed|
| `Ψ₁` | | [`seasonal_component_senescence`](@ref) | fixed|
| `Ψ₂` | | [`seasonal_component_senescence`](@ref) |fixed |
| `sla_tr`                        | reference community weighted mean specific leaf area, if the community weighted mean specific leaf area is equal to `sla_tr` then transpiration will not increase or decrease | [`transpiration`](@ref) | ☑ |
| `sla_tr_exponent`               | controls how strongly a community mean specific leaf area that deviates from `sla_tr` is affecting the transpiration  | [`transpiration`](@ref) | ☑ |
| `biomass_dens`                  | if the matrix multiplication between the trait similarity matrix and the biomass equals `biomass_dens` the available water and nutrients for growth are not in- or decreased | [`below_ground_competition!`](@ref) | ☑ |
| `belowground_density_efffect`   | controls how strongly the available water and nutrients are in- or decreased if the matrix multiplication between the trait similarity matrix and the biomass of the species is above or below of `biomass_dens` | [`below_ground_competition!`](@ref) | ☑ |
| `height_strength`               | controls how strongly taller plants gets more light for growth | [`height_influence!`](@ref) | ☑ |
| `leafnitrogen_graz_exp`         | controls how strongly grazers prefer plant species with high leaf nitrogen content | [`grazing_parameter!`](@ref) |       |
| `κ`                             | consumption of a livestock unit per day [kg d⁻¹] | [`grazing!`](@ref)  | fixed |
| `grazing_half_factor`           | total biomass  [kg ha⁻¹] when the daily consumption by grazers reaches half of their maximal consumption defined by κ $\cdot$ livestock density | [`grazing!`](@ref)  |       |
| `trampling_factor`              | defines together with the height of the plants and the livestock density the proportion of biomass that is trampled $\cdot 10^{-3}$ [ha m⁻¹]                                            |                                     |                       |
| `mowing_mid_days`               | number of days after a mowing event when the plants are grown back to half of their normal size |         |          |
| `max_rsa_above_water_reduction` | maximal reduction of growth based on the water availability the trait root surface area / aboveground biomass | [`rsa_above_water_response!`](@ref) | |
| `max_SLA_water_reduction`       |                                             |                                     |                       |
| `max_AMC_nut_reduction`         |                                             |                                     |                       |
| `max_rsa_above_nut_reduction`   |                                             |                                     |                       |

In addition, regression equation by [Reich1992](@cite) used to calculate the leaf life span from the specific leaf area (see [`senescence_rate!`](@ref)). Regression equation from [Gupta1979](@cite) used to derive
the water holding capacity and the permanent wilting point (see [`input_WHC_PWP`](@ref))



### Parameters that are only used for calibration


| Parameter            | Description |
| -------------------- | ----------- |
| `moistureconv_alpha` |             |
| `moistureconv_beta`  |             |
| `b_biomass`          |             |
| `b_sla`              |             |
| `b_lncm`             |             |
| `b_amc`              |             |
| `b_height`           |             |
| `b_rsa_above`        |             |
| `b_var_sla`          |             |
| `b_var_lncm`         |             |
| `b_var_height`       |             |
| `b_var_rsa_above`    |             |
| `b_soilmoisture`     |             |

