```@meta
CurrentModule = GrasslandTraitSim
```

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
temperature_sum = sim.cumulative_temperature(; temperature, year) 

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
    initbiomass = 1500u"kg / ha",
    initsoilwater = 80u"mm"
)           
```

## Fixed simulation parameters
```@example input_creation
simp = (
    ntimesteps, 
    nspecies = 5,  
    patch_xdim = 1, 
    patch_ydim = 1, 
    npatches = 1,
    nutheterog = 0.0, 
    trait_seed = missing,  
    
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
    plotID = "HEG01", nspecies = 5);
```

## Traits

If no input traits are specified, the model will generate for each simulation new traits from a Gaussian Mixture model that was fitted to grassland plant species in Germany (see [`random_traits!`](@ref)).

If you want to use your own traits, you can specify them in the following way:

```@example input_creation
# the number of values per array has to be equal to the number of species
trait_input = (;
    amc = [0.12, 0.52, 0.82, 0.13, 0.16],
    sla = [0.021, 0.026, 0.014, 0.016, 0.0191]u"m^2/g",
    height = [0.38, 0.08, 0.06, 0.51, 0.27]u"m",
    rsa_above = [0.108, 0.163, 0.117, 0.132, 0.119]u"m^2/g",
    ampm = [0.63, 0.52, 0.65, 0.58, 0.72],
    lmpm = [0.55, 0.49, 0.62, 0.38, 0.68],
    lncm = [19.6, 20.7, 22.7, 20.1, 23.6]u"mg/g")
```

## Simulation parameters that are adapted in the calibration process

```@example input_creation
inf_p = (
    α_sen = 5.568529, 
    β_sen = 2.131722, 
    sla_tr = 0.0209188, 
    sla_tr_exponent = 1.122322, 
    β_pet = 0.5,
    biomass_dens = 1072.062, 
    belowground_density_effect = 2.054232, 
    height_strength = 0.616476, 
    leafnitrogen_graz_exp = 2.618872, 
    trampling_factor = 198.9975, 
    grazing_half_factor = 102.4847, 
    mowing_mid_days = 46.11971, 
    totalN_β = 0.1,
    CN_β = 0.1,
    δ_wrsa = 0.4799059,
    δ_sla = 0.6447272, 
    δ_amc = 0.7082366, 
    δ_nrsa = 0.4069509
)
```


## Run a simulation

```@example input_creation
# if you will run many simulations, it is recommended to preallocated the vectors
# but the simulation will also run without preallocation 
calc = sim.preallocate_vectors(; input_obj);

# traits will be generated, no preallocation
sol = sim.solve_prob(; input_obj, inf_p)

# with static traits, with preallocation
sol = sim.solve_prob(; input_obj, calc, inf_p, trait_input)
```