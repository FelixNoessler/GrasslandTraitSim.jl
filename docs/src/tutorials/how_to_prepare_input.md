# How to prepare the input data to start a simulation


Which input is needed (see also [here](@ref "Model inputs and outputs")):
- daily climatic variables (PET, PAR, temperature, precipitation)
- daily management variables (mowing, livestock density)
- soil properties (texture, organic matter, bulk density, root depth)

We will create the input for a simulation from 2010 to 2012 with
dummy data.

If you want to use the model with data from your own site, you can
prepare the input similarly. Convert the data to the units that
are used here and then, add the `Unitful.jl` unit to the data.

## Climatic data

All climatic variables are here set to one to avoid complex data wrangling.

For an explanation of the variables, see [here](@ref climate_input).

```@example input_creation
import GrasslandTraitSim as sim
import Dates
using Unitful

date = Dates.Date(2010):Dates.lastdayofyear(Dates.Date(2012))
doy = Dates.dayofyear.(date)
year = Dates.year.(date)
ntimesteps = length(date)
ts = Base.OneTo(ntimesteps) 

# --------------- PAR [MJ ha⁻¹ d⁻¹]
PAR = ones(ntimesteps)u"MJ / (ha * d)"

# --------------- PET [mm d⁻¹]
PET = ones(ntimesteps)u"mm / d"

# --------------- precipiation [mm d⁻¹]	
precipitation = ones(ntimesteps)u"mm / d"

# --------------- temperature [°C]
temperature = ones(ntimesteps)u"°C"

# --------------- yearly temperature sum [°C]
function cumulative_temperature(; temperature, year)
    temperature = ustrip.(temperature)
    temperature_sum = Float64[]
    
    for y in year
        year_filter = y .== year
        append!(temperature_sum, cumsum(temperature[year_filter]))
    end

    return temperature_sum * u"°C"
end
temperature_sum = cumulative_temperature(; temperature, year)

# --------------- final tuple of climatic inputs
climatic_inputs = (; temperature, temperature_sum, PAR, PET, precipitation)
```

## Management data

To show how to create the management data, we will add two mowing events 
(first of May and first of August) and one grazing event per year
(first of June to first of August).

If you want, you can vary the mowing height and the grazing intensity
for each event. If the site was not mowed or grazed in a year, set the
variable to `NaN`.

For an explanation of the variables, see [here](@ref management_input).

```@example input_creation

# --------------- mowing height [m], NaN if no mowing
mowing = fill(NaN * u"m", ntimesteps)
mowing_dates = [Dates.Date(2010, 5, 1), Dates.Date(2010, 8, 1), 
                Dates.Date(2011, 5, 1), Dates.Date(2011, 8, 1)]
[mowing[d .== date] .= 0.08u"m" for d in mowing_dates]

# --------------- grazing intensity in livestock density [ha⁻¹], NaN if no grazing
grazing = fill(NaN / u"ha", ntimesteps)
grazing_starts = [Dates.Date(2010, 6, 1), Dates.Date(2011, 6, 1)]
grazing_ends = [Dates.Date(2010, 8, 1), Dates.Date(2011, 8, 1)]
livestock_density = [1, 3]u"ha^-1"

for i in eachindex(grazing_starts)
    r = grazing_starts[i] .<= date .<= grazing_ends[i]
    grazing[r] .= livestock_density[i]
end

management_tuple = (; mowing, grazing)
```

## Site variables 

For an explanation of the variables, see [here](@ref site_input).

```@example input_creation
site_tuple = (;
    totalN = 5.0,      # g kg⁻¹
    CNratio = 10.0,    # -
    clay = 50.0,       # %
    silt = 45.0,       # %
    sand = 5.0,        # %
    organic = 6.0,     # %
    bulk = 0.7,        # g cm⁻³
    rootdepth = 160.0, # mm
    initbiomass = 1500u"kg / ha"
)           
```

## Fixed simulation parameters
```@example input_creation
simp = (
    ntimesteps, 
    nspecies = 25, 
    npatches = 1, 
    patch_xdim = 1, 
    patch_ydim = 1, 
    nutheterog = 0.0, 
    constant_seed = false, 
    startyear = year[1], 
    endyear = year[end], 
    
    ## these variables are used to debug the model
    included = 
        (senescence_included = true, 
         potgrowth_included = true, 
         mowing_included = true, 
         grazing_included = true, 
         below_included = true, 
         height_included = true, 
         water_red = true, 
         nutrient_red = true, 
         temperature_red = true, 
         season_red = true, 
         radiation_red = true)
)
```

## Putting everything together

Then we can add all the tuples to one bigger named tuple.

```@example input_creation
input_obj = (; daily_input = (;
                   climatic_inputs..., 
                   management_tuple...,),
               site = site_tuple, 
               simp, doy, date, ts)
```

**For the plots from the Biodiversity Exploratories, we used the following convenience function
to create the same object:**
```@example
import GrasslandTraitSim.Valid as valid
input_obj_HEG01 = valid.validation_input(;
    plotID = "HEG01", nspecies = 25,
    startyear = 2009, endyear = 2021,
    npatches = 1, nutheterog = 0.0);
```

## Simulation parameters that are adapted in the calibration process

```@example input_creation
inf_p = (
    moistureconv_alpha = 5.757897, 
    moistureconv_beta = 1.642053, 
    senescence_intercept = 5.568529, 
    senescence_rate = 2.131722, 
    sla_tr = 0.0209188, 
    sla_tr_exponent = 1.122322, 
    nut_dens = 1072.062, 
    water_dens = 1207.795, 
    belowground_density_effect = 2.054232, 
    height_strength = 0.616476, 
    leafnitrogen_graz_exp = 2.618872, 
    trampling_factor = 198.9975, 
    grazing_half_factor = 102.4847, 
    mowing_mid_days = 46.11971, 
    max_rsa_above_water_reduction = 0.4799059,
    max_SLA_water_reduction = 0.6447272, 
    max_AMC_nut_reduction = 0.7082366, 
    max_rsa_above_nut_reduction = 0.4069509
)
```


## Run a simulation

```@example input_creation
sol = sim.solve_prob(; input_obj, inf_p)
```