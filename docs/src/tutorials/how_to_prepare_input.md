```@meta
CurrentModule = GrasslandTraitSim
```

# How to prepare the input data to start a simulation

Which input is needed (see also [here](@ref "Model inputs")):
- daily climatic variables (PET, PAR, temperature, precipitation)
- daily management variables (mowing, livestock density)
- soil properties (texture, organic matter, bulk density, root depth)

We will create the input for a simulation from 2010 to 2012 with
dummy data.

If you want to use the model with data from your own site, you can
prepare the input similarly. Convert the data to the units that
are used here and then, add the `Unitful.jl` unit to the data.


## Simulation settings
```@example input_creation
import GrasslandTraitSim as sim
import Dates
using Unitful

time_step_days = Dates.Day(1)
output_date = Dates.Date(2010):Dates.lastdayofyear(Dates.Date(2012))
mean_input_date = output_date[1:end-1] .+ (time_step_days ÷ 2)
year = Dates.year.(output_date[1:end-1])
ntimesteps = length(output_date) - 1
ts = Base.OneTo(ntimesteps) 

simp = (
    output_date,
    ts,
    ntimesteps, 
    time_step_days,
    mean_input_date,
    nspecies = 5,  
    patch_xdim = 1, 
    patch_ydim = 1, 
    npatches = 1,
    trait_seed = missing,  
    initbiomass = 1500u"kg / ha",
    initsoilwater = 80u"mm",
    
    ## which processes to include, see extra tutorial
    ## empty tuple means, that everything is included
    included = sim.create_included(),
    
    ## decide on different versions of the model
    variations = (; use_height_layers = true)
)

nothing # hide
```


## Climatic data

All climatic variables are here set to one to avoid complex data wrangling.

For an explanation of the variables, see [here](@ref "Daily abiotic conditions").

```@example input_creation
# --------------- PAR [MJ ha⁻¹]
PAR = ones(ntimesteps)u"MJ / ha"

# --------------- PET [mm]
PET = ones(ntimesteps)u"mm"

# --------------- precipiation [mm]	
precipitation = ones(ntimesteps)u"mm"

# --------------- temperature [°C]
temperature = ones(ntimesteps)u"°C"

# --------------- yearly temperature sum [°C]
temperature_sum = sim.cumulative_temperature(temperature, year) 

# --------------- final tuple of climatic inputs
climatic_inputs = (; temperature, temperature_sum, PAR, PAR_sum = PAR, PET, PET_sum = PET, precipitation)

nothing # hide
```

## Management data

To show how to create the management data, we will add two mowing events 
(first of May and first of August) and one grazing event per year
(first of June to first of August).

If you want, you can vary the mowing height and the grazing intensity
for each event. If the site was not mowed or grazed in a year, set the
variable to `NaN`.

For an explanation of the variables, see [here](@ref "Daily management variables").

```@example input_creation
# --------------- mowing height [m], NaN if no mowing
CUT_mowing = Vector{Union{Missing, typeof(1.0u"m")}}(missing, ntimesteps)
mowing_dates = [Dates.Date(2010, 5, 1), Dates.Date(2010, 8, 1), 
                Dates.Date(2011, 5, 1), Dates.Date(2011, 8, 1)]
[CUT_mowing[d .== output_date[1:end-1]] .= 0.08u"m" for d in mowing_dates]

# --------------- grazing intensity in livestock density [ha⁻¹], NaN if no grazing
LD_grazing = Vector{Union{Missing, typeof(1.0u"ha^-1")}}(missing, ntimesteps)   
grazing_starts = [Dates.Date(2010, 6, 1), Dates.Date(2011, 6, 1)]
grazing_ends = [Dates.Date(2010, 8, 1), Dates.Date(2011, 8, 1)]
livestock_density = [1, 3]u"ha^-1"

for i in eachindex(grazing_starts)
    r = grazing_starts[i] .<= output_date[1:end-1] .<= grazing_ends[i]
    LD_grazing[r] .= livestock_density[i]
end

management_tuple = (; CUT_mowing, LD_grazing)

nothing # hide
```

## Site variables 

For an explanation of the variables, see [here](@ref "Raw time invariant site variables").

```@example input_creation
site_tuple = (;
    totalN = 5.0u"g / kg",
    clay = 0.5,       
    silt = 0.45,       
    sand = 0.05,        
    organic = 0.06,     
    bulk = 0.7u"g / cm^3",
    rootdepth = 160.0u"mm"
)    

nothing # hide       
```



## Putting everything together

Then we can add all the tuples to one bigger named tuple.

```@example input_creation
input_obj = (; input = (; climatic_inputs..., management_tuple..., site_tuple...),
               simp)
```

**For the plots from the Biodiversity Exploratories, we used the following convenience function
to create the same object:**
```@example input_creation
input_obj_HEG01 = sim.validation_input("HEG01");

nothing # hide
```

## Traits

If no input traits are specified, the model will generate for each simulation new traits from a Gaussian Mixture model that was fitted to grassland plant species in Germany (see [`random_traits!`](@ref)).

If you want to use your own traits, you can specify them in the following way:

```@example input_creation
# the number of values per array has to be equal to the number of species
trait_input = (;
    amc = [0.12, 0.52, 0.82, 0.13, 0.16],
    sla = [0.021, 0.026, 0.014, 0.016, 0.0191]u"m^2/g",
    maxheight = [0.38, 0.08, 0.06, 0.51, 0.27]u"m",
    rsa = [0.108, 0.163, 0.117, 0.132, 0.119]u"m^2/g",
    abp = [0.63, 0.52, 0.65, 0.58, 0.72],
    lbp = [0.55, 0.49, 0.62, 0.38, 0.68],
    lnc = [19.6, 20.7, 22.7, 20.1, 23.6]u"mg/g")

nothing # hide
```

## Run a simulation

```@example input_creation
## get parameters
p = sim.SimulationParameter()

# if you will run many simulations, it is recommended to preallocated the vectors
# but the simulation will also run without preallocation 
prealloc = sim.preallocate_vectors(; input_obj);
prealloc_specific = sim.preallocate_specific_vectors(; input_obj);

# traits will be generated, no preallocation
sol = sim.solve_prob(; input_obj, p);

# with static traits, with preallocation
sol = sim.solve_prob(; input_obj, prealloc, prealloc_specific, p, trait_input);

nothing # hide
```