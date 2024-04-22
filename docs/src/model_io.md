# Model inputs and outputs

```@meta
CurrentModule = GrasslandTraitSim
```

## Inputs

### [Daily abiotic conditions](@id climate_input)
| Variable          | Description                                       | used in                                                                    |
| ----------------- | ------------------------------------------------- | -------------------------------------------------------------------------- |
| `temperature`     | Temperature [°C]                                  | [`temperature_reduction!`](@ref)                                           |
| `temperature_sum` | Yearly cumulative temperature [°C]                | [`seasonal_reduction!`](@ref), [`seasonal_component_senescence`](@ref)     |
| `precipitation`   | Precipitation [mm d⁻¹]                            | [`change_water_reserve`](@ref)                                             |
| `PAR`             | Photosynthetically active radiation [MJ ha⁻¹ d⁻¹] | [`potential_growth!`](@ref), [`radiation_reduction!`](@ref)                |
| `PET`             | Potential evapotranspiration [mm d⁻¹]             | [`water_reduction!`](@ref), [`evaporation`](@ref), [`transpiration`](@ref) |

### [Daily management variables](@id management_input)
| Variable  | Description                                                                     | used in                                  |
| --------- | ------------------------------------------------------------------------------- | ---------------------------------------- |
| `mowing`  | Height of mowing event, `NaN` means no mowing [m]                               | [`mowing!`](@ref)                        |
| `grazing` | Grazing intensity measured in livestock units, `NaN` means no grazing [LD ha⁻¹] | [`grazing!`](@ref), [`trampling!`](@ref) |

### Traits of the plant species
| Variable    | Description                                      | used in                                                                                        |
| ----------- | ------------------------------------------------ | ---------------------------------------------------------------------------------------------- |
| `amc`       | Arbuscular mycorrhizal colonisation rate [-]     | [`below_ground_competition!`](@ref), [`nutrient_reduction!`](@ref)                             |
| `sla`       | Specific leaf area [m² g⁻¹]                      | [`water_reduction!`](@ref), [`calculate_LAI!`](@ref), [`senescence!`](@ref)                    |
| `height`    | Plant height [m]                                 | [`potential_growth!`](@ref), [`light_competition!`](@ref), [`mowing!`](@ref)                   |
| `rsa_above` | Root surface area / aboveground biomass [m² g⁻¹] | [`below_ground_competition!`](@ref), [`water_reduction!`](@ref), [`nutrient_reduction!`](@ref) |
| `ampm`      | Aboveground biomass / total biomass [-]          | [`calculate_LAI!`](@ref)                                                                       |
| `lmpm`      | Leaf mass / total biomass [-]                    | [`calculate_LAI!`](@ref)                                                                       |
| `lncm`      | Leaf nitrogen content per leaf mass [mg g⁻¹]     | [`grazing!`](@ref)                                                                             |
    
### [Raw time invariant site variables](@id site_input)
| Variable    | Description                       | used in                    |
| ----------- | --------------------------------- | -------------------------- |
| `sand`      | Sand content [%]                  | [`input_WHC_PWP!`](@ref)   |
| `silt`      | Silt content [%]                  | [`input_WHC_PWP!`](@ref)   |
| `clay`      | Clay content [%]                  | [`input_WHC_PWP!`](@ref)   |
| `rootdepth` | Mean rooting depth of plants [mm] | [`input_WHC_PWP!`](@ref)   |
| `bulk`      | Bulk density [g cm⁻³]             | [`input_WHC_PWP!`](@ref)   |
| `organic`   | Organic matter content [%]        | [`input_WHC_PWP!`](@ref)   |
| `totalN`    | Total nitrogen [g kg⁻¹]           | [`input_nutrients!`](@ref) |

### Derived time invariant site variables
| Variable         | Description                                  | used in                       |
| ---------------- | -------------------------------------------- | ----------------------------- |
| `PWP[x, y]`      | Permanent wilting point [mm]                 | [`water_reduction!`](@ref)    |
| `WHC[x, y]`      | Water holding capacity [mm]                  | [`water_reduction!`](@ref)    |
| `nutindex[x, y]` | Nutrients index ranging from zero to one [-] | [`nutrient_reduction!`](@ref) |

---

## Outputs

### Raw outputs (state variables)
| Variable                    | Description                               |
| --------------------------- | ----------------------------------------- |
| `biomass[t, x, y, species]` | Aboveground fresh green biomass [kg ha⁻¹] |
| `water[t, x, y]`            | Water reserve [mm]                        |


### Derived outputs
| Variable                                                                     | Description                                      |
| ---------------------------------------------------------------------------- | ------------------------------------------------ |
| `leaf[t, x, y, species]`, `stem[t, x, y, species]`, `root[t, x, y, species]` | Allocation of biomass to leaves, stems and roots |
| `CWM_trait[t, x, y]`                                                         | Community weighted mean of all traits            |
| `CWV_trait[t, x, y]`                                                         | Community weighted variance of all traits        |
| `FDI[t, x, y]`, `TDI[t, x, y]`                                               | Functional and taxonomic diversity indices       |
