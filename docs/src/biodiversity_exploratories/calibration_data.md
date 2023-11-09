# Model calibration data from the Biodiversity Exploratories

## Input data

### Daily abiotic conditions

The temperature and precipitation was downloaded from the Biodiversity Exploratories data base
and is specific to each site.

Estimates of the photosynthetically active radiation (PAR) are available with a three hours resolution.
A quadratic regression was fitted to the data and used to estimate the daily PAR. 
The daily PAR equals the sum under the quadratic regression curve. The spatial resolution
of the gridded data set is not high enough to describes differences on the plot level,
therefore the daily PAR values were calculated per region 
(Exploratories: Schorfheide-Chorin, Hainich, Schwäbische Alb).

The potential evapotranspiration (PET) values
were estimated by the agrometeorological model AMBAV, the VPGB variable 
("potential evapotranspiration over gras") is used here. Estimates of PET are 
available for different weather stations in Germany.
The closest weather station of each Exploratory was chosen to get the daily PET values. 

| Variable                 | Description                                       | data source           |
| ------------------------ | ------------------------------------------------- | --------------------- |
| `temperature[t, plot]`   | Temperature [°C]                                  | [explo19007v6](@cite) |
| `precipitation[t, plot]` | Precipitation [mm d⁻¹]                            | [explo19007v6](@cite) |
| `PAR[t, region]`         | Photosynthetically active radiation [MJ ha⁻¹ d⁻¹] | [PARdata](@cite)      |
| `PET[t, region]`         | Potential evapotranspiration [mm d⁻¹]             | [PETdata](@cite)      |

### Daily management variables

Unfortunately, the raw data set is at the moment not publicly available.

| Variable  | Description                                                                     | data source            |
| --------- | ------------------------------------------------------------------------------- | ---------------------- |
| `mowing`  | Height of mowing event, `NaN` means no mowing [m]                               | [explo26487v58](@cite) |
| `grazing` | Grazing intensity measured in livestock units, `NaN` means no grazing [LD ha⁻¹] | [explo26487v58](@cite) |


### Raw time invariant site variables
The texture classes of [explo14686v10](@cite) were partly collapsed:
`Fine_Silt`, `Medium_Silt`, `Coarse_Silt` to `silt` and
`Fine_Sand`, `Medium_Sand`, `Coarse_Sand` to `sand`.

| Variable    | Description                                 | Data source            |
| ----------- | ------------------------------------------- | ---------------------- |
| `sand`      | Sand content [%]                            | [explo14686v10](@cite) |
| `silt`      | Silt content [%]                            | [explo14686v10](@cite) |
| `clay`      | Clay content [%]                            | [explo14686v10](@cite) |
| `rootdepth` | Mean rooting depth of plants [mm, orig: cm] | [explo4761v3](@cite)   |
| `bulk`      | Bulk density [g cm⁻³]                       | [explo17086v4](@cite)  |
| `organic`   | Organic matter content [%]                  | [explo14446v19](@cite) |
| `totalN`    | Total nitrogen [g kg⁻¹]                     | [explo14446v19](@cite)[explo18787v6](@cite)[explo23846v10](@cite)[explo31210v6](@cite) |
| `CNratio`   | Carbon to nitrogen ratio [-]                | [explo14446v19](@cite) |



## Calibration data

Biomass and soil moisture data was downloaded for 2009 - 2022.

| Variable                | Description                                                                           | Data source     |
| ----------------------- | ------------------------------------------------------------------------------------- | -------------- |
| `biomass[plot, year]`   | Dried aboveground biomass, cutted at a height of 4 cm once per year in spring [g m⁻²] | [explo16209v2](@cite)[explo12706v2](@cite)[explo14346v3](@cite)[explo15588v2](@cite)[explo16826v4](@cite)[explo19807v4](@cite)[explo19809v3](@cite)[explo21187v3](@cite)[explo23486v4](@cite)[explo24166v4](@cite)[explo26151v4](@cite)[explo27426v5](@cite)[explo31180v22](@cite)[explo31387v10](@cite) |
| `soilmoisture[plot, t]` | Daily soil moisture [%] | [explo19007v6](@cite) |


### Community weighted mean traits

**Raw data:**

Vegetation data was subsetted to 2009 - 2002. The exact date of the vegetation records is not available in [explo31389v7](@cite), therefore the dates of the vegetation sampling were used from the header data sets.

Species mean trait values were calculated from the raw trait data sets.

| Description                                      | Data source                                             |
| ------------------------------------------------ | ------------------------------------------------------- |
| Vegetation records                               | data: [explo31389v7](@cite), date: [explo6340v2](@cite)[explo13486v2](@cite)[explo14326v2](@cite)[explo15588v2](@cite)[explo16826v4](@cite)[explo19807v4](@cite)[explo19809v3](@cite)[explo21187v3](@cite)[explo23486v4](@cite)[explo24166v4](@cite)[explo26151v4](@cite)[explo27426v5](@cite)[explo31180v22](@cite)[explo31387v10](@cite) |
| Specific leaf area [m² g⁻¹]                      | [explo24807v2](@cite)                                   |
| Arbuscular mycorrhizal colonisation [-]          | [explo26546v2](@cite)                                   |
| Root surface area / aboveground biomass [m² g⁻¹] | [explo26546v2](@cite)                                   |
| Plant height [m]                                 | [trydb](@cite)                                          |
| Leaf nitrogen / leaf mass [mg g⁻¹]               | [trydb](@cite)                                          |


**Derived community weighted mean traits:**

Vegetation data set with exact dates was joined with species mean trait values to
calculate community weighted mean traits for each plot and year.

| Variable                  | Description                                      |
| ------------------------- | ------------------------------------------------ |
| `CWM_sla[t, plot]`        | Specific leaf area [m² g⁻¹]                      |
| `CWM_amc[t, plot]`        | Arbuscular mycorrhizal colonisation [-]          |
| `CWM_rsa_above[t, plot]` | Root surface area / aboveground biomass [m² g⁻¹] |
| `CWM_height[t, plot]`     | Plant height [m]                                 |
| `CWM_lncm[t, plot]`       | Leaf nitrogen / leaf mass [mg g⁻¹]               |
