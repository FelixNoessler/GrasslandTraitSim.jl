```@meta
CurrentModule = GrasslandTraitSim
```

# How to model heterogeneous site conditions or management

This tutorial assumes that you have read the basic tutorial [How to prepare the input data to start a simulation](@ref). We will use an existing input object and change the number of patches to two and remove the management in the second patch.


```@example heterog_input
import GrasslandTraitSim as sim
import GrasslandTraitSim.Valid as valid

using Unitful
using Statistics
using CairoMakie

patch_xdim = 2 
patch_ydim = 1

input_obj_prep = valid.validation_input(;
    plotID = "HEG01", nspecies = 25,
    trait_seed = 99);

# --------------- change the number of patches
simp_prep = Dict()
for k in keys(input_obj_prep.simp)
    simp_prep[k] = input_obj_prep.simp[k]
end
simp_prep[:patch_xdim] = patch_xdim
simp_prep[:patch_ydim] = patch_ydim
simp_prep[:npatches] = patch_xdim * patch_ydim
simp = NamedTuple(simp_prep)

# --------------- change the management
daily_input_prep = Dict()
for k in keys(input_obj_prep.daily_input)
    daily_input_prep[k] = input_obj_prep.daily_input[k]
end

mowing_prep = daily_input_prep[:mowing]
mowing = fill(NaN * u"m", length(mowing_prep), patch_xdim, patch_ydim)
mowing[:, 1, 1] .= mowing_prep

grazing_prep = daily_input_prep[:grazing]
grazing = fill(NaN / u"ha", length(grazing_prep), patch_xdim, patch_ydim)
grazing[:, 1, 1] .= grazing_prep

daily_input_prep[:mowing] = mowing
daily_input_prep[:grazing] = grazing
daily_input = NamedTuple(daily_input_prep)

# --------------- add everything together
input_obj = (; daily_input, simp,
               site = input_obj_prep.site,  
               doy = input_obj_prep.doy, 
               date = input_obj_prep.date, 
               ts = input_obj_prep.ts)
```

```@example heterog_input
p = sim.Parameter() 

sol = sim.solve_prob(; input_obj, p);

patch_biomass = dropdims(sum(sol.output.biomass; dims = :species); dims = :species)
numeric_date = sim.Valid.to_numeric.(sol.date)

begin
    fig = Figure()
    Axis(fig[1, 1];
         ylabel = "Aboveground dry biomass [kg ha⁻¹]", 
         xlabel = "Date [year]")

    for x in Base.OneTo(patch_xdim)
        for y in Base.OneTo(patch_ydim)
            lines!(numeric_date, vec(ustrip.(patch_biomass[:, x, y]));)  
        end
    end
    
    fig
end
```