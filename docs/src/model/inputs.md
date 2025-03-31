```@meta
CurrentModule = GrasslandTraitSim
```

# Model inputs

Here you find all inputs needed to start a simulation. You can click on the links to the methods to see how the input is used in those methods. If you want to prepare your own inputs, go to the [tutorial](@ref "How to prepare the input data to start a simulation").

## Daily abiotic conditions
| Symbol        | Description                                                        | used in                                                                    |
| ------------- | ------------------------------------------------------------------ | -------------------------------------------------------------------------- |
| ``T_{txy}``   | Temperature [°C]                                                   | [`temperature_reduction!`](@ref)                                           |
| ``ST_{txy}``  | Cumulative temperature from the beginning of the current year [°C] | [`seasonal_reduction!`](@ref), [`seasonal_component_senescence`](@ref)     |
| ``P_{txy}``   | Precipitation [mm d⁻¹]                                             | [`change_water_reserve`](@ref)                                             |
| ``PAR_{txy}`` | Photosynthetically active radiation [MJ ha⁻¹ d⁻¹]                  | [`potential_growth!`](@ref), [`radiation_reduction!`](@ref)                |
| ``PET_{txy}`` | Potential evapotranspiration [mm d⁻¹]                              | [`water_reduction!`](@ref), [`evaporation`](@ref), [`transpiration`](@ref) |

## Daily management variables
| Symbol        | Description                                                                     | used in                                  
| ------------- | ------------------------------------------------------------------------------- | -------------------|
| ``CUT_{txy}`` | Height of mowing event, `NaN` means no mowing [m]                               | [`mowing!`](@ref)  |
| ``LD_{txy}``  | Grazing intensity measured in livestock units, `NaN` means no grazing [LD ha⁻¹] | [`grazing!`](@ref) |

## Morphological traits of the plant species
| Symbol          | Description                                      | used in                                                                                    |
| --------------- | ------------------------------------------------ | ------------------------------------------------------------------------------------------ |
| ``amc_s``       | Arbuscular mycorrhizal colonisation rate [-]     | [`nutrient_competition!`](@ref), [`nutrient_reduction!`](@ref)                             |
| ``sla_s``       | Specific leaf area [m² g⁻¹]                      | [`water_reduction!`](@ref), [`calculate_LAI!`](@ref), [`senescence!`](@ref)                |
| ``maxheight_s`` | Maximum plant height [m]                         | [`potential_growth!`](@ref), [`light_competition!`](@ref), [`mowing!`](@ref)               |
| ``rsa_s``       | Root surface area / aboveground biomass [m² g⁻¹] | [`nutrient_competition!`](@ref), [`water_reduction!`](@ref), [`nutrient_reduction!`](@ref) |
| ``abp_s``       | Aboveground biomass / total biomass [-]          | [`calculate_LAI!`](@ref)                                                                   |
| ``lbp_s``       | Leaf mass / aboveground biomass [-]              | [`calculate_LAI!`](@ref)                                                                   |
| ``lnc_s``       | Leaf nitrogen content per leaf mass [mg g⁻¹]     | [`grazing!`](@ref)                                                                         |
    
## Raw time invariant site variables
| Symbol       | Description                       | used in                       |
| ------------ | --------------------------------- | --------------------------    |
| ``SND_{xy}`` | Sand content [-]                  | [`input_WHC_PWP!`](@ref)      |
| ``SLT_{xy}`` | Silt content [-]                  | [`input_WHC_PWP!`](@ref)      |
| ``CLY_{xy}`` | Clay content [-]                  | [`input_WHC_PWP!`](@ref)      |
| ``OM_{xy}``  | Organic matter content [-]        | [`input_WHC_PWP!`](@ref)      |
| ``BLK_{xy}`` | Bulk density [g cm⁻³]             | [`input_WHC_PWP!`](@ref)      |
| ``RD_{xy}``  | Mean rooting depth of plants [mm] | [`input_WHC_PWP!`](@ref)      |
| ``N_{xy}``   | Total nitrogen [g kg⁻¹]           | [`nutrient_reduction!`](@ref) |
