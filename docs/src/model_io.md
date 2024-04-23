# Model inputs and outputs

```@meta
CurrentModule = GrasslandTraitSim
```

## Inputs

### [Daily abiotic conditions](@id climate_input)
| Variable          | Symbol        | Description                                       | used in                                                                    |
| ----------------- | ------------- | ------------------------------------------------- | -------------------------------------------------------------------------- |
| `temperature`     | ``T_{txy}``   | Temperature [°C]                                  | [`temperature_reduction!`](@ref)                                           |
| `temperature_sum` | ``ST_{txy}``  | Yearly cumulative temperature [°C]                | [`seasonal_reduction!`](@ref), [`seasonal_component_senescence`](@ref)     |
| `precipitation`   | ``P_{txy}``   | Precipitation [mm d⁻¹]                            | [`change_water_reserve`](@ref)                                             |
| `PAR`             | ``PAR_{txy}`` | Photosynthetically active radiation [MJ ha⁻¹ d⁻¹] | [`potential_growth!`](@ref), [`radiation_reduction!`](@ref)                |
| `PET`             | ``PET_{txy}`` | Potential evapotranspiration [mm d⁻¹]             | [`water_reduction!`](@ref), [`evaporation`](@ref), [`transpiration`](@ref) |

### [Daily management variables](@id management_input)
| Variable     | Symbol        | Description                                                                     | used in                                  |
| ------------ | ------------- | ------------------------------------------------------------------------------- | ---------------------------------------- |
| `CUT_mowing` | ``CUT_{txy}`` | Height of mowing event, `NaN` means no mowing [m]                               | [`mowing!`](@ref)                        |
| `LD_grazing` | ``LD_{txy}``  | Grazing intensity measured in livestock units, `NaN` means no grazing [LD ha⁻¹] | [`grazing!`](@ref), [`trampling!`](@ref) |

### Traits of the plant species
| Variable    | Symbol    |Description                                       | used in                                                                                        |
| ----------- | --------- | ------------------------------------------------ | ---------------------------------------------------------------------------------------------- |
| `amc`       | ``AMC_s`` | Arbuscular mycorrhizal colonisation rate [-]     | [`below_ground_competition!`](@ref), [`nutrient_reduction!`](@ref)                             |
| `sla`       | ``SLA_s`` | Specific leaf area [m² g⁻¹]                      | [`water_reduction!`](@ref), [`calculate_LAI!`](@ref), [`senescence!`](@ref)                    |
| `height`    | ``H_s``   | Plant height [m]                                 | [`potential_growth!`](@ref), [`light_competition!`](@ref), [`mowing!`](@ref)                   |
| `rsa`       | ``RSA_s`` | Root surface area / aboveground biomass [m² g⁻¹] | [`below_ground_competition!`](@ref), [`water_reduction!`](@ref), [`nutrient_reduction!`](@ref) |
| `abp`       | ``ABP_s`` | Aboveground biomass / total biomass [-]          | [`calculate_LAI!`](@ref)                                                                       |
| `lbp`       | ``LBP_s`` | Leaf mass / total biomass [-]                    | [`calculate_LAI!`](@ref)                                                                       |
| `lnc`       | ``LNC_s`` | Leaf nitrogen content per leaf mass [mg g⁻¹]     | [`grazing!`](@ref)                                                                             |
    
### [Raw time invariant site variables](@id site_input)
| Variable    | Symbol       | Description                       | used in                    |
| ----------- | ------------ | --------------------------------- | -------------------------- |
| `sand`      | ``SND_{xy}`` | Sand content [-]                  | [`input_WHC_PWP!`](@ref)   |
| `silt`      | ``SLT_{xy}`` | Silt content [-]                  | [`input_WHC_PWP!`](@ref)   |
| `clay`      | ``CLY_{xy}`` | Clay content [-]                  | [`input_WHC_PWP!`](@ref)   |
| `organic`   | ``OM_{xy}``  | Organic matter content [-]        | [`input_WHC_PWP!`](@ref)   |
| `bulk`      | ``BLK_{xy}`` | Bulk density [g cm⁻³]             | [`input_WHC_PWP!`](@ref)   |
| `rootdepth` | ``RD_{xy}``  | Mean rooting depth of plants [mm] | [`input_WHC_PWP!`](@ref)   |
| `totalN`    | ``N_{xy}``   | Total nitrogen [g kg⁻¹]           | [`input_nutrients!`](@ref) |

### Derived time invariant site variables
| Variable         | Symbol                | Description                                  | used in                       |
| ---------------- | --------------------- | -------------------------------------------- | ----------------------------- |
| `PWP[x, y]`      | ``PWP_{xy}``          | Permanent wilting point [mm]                 | [`water_reduction!`](@ref)    |
| `WHC[x, y]`      | ``WHC_{xy}``          | Water holding capacity [mm]                  | [`water_reduction!`](@ref)    |
| `nutindex[x, y]` | ``N_{xy} / N_{\max}`` | Nutrients index ranging from zero to one [-] | [`nutrient_reduction!`](@ref) |

---

## Outputs

### Sstate variables
| Variable                    | Symbol       | Description                               |
| --------------------------- | ------------ | ----------------------------------------- |
| `biomass[t, x, y, species]` | ``B_{txys}`` | Aboveground fresh green biomass [kg ha⁻¹] |
| `water[t, x, y]`            | ``W_{txy}``  | Water reserve [mm]                        |


### Derived outputs
| Variable                                                                     | Description                                      |
| ---------------------------------------------------------------------------- | ------------------------------------------------ |
| `leaf[t, x, y, species]`, `stem[t, x, y, species]`, `root[t, x, y, species]` | Allocation of biomass to leaves, stems and roots |
| `CWM_trait[t, x, y]`                                                         | Community weighted mean of all traits            |
| `CWV_trait[t, x, y]`                                                         | Community weighted variance of all traits        |
| `FDI[t, x, y]`, `TDI[t, x, y]`                                               | Functional and taxonomic diversity indices       |
