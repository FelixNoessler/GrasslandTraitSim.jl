
# How to prepare the input data to start a simulation {#How-to-prepare-the-input-data-to-start-a-simulation}

We need several input files to create the input object for the simulation (see also [page on model inputs](/model/inputs#Model-inputs)). You can find the structure and an example for loading the data in the sections below.

## Input files structure {#Input-files-structure}

### Climate.csv {#Climate.csv}
- data for each day is needed
  

```csv
temperature,temperature_sum,precipitation,PET,PAR,t,plotID
0.3,0.3,0,0.1,9060,2006-01-01,AEG01
0.4,0.7,0,0.2,9176,2006-01-02,AEG01
-1.1,0.7,0.1,0.1,5983,2006-01-03,AEG01
```

- **temperature**: Daily average temperature [°C]
  
- **temperature_sum**: Cumulative temperature [°C]
  
- **precipitation**: Daily precipitation [mm d⁻¹]
  
- **PET**: Potential evapotranspiration  [mm d⁻¹]
  
- **PAR**: Photosynthetically active radiation [MJ ha⁻¹ d⁻¹]
  
- **t**: Date [YYYY-MM-DD]
  
- **plotID**: Identifier for the plot (e.g., AEG01)
  

### Management.csv {#Management.csv}
- if no management was done, rows can be omited
  

```csv
LD,CUT,t,plotID
,0.07,2006-06-01,AEG01
,0.07,2006-07-31,AEG01
0.5272,,2022-10-01,AEG01
0.5272,,2022-10-02,AEG01
```

- **LD**: Grazing intensity measured in livestock units [LSU ha⁻¹ d⁻¹] 
  
- **CUT**: Height of mowing event [m]
  
- **t**: Date [YYYY-MM-DD]
  
- **plotID**: Identifier for the plot (e.g., AEG01)
  

### Plots.csv {#Plots.csv}

```csv
plotID,startDate,endDate,initSoilwater
AEG01,2006-01-01,2022-12-31,200
AEG02,2006-01-01,2022-12-31,200
AEG03,2006-01-01,2022-12-31,200
```

- **plotID**: Identifier for the plot (e.g., AEG01)
  
- **startDate**: Start date of the simulation [YYYY-MM-DD]
  
- **endDate**: End date of the simulation [YYYY-MM-DD]
  
- **initSoilwater**: Initial soil water content [mm]
  

### Soil.csv {#Soil.csv}
- All soil properties can be either vary between years and then put into Soil_yearly.csv or be constant over the years and put into Soil.csv. It is possible that either of the files can be omitted if all properties are constant or all properties vary over the years.
  

```csv
sand,silt,clay,organic,bulk,rootdepth,plotID
0.03,0.32,0.64,0.09,0.63,80,AEG01
0.08,0.41,0.51,0.08,0.71,80,AEG02
0.03,0.3,0.67,0.06,0.79,80,AEG03
0.08,0.43,0.49,0.05,0.97,70,AEG04
```

- **sand**: Sand content in the soil [fraction]
  
- **silt**: Silt content in the soil [fraction]
  
- **clay**: Clay content in the soil [fraction]
  
- **organic**: Organic matter content in the soil [fraction]
  
- **bulk**: Bulk density of the soil [g cm⁻³]
  
- **rootdepth**: Mean rooting depth of plants [mm]
  
- **plotID**: Identifier for the plot (e.g., AEG01)
  

### Soil_yearly.csv {#Soil_yearly.csv}
- All soil properties can be either vary between years and then put into Soil_yearly.csv or be constant over the years and put into Soil.csv. It is possible that either of the files can be omitted if all properties are constant or all properties vary over the years.
  

```csv
totalN,fertilization,year,plotID
9.28,69.5785,2006,AEG01
9.28,44.7892,2007,AEG01
9.28,35,2008,AEG01
```

- **totalN**: Total nitrogen content in the soil [g m⁻²]
  
- **fertilization**: Amount of fertilization [kg N ha⁻¹]
  
- **year**: Year of the fertilization event [YYYY]
  
- **plotID**: Identifier for the plot (e.g., AEG01)
  

### Species.csv {#Species.csv}
- time invariant morphological traits of the species, initialization of the species
  

```csv
species,abp,lbp,maxheight,sla,lnc,rsa,amc,initAbovegroundBiomass,initBelowgroundBiomass,initHeight
Achillea millefolium,0.608,0.8,0.8,0.00764,23,0.1538,0.482,71,71,0.4
Agrostis capillaris,0.612,0.8,0.8,0.01714,22.3,0.225,0.44,71,71,0.4
Allium schoenoprasum,0.563,0.8,0.5,0.0034,27.6,0.1651,0.639,71,71,0.2
```

- **species**: Name of the species
  
- **abp**:  Aboveground biomass / total biomass [-]    
  
- **lbp**: Leaf mass / aboveground biomass [-]
  
- **maxheight**: Maximum plant height [m]
  
- **sla**: Specific leaf area [m² g⁻¹]
  
- **lnc**: Leaf nitrogen content per leaf mass [mg g⁻¹]
  
- **rsa**: Root surface area / belowground biomass [m² g⁻¹]
  
- **amc**: Arbuscular mycorrhizal colonisation rate [-]
  
- **initAbovegroundBiomass**: Initial aboveground biomass [kg ha⁻¹]
  
- **initBelowgroundBiomass**: Initial belowground biomass [kg ha⁻¹]
  
- **initHeight**: Initial plant height [m]
  

## Code example - load input data {#Code-example-load-input-data}

see also [example on how to change parameter values](/model/parameter#How-to-change-a-parameter-value)

```julia
## get parameter object
p = sim.SimulationParameter()

## load input data
sim.load_data("your_data_path_here") 

## create input object
input_obj = sim.create_input("your_site_name_here")

## run simulation
sol = sim.solve_prob(; input_obj, p);
```

