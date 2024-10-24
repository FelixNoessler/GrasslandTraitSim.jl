# Model inputs and outputs

```@meta
CurrentModule = GrasslandTraitSim
```

## Inputs

### [Daily abiotic conditions](@id climate_input)
| Symbol        | Description                                       | used in                                                                    |
| ------------- | ------------------------------------------------- | -------------------------------------------------------------------------- |
| ``T_{txy}``   | Temperature [°C]                                  | [`temperature_reduction!`](@ref)                                           |
| ``ST_{txy}``  | Yearly cumulative temperature [°C]                | [`seasonal_reduction!`](@ref), [`seasonal_component_senescence`](@ref)     |
| ``P_{txy}``   | Precipitation [mm d⁻¹]                            | [`change_water_reserve`](@ref)                                             |
| ``PAR_{txy}`` | Photosynthetically active radiation [MJ ha⁻¹ d⁻¹] | [`potential_growth!`](@ref), [`radiation_reduction!`](@ref)                |
| ``PET_{txy}`` | Potential evapotranspiration [mm d⁻¹]             | [`water_reduction!`](@ref), [`evaporation`](@ref), [`transpiration`](@ref) |

### [Daily management variables](@id management_input)
| Symbol        | Description                                                                     | used in                                  
| ------------- | ------------------------------------------------------------------------------- | ---------------------------------------- |
| ``CUT_{txy}`` | Height of mowing event, `NaN` means no mowing [m]                               | [`mowing!`](@ref)                        |
| ``LD_{txy}``  | Grazing intensity measured in livestock units, `NaN` means no grazing [LD ha⁻¹] | [`grazing!`](@ref)                       |

### Traits of the plant species
| Symbol    |Description                                       | used in                                                                                        |
| --------- | ------------------------------------------------ | ---------------------------------------------------------------------------------------------- |
| ``AMC_s`` | Arbuscular mycorrhizal colonisation rate [-]     | [`nutrient_competition!`](@ref), [`nutrient_reduction!`](@ref)                             |
| ``SLA_s`` | Specific leaf area [m² g⁻¹]                      | [`water_reduction!`](@ref), [`calculate_LAI!`](@ref), [`senescence!`](@ref)                    |
| ``H_s``   | Plant height [m]                                 | [`potential_growth!`](@ref), [`light_competition!`](@ref), [`mowing!`](@ref)                   |
| ``RSA_s`` | Root surface area / aboveground biomass [m² g⁻¹] | [`nutrient_competition!`](@ref), [`water_reduction!`](@ref), [`nutrient_reduction!`](@ref) |
| ``ABP_s`` | Aboveground biomass / total biomass [-]          | [`calculate_LAI!`](@ref)                                                                       |
| ``LBP_s`` | Leaf mass / total biomass [-]                    | [`calculate_LAI!`](@ref)                                                                       |
| ``LNC_s`` | Leaf nitrogen content per leaf mass [mg g⁻¹]     | [`grazing!`](@ref)                                                                             |
    
### [Raw time invariant site variables](@id site_input)
| Symbol       | Description                       | used in                    |
| ------------ | --------------------------------- | -------------------------- |
| ``SND_{xy}`` | Sand content [-]                  | [`input_WHC_PWP!`](@ref)   |
| ``SLT_{xy}`` | Silt content [-]                  | [`input_WHC_PWP!`](@ref)   |
| ``CLY_{xy}`` | Clay content [-]                  | [`input_WHC_PWP!`](@ref)   |
| ``OM_{xy}``  | Organic matter content [-]        | [`input_WHC_PWP!`](@ref)   |
| ``BLK_{xy}`` | Bulk density [g cm⁻³]             | [`input_WHC_PWP!`](@ref)   |
| ``RD_{xy}``  | Mean rooting depth of plants [mm] | [`input_WHC_PWP!`](@ref)   |
| ``N_{xy}``   | Total nitrogen [g kg⁻¹]           | [`nutrient_reduction!`](@ref) |

### Derived time invariant site variables
| Symbol                | Description                                  | used in                       |
| --------------------- | -------------------------------------------- | ----------------------------- |
| ``PWP_{xy}``          | Permanent wilting point [mm]                 | [`water_reduction!`](@ref)    |
| ``WHC_{xy}``          | Water holding capacity [mm]                  | [`water_reduction!`](@ref)    |
| ``N_{xy} / N_{\max}`` | Nutrients index ranging from zero to one [-] | [`nutrient_reduction!`](@ref) |

---

## Outputs

### State variables
| Symbol       | Description                               |
| ------------ | ----------------------------------------- |
| ``B_{txys}`` | Aboveground fresh green biomass [kg ha⁻¹] |
| ``W_{txy}``  | Water reserve [mm]                        |


### Derived outputs
| Variable                                                                     | Description                                      |
| ---------------------------------------------------------------------------- | ------------------------------------------------ |
| `leaf[t, x, y, species]`, `stem[t, x, y, species]`, `root[t, x, y, species]` | Allocation of biomass to leaves, stems and roots |
| `CWM_trait[t, x, y]`                                                         | Community weighted mean of all traits            |
| `CWV_trait[t, x, y]`                                                         | Community weighted variance of all traits        |
| `FDI[t, x, y]`, `TDI[t, x, y]`                                               | Functional and taxonomic diversity indices       |
