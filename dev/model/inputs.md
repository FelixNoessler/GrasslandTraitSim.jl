


# Model inputs {#Model-inputs}

Here you find all inputs needed to start a simulation. You can click on the links to the methods to see how the input is used in those methods. If you want to prepare your own inputs, go to the [tutorial](/tutorials/how_to_prepare_input#How-to-prepare-the-input-data-to-start-a-simulation).

## Daily abiotic conditions {#Daily-abiotic-conditions}

|      Symbol |                                                        Description |                                                                                                                                                                                                                                         used in |
| -----------:| ------------------------------------------------------------------:| -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
|   $T_{txy}$ |                                                   Temperature [°C] |                                                                                                                                          [`temperature_reduction!`](/model/biomass/growth_env_factors#GrasslandTraitSim.temperature_reduction!) |
|  $ST_{txy}$ | Cumulative temperature from the beginning of the current year [°C] |                                  [`seasonal_reduction!`](/model/biomass/growth_env_factors#GrasslandTraitSim.seasonal_reduction!), [`seasonal_component_senescence`](/model/biomass/senescence#GrasslandTraitSim.seasonal_component_senescence) |
|   $P_{txy}$ |                                             Precipitation [mm d⁻¹] |                                                                                                                                                             [`change_water_reserve`](/model/water/index#GrasslandTraitSim.change_water_reserve) |
| $PAR_{txy}$ |                  Photosynthetically active radiation [MJ ha⁻¹ d⁻¹] |                                           [`potential_growth!`](/model/biomass/growth_potential_growth#GrasslandTraitSim.potential_growth!), [`radiation_reduction!`](/model/biomass/growth_env_factors#GrasslandTraitSim.radiation_reduction!) |
| $PET_{txy}$ |                              Potential evapotranspiration [mm d⁻¹] | [`water_reduction!`](/model/biomass/growth_species_specific_water#GrasslandTraitSim.water_reduction!), [`evaporation`](/model/water/index#GrasslandTraitSim.evaporation), [`transpiration`](/model/water/index#GrasslandTraitSim.transpiration) |


## Daily management variables {#Daily-management-variables}

|      Symbol |                                                                     Description |                                                                used in |
| -----------:| -------------------------------------------------------------------------------:| ----------------------------------------------------------------------:|
| $CUT_{txy}$ |                               Height of mowing event, `NaN` means no mowing [m] |   [`mowing!`](/model/biomass/mowing_grazing#GrasslandTraitSim.mowing!) |
|  $LD_{txy}$ | Grazing intensity measured in livestock units, `NaN` means no grazing [LD ha⁻¹] | [`grazing!`](/model/biomass/mowing_grazing#GrasslandTraitSim.grazing!) |


## Morphological traits of the plant species {#Morphological-traits-of-the-plant-species}

|        Symbol |                                      Description |                                                                                                                                                                                                                                                                                                                                     used in |
| -------------:| ------------------------------------------------:| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
|       $amc_s$ |     Arbuscular mycorrhizal colonisation rate [-] |                                                                                                        [`nutrient_competition!`](/model/biomass/growth_species_specific_nutrients#GrasslandTraitSim.nutrient_competition!), [`nutrient_reduction!`](/model/biomass/growth_species_specific_nutrients#GrasslandTraitSim.nutrient_reduction!) |
|       $sla_s$ |                      Specific leaf area [m² g⁻¹] |                                                                [`water_reduction!`](/model/biomass/growth_species_specific_water#GrasslandTraitSim.water_reduction!), [`calculate_LAI!`](/model/biomass/growth_potential_growth#GrasslandTraitSim.calculate_LAI!), [`senescence!`](/model/biomass/senescence#GrasslandTraitSim.senescence!) |
| $maxheight_s$ |                         Maximum plant height [m] |                                                          [`potential_growth!`](/model/biomass/growth_potential_growth#GrasslandTraitSim.potential_growth!), [`light_competition!`](/model/biomass/growth_species_specific_light#GrasslandTraitSim.light_competition!), [`mowing!`](/model/biomass/mowing_grazing#GrasslandTraitSim.mowing!) |
|       $rsa_s$ | Root surface area / aboveground biomass [m² g⁻¹] | [`nutrient_competition!`](/model/biomass/growth_species_specific_nutrients#GrasslandTraitSim.nutrient_competition!), [`water_reduction!`](/model/biomass/growth_species_specific_water#GrasslandTraitSim.water_reduction!), [`nutrient_reduction!`](/model/biomass/growth_species_specific_nutrients#GrasslandTraitSim.nutrient_reduction!) |
|       $abp_s$ |          Aboveground biomass / total biomass [-] |                                                                                                                                                                                                                                                 [`calculate_LAI!`](/model/biomass/growth_potential_growth#GrasslandTraitSim.calculate_LAI!) |
|       $lbp_s$ |                    Leaf mass / total biomass [-] |                                                                                                                                                                                                                                                 [`calculate_LAI!`](/model/biomass/growth_potential_growth#GrasslandTraitSim.calculate_LAI!) |
|       $lnc_s$ |     Leaf nitrogen content per leaf mass [mg g⁻¹] |                                                                                                                                                                                                                                                                      [`grazing!`](/model/biomass/mowing_grazing#GrasslandTraitSim.grazing!) |


## Raw time invariant site variables {#Raw-time-invariant-site-variables}

|     Symbol |                       Description |                                                                                                         used in |
| ----------:| ---------------------------------:| ---------------------------------------------------------------------------------------------------------------:|
| $SND_{xy}$ |                  Sand content [-] |                                         [`input_WHC_PWP!`](/model/water/index#GrasslandTraitSim.input_WHC_PWP!) |
| $SLT_{xy}$ |                  Silt content [-] |                                         [`input_WHC_PWP!`](/model/water/index#GrasslandTraitSim.input_WHC_PWP!) |
| $CLY_{xy}$ |                  Clay content [-] |                                         [`input_WHC_PWP!`](/model/water/index#GrasslandTraitSim.input_WHC_PWP!) |
|  $OM_{xy}$ |        Organic matter content [-] |                                         [`input_WHC_PWP!`](/model/water/index#GrasslandTraitSim.input_WHC_PWP!) |
| $BLK_{xy}$ |             Bulk density [g cm⁻³] |                                         [`input_WHC_PWP!`](/model/water/index#GrasslandTraitSim.input_WHC_PWP!) |
|  $RD_{xy}$ | Mean rooting depth of plants [mm] |                                         [`input_WHC_PWP!`](/model/water/index#GrasslandTraitSim.input_WHC_PWP!) |
|   $N_{xy}$ |           Total nitrogen [g kg⁻¹] | [`nutrient_reduction!`](/model/biomass/growth_species_specific_nutrients#GrasslandTraitSim.nutrient_reduction!) |

