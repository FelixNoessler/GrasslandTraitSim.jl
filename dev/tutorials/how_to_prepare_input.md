


# How to prepare the input data to start a simulation {#How-to-prepare-the-input-data-to-start-a-simulation}

Which input is needed (see also [here](/model/inputs#Model-inputs)):
- daily climatic variables (PET, PAR, temperature, precipitation)
  
- daily management variables (mowing, livestock density)
  
- soil properties (texture, organic matter, bulk density, root depth)
  

We will create the input for a simulation from 2010 to 2012 with dummy data.

If you want to use the model with data from your own site, you can prepare the input similarly. Convert the data to the units that are used here and then, add the `Unitful.jl` unit to the data.

## Simulation settings {#Simulation-settings}

```julia
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
```


## Climatic data {#Climatic-data}

All climatic variables are here set to one to avoid complex data wrangling.

For an explanation of the variables, see [here](/model/inputs#Daily-abiotic-conditions).

```julia
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
```


## Management data {#Management-data}

To show how to create the management data, we will add two mowing events  (first of May and first of August) and one grazing event per year (first of June to first of August).

If you want, you can vary the mowing height and the grazing intensity for each event. If the site was not mowed or grazed in a year, set the variable to `NaN`.

For an explanation of the variables, see [here](/model/inputs#Daily-management-variables).

```julia
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
```


## Site variables {#Site-variables}

For an explanation of the variables, see [here](/model/inputs#Raw-time-invariant-site-variables).

```julia
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


## Putting everything together {#Putting-everything-together}

Then we can add all the tuples to one bigger named tuple.

```julia
input_obj = (; input = (; climatic_inputs..., management_tuple..., site_tuple...),
               simp)
```


```
(input = (temperature = Unitful.Quantity{Float64, 𝚯, Unitful.FreeUnits{(K,), 𝚯, Unitful.Affine{-5463//20}}}[1.0 °C, 1.0 °C, 1.0 °C, 1.0 °C, 1.0 °C, 1.0 °C, 1.0 °C, 1.0 °C, 1.0 °C, 1.0 °C  …  1.0 °C, 1.0 °C, 1.0 °C, 1.0 °C, 1.0 °C, 1.0 °C, 1.0 °C, 1.0 °C, 1.0 °C, 1.0 °C], temperature_sum = Any[1.0 °C, 2.0 °C, 3.0 °C, 4.0 °C, 5.0 °C, 6.0 °C, 7.0 °C, 8.0 °C, 9.0 °C, 10.0 °C  …  356.0 °C, 357.0 °C, 358.0 °C, 359.0 °C, 360.0 °C, 361.0 °C, 362.0 °C, 363.0 °C, 364.0 °C, 365.0 °C], PAR = Unitful.Quantity{Float64, 𝐌 𝐓^-2, Unitful.FreeUnits{(ha^-1, MJ), 𝐌 𝐓^-2, nothing}}[1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1  …  1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1], PAR_sum = Unitful.Quantity{Float64, 𝐌 𝐓^-2, Unitful.FreeUnits{(ha^-1, MJ), 𝐌 𝐓^-2, nothing}}[1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1  …  1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1, 1.0 MJ ha^-1], PET = Unitful.Quantity{Float64, 𝐋, Unitful.FreeUnits{(mm,), 𝐋, nothing}}[1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm  …  1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm], PET_sum = Unitful.Quantity{Float64, 𝐋, Unitful.FreeUnits{(mm,), 𝐋, nothing}}[1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm  …  1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm], precipitation = Unitful.Quantity{Float64, 𝐋, Unitful.FreeUnits{(mm,), 𝐋, nothing}}[1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm  …  1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm, 1.0 mm], CUT_mowing = Union{Missing, Unitful.Quantity{Float64, 𝐋, Unitful.FreeUnits{(m,), 𝐋, nothing}}}[missing, missing, missing, missing, missing, missing, missing, missing, missing, missing  …  missing, missing, missing, missing, missing, missing, missing, missing, missing, missing], LD_grazing = Union{Missing, Unitful.Quantity{Float64, 𝐋^-2, Unitful.FreeUnits{(ha^-1,), 𝐋^-2, nothing}}}[missing, missing, missing, missing, missing, missing, missing, missing, missing, missing  …  missing, missing, missing, missing, missing, missing, missing, missing, missing, missing], totalN = 5.0 g kg^-1, clay = 0.5, silt = 0.45, sand = 0.05, organic = 0.06, bulk = 0.7 g cm^-3, rootdepth = 160.0 mm), simp = (output_date = Dates.Date("2010-01-01"):Dates.Day(1):Dates.Date("2012-12-31"), ts = Base.OneTo(1095), ntimesteps = 1095, time_step_days = Dates.Day(1), mean_input_date = [Dates.Date("2010-01-01"), Dates.Date("2010-01-02"), Dates.Date("2010-01-03"), Dates.Date("2010-01-04"), Dates.Date("2010-01-05"), Dates.Date("2010-01-06"), Dates.Date("2010-01-07"), Dates.Date("2010-01-08"), Dates.Date("2010-01-09"), Dates.Date("2010-01-10")  …  Dates.Date("2012-12-21"), Dates.Date("2012-12-22"), Dates.Date("2012-12-23"), Dates.Date("2012-12-24"), Dates.Date("2012-12-25"), Dates.Date("2012-12-26"), Dates.Date("2012-12-27"), Dates.Date("2012-12-28"), Dates.Date("2012-12-29"), Dates.Date("2012-12-30")], nspecies = 5, patch_xdim = 1, patch_ydim = 1, npatches = 1, trait_seed = missing, initbiomass = 1500 kg ha^-1, initsoilwater = 80 mm, included = (senescence = true, senescence_season = true, senescence_sla = true, potential_growth = true, mowing = true, grazing = true, belowground_competition = true, community_self_shading = true, height_competition = true, water_growth_reduction = true, nutrient_growth_reduction = true, root_invest = true, temperature_growth_reduction = true, seasonal_growth_adjustment = true, radiation_growth_reduction = true), variations = (use_height_layers = true,)))
```


**For the plots from the Biodiversity Exploratories, we used the following convenience function to create the same object:**

```julia
input_obj_HEG01 = sim.validation_input("HEG01");
```


## Traits

If no input traits are specified, the model will generate for each simulation new traits from a Gaussian Mixture model that was fitted to grassland plant species in Germany (see [`random_traits!`](/model/index#GrasslandTraitSim.random_traits!)).

If you want to use your own traits, you can specify them in the following way:

```julia
# the number of values per array has to be equal to the number of species
trait_input = (;
    amc = [0.12, 0.52, 0.82, 0.13, 0.16],
    sla = [0.021, 0.026, 0.014, 0.016, 0.0191]u"m^2/g",
    maxheight = [0.38, 0.08, 0.06, 0.51, 0.27]u"m",
    rsa = [0.108, 0.163, 0.117, 0.132, 0.119]u"m^2/g",
    abp = [0.63, 0.52, 0.65, 0.58, 0.72],
    lbp = [0.55, 0.49, 0.62, 0.38, 0.68],
    lnc = [19.6, 20.7, 22.7, 20.1, 23.6]u"mg/g")
```


## Run a simulation {#Run-a-simulation}

```julia
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
```

