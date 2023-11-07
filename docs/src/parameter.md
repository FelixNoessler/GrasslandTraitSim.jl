```@meta
CurrentModule = GrasslandTraitSim
```

# Model Parameter

| Parameter                     | Description                                 | used in                             | calibrated, reference |
| ----------------------------- | ------------------------------------------- | ----------------------------------- | --------------------- |
| `nspecies`                      | Number of species (plant functional types)  | e.g. [`random_traits!`](@ref)       | fixed                 |
| `npatches`                      | Number of quadratic patches within one site |                                     | fixed                 |
| `senescence_intercept`          |                                             |                                     | ☑                      |
| `senescence_rate`               |                                             |                                     | ☑                      |
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

