# Model inputs and outputs

```@meta
CurrentModule = GrasslandTraitSim
```

## Inputs

### [Daily abiotic conditions](@id climate_input)
| Variable          | Description                                       | used in |
| ----------------- | ------------------------------------------------- | ------- |
| `temperature`     | Temperature [°C]                                  | [`temperature_reduction`](@ref) |
| `temperature_sum` | Yearly cumulative temperature [°C]                | [`seasonal_reduction`](@ref), [`seasonal_component_senescence`](@ref)         |
| `precipitation`   | Precipitation [mm d⁻¹]                            | [`change_water_reserve`](@ref) |
| `PAR`             | Photosynthetically active radiation [MJ ha⁻¹ d⁻¹] | [`potential_growth!`](@ref), [`radiation_reduction`](@ref) |
| `PET`             | Potential evapotranspiration [mm d⁻¹]             |[`water_reduction!`](@ref), [`evaporation`](@ref), [`transpiration`](@ref)        |


### [Daily management variables](@id management_input)
| Variable  | Description                                                                     | used in                                                |
| --------- | ------------------------------------------------------------------------------- | ------------------------------------------------------ |
| `mowing`  | Height of mowing event, `NaN` means no mowing [m]                               | [`mowing!`](@ref)                               |
| `grazing` | Grazing intensity measured in livestock units, `NaN` means no grazing [LD ha⁻¹] | [`grazing!`](@ref), [`trampling!`](@ref) |


### [Raw time invariant site variables](@id site_input)

| Variable    | Description                       | used in                   |
| ----------- | --------------------------------- | ------------------------- |
| `sand`      | Sand content [%]                  | [`input_WHC_PWP`](@ref)   |
| `silt`      | Silt content [%]                  | [`input_WHC_PWP`](@ref)   |
| `clay`      | Clay content [%]                  | [`input_WHC_PWP`](@ref)   |
| `rootdepth` | Mean rooting depth of plants [mm] | [`input_WHC_PWP`](@ref)   |
| `bulk`      | Bulk density [g cm⁻³]             | [`input_WHC_PWP`](@ref)   |
| `organic`   | Organic matter content [%]        | [`input_WHC_PWP`](@ref)   |
| `totalN`    | Total nitrogen [g kg⁻¹]           | [`input_nutrients!`](@ref) |
| `CNratio`   | Carbon to nitrogen ratio [-]      | [`input_nutrients!`](@ref) |



### Derived time invariant site variables

| Variable          | Description                                  | used in                                                                   |
| ----------------- | -------------------------------------------- | ------------------------------------------------------------------------- |
| `PWP[patch]`      | Permanent wilting point [mm]                 | [`water_reduction!`](@ref)                                         |
| `WHC[patch]`      | Water holding capacity [mm]                  | [`water_reduction!`](@ref)                                         |
| `nutindex[patch]` | Nutrients index ranging from zero to one [-] | [`amc_nut_reduction!`](@ref), [`rsa_above_nut_reduction!`](@ref) |

---

## Outputs

### Raw outputs
| Variable                     | Description                               |
| ---------------------------- | ----------------------------------------- |
| `biomass[t, patch, species]` | Aboveground fresh green biomass [kg ha⁻¹] |
| `water[t, patch]`            | Water reserve [mm]                        |


### Derived outputs (community weighted mean traits)

| Variable                   | Description                                      |
| -------------------------- | ------------------------------------------------ |
| `CWM_sla[t, patch]`        | Specific leaf area [m² g⁻¹]                      |
| `CWM_amc[t, patch]`        | Arbuscular mycorrhizal colonisation [-]          |
| `CWM_rsa_above[t, patch]` | Root surface area / aboveground biomass [m² g⁻¹] |
| `CWM_height[t, patch]`     | Plant height [m]                                 |
| `CWM_lncm[t, patch]`       | Leaf nitrogen / leaf mass [mg g⁻¹]               |


