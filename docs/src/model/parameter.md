```@meta
CurrentModule = GrasslandTraitSim
```

# Parameter in the model

```@eval
import GrasslandTraitSim as sim
import Markdown
using LaTeXStrings
using PrettyTables

function parameter_doc()
    param_description = (;
        ϕ_TRSA = L"Reference root surface area per total biomass, used in nutrient stress function and maintenance costs for roots function, set to mean of community: $\phi_{TRSA} = \text{mean}((1 - \mathbf{abp}) \cdot \mathbf{rsa})$",
        ϕ_TAMC = L"Reference arbuscular mycorriza colonisation rate per total biomass, used in nutrient stress function and maintenance costs for mycorrhizae function, set to mean of community: $\phi_{TAMC} = \text{mean}((1 - \mathbf{abp}) \cdot \mathbf{amc})$",
        ϕ_sla = L"Reference specific leaf area, used in senescence function, set to mean of community: $\phi_{sla} = \text{mean}(\mathbf{sla})$",
        
        γ_RUEmax = "Maximum radiation use efficiency",
        γ_RUE_k =  "Light extinction coefficient",
        α_RUE_cwmH = "Reduction factor of radiation use efficiency at a height of 0.2 m ∈ [0, 1]",
        
        α_WAT_rsa05 = L"Water stress growth reduction factor for species with mean trait: $TRSA = \phi_{TRSA}$, when the plant available water equals: $W_{p,t} = 0.5$",
        β_WAT_rsa = "Slope of the logistic function that relates the plant available water to the water stress growth reduction factor",
        δ_WAT_rsa  = "Controls how strongly species differ in their water stress growth reduction from the mean response", 
        
        ω_NUT_totalN = "Controls the influence of the total soil nitrogen on the nutrient index",
        ω_NUT_fertilization = "Controls the influence of the fertilization rate on the nutrient index",
        β_TS = L"Scales the similarity for nutrient uptake traits (root surface area and arbuscular and mycorriza colonisation rate), which is used for competition for nutrients (very dissimilar species compete less strongly for nutrients). If $β_TS = 0$, all trait similiarities are set to 1 and the trait similarity has no effect on the competition for nutrients, with increasing $β_{TS}$ the effect of the trait similarity on the nutrient competition becomes stronger.",
        α_NUT_TSB = L"Reference value, if the sum of the product of trait similarity and biomass of all species equals: $\sum TS \cdot B < 1$, $\sum TS \cdot B = 1$, $\sum TS \cdot B > 1$ the nutrient adjustment factor $NUT_{adj,ts}$ is higher than one, one and lower than one, respectively",
        α_NUT_maxadj = "Maximum of the nutrient adjustment factor, fixed for calibration",
        α_NUT_amc05 = L"Nutrient stress based on arbuscular mycorriza colonisation growth reduction factor for species with mean trait: $TAMC = \phi_{TAMC}$, when the plant available nutrients equal: $N_{p,ts} = 0.5$",
        α_NUT_rsa05 = L"Nutrient stress based on root surface area growth reduction factor for species with mean trait: $TRSA = \phi_{TRSA}$, when the plant available nutrients equal: $N_{p,ts} = 0.5$",
        β_NUT_rsa = "Slope of the logistic function that relates the plant available nutrients to the nutrient stress growth reduction factor based on root surface area & calibrated",
        β_NUT_amc = "Slope of the logistic function that relates the plant available nutrients to the nutrient stress growth reduction factor based on arbuscular mycorriza colonisation",
        δ_NUT_rsa = "Controls how strongly species differ in their nutrient stress growth reduction based on root surface area from the mean response",
        δ_NUT_amc = "Controls how strongly species differ in their nutrients stress growth reduction based on arbuscular mycorriza colonisation from the mean response & calibrated",
        
        κ_ROOT_amc = "Maximum growth reduction due to maintenance costs for mycorrhizae based on arbuscular mycorriza colonisation rate",
        κ_ROOT_rsa = "Maximum growth reduction due to maintenance costs for fine roots based on root surface area",
        
        γ_RAD1 = L"Controls the steepness of the linear decrease in radiation use efficiency for high $PAR_{t}$ values",
        γ_RAD2 = L"Threshold value of $PAR_{t}$ from which starts a linear decrease in radiation use efficiency",
        
        ω_TEMP_T1 = "Minimum temperature for growth",
        ω_TEMP_T2 = "Lower limit of optimum temperature for growth",
        ω_TEMP_T3 = "Upper limit of optimum temperature for growth",
        ω_TEMP_T4 = "Maximum temperature for growth",
        
        ζ_SEA_ST1 = L"Threshold of the cumulative temperate since the beginning of the current year, the seasonality factor starts to decrease from $\zeta_{SEA\max}$ to $\zeta_{SEA\min}$ above $\zeta_{SEA,ST_1} - 100 °C$",
        ζ_SEA_ST2 = L"Threshold of the cumulative temperate since the beginning of the current year, above which the seasonality factor is set to $\zeta_{SEA\min}$",
        ζ_SEAmin = "Minimum value of the seasonal growth effect",
        ζ_SEAmax = "Maximum value of the seasonal growth effect",
        
        α_SEN = "Basic senescence rate",
        β_SEN_sla = " Controls the influence of the specific leaf area on the senescence rate",
        ψ_SEN_ST1 = "Threshold of the cumulative temperate since the beginning of the current year above which the senescence begins to increase",
        ψ_SEN_ST2 = "Threshold of the cumulative temperate since the beginning of the current year above which the senescence reaches the maximum senescence rate",
        ψ_SENmax = "Maximum senescence rate",
        
        β_GRZ_lnc = " Controls the influence of leaf nitrogen per leaf mass on grazer preference",
        β_GRZ_H = "Controls the influence of height on grazer preference",
        η_GRZ = "Scaling factor that controls at which biomass density additional feed is supplied by farmers, fixed for calibration",
        κ_GRZ = "Consumption of dry biomass per livestock and day",
        ϵ_GRZ_minH = "Minimum height that is reachable by grazers",
        
        β_SND_WHC = "Slope parameter relating the sand content to the soil water content at the water holding capacity",
        β_SLT_WHC = "Slope parameter relating the silt content to the soil water content at the water holding capacity",
        β_CLY_WHC = "Slope parameter relating the clay content to the soil water content at the water holding capacity",
        β_OM_WHC = "Slope parameter relating the organic matter content to the soil water content at the water holding capacity",
        β_BLK_WHC = "Slope parameter relating the bulk density to the soil water content at the water holding capacity",
        β_SND_PWP = "Slope parameter relating the sand content to the soil water content at the permanent wilting point",
        β_SLT_PWP = "Slope parameter relating the silt content to the soil water content at the permanent wilting point",
        β_CLY_PWP = "Slope parameter relating the clay content to the soil water content at the permanent wilting point",
        β_OM_PWP = "Slope parameter relating the organic matter content to the soil water content at the permanent wilting point",
        β_BLK_PWP = "Slope parameter relating the bulk density to the soil water content at the permanent wilting point"
    )

    p = sim.optim_parameter()
    p_keys = collect(keys(p))
    p_values = collect(values(p))
    p_descriptions = [haskey(param_description, k) ? param_description[k] : "TODO" for k in p_keys]
    data = hcat(p_keys, p_values, p_descriptions)
    
    
    if any(keys(param_description) .∉ Ref(p_keys))
      p_documented = collect(keys(param_description))[collect(keys(param_description) .∉ Ref(p_keys))]
      @info "Following keys documented: $p_documented but not part of the GrasslandTraitSim.jl model"
    end
  
    str = pretty_table(String, data; alignment = [:r, :l, :l], header = ["Parameter", "Value", "Description"], backend = Val(:markdown))
    return str
end

Markdown.parse(parameter_doc())
```

## Which method uses a parameter?

| **Parameter**         | **Used in...**                                                                                 |
|----------------------:|-----------------------------------------------------------------------------------------------:|
| ϕ\_TRSA               | [\`root\_investment!\`](@ref); [\`nutrient\_reduction!\`](@ref); [\`water\_reduction!\`](@ref) |
| ϕ\_TAMC               | [\`root\_investment!\`](@ref); [\`nutrient\_reduction!\`](@ref)                                |
| ϕ\_sla                | [\`initialize\_senescence\_rate!\`](@ref)                                                      |
| γ\_RUEmax             | [\`potential\_growth!\`](@ref)                                                                 |
| γ\_RUE\_k             | [\`light\_competition\_height\_layer!\`](@ref); [\`potential\_growth!\`](@ref)                 |
| α\_RUE\_cwmH          | [\`potential\_growth!\`](@ref)                                                                 |
| α\_WAT\_rsa05         | [\`water\_reduction!\`](@ref)                                                                  |
| β\_WAT\_rsa           | [\`water\_reduction!\`](@ref)                                                                  |
| δ\_WAT\_rsa           | [\`water\_reduction!\`](@ref)                                                                  |
| ω\_NUT\_totalN        | [\`input\_nutrients!\`](@ref)                                                                  |
| ω\_NUT\_fertilization | [\`input\_nutrients!\`](@ref)                                                                  |
| β\_TS                 | [\`similarity\_matrix!\`](@ref)                                                                |
| α\_NUT\_TSB           | [\`nutrient\_competition!\`](@ref)                                                             |
| α\_NUT\_maxadj        | [\`nutrient\_competition!\`](@ref)                                                             |
| α\_NUT\_amc05         | [\`nutrient\_reduction!\`](@ref)                                                               |
| α\_NUT\_rsa05         | [\`nutrient\_reduction!\`](@ref)                                                               |
| β\_NUT\_rsa           | [\`nutrient\_reduction!\`](@ref)                                                               |
| β\_NUT\_amc           | [\`nutrient\_reduction!\`](@ref)                                                               |
| δ\_NUT\_rsa           | [\`nutrient\_reduction!\`](@ref)                                                               |
| δ\_NUT\_amc           | [\`nutrient\_reduction!\`](@ref)                                                               |
| κ\_ROOT\_amc          | [\`root\_investment!\`](@ref)                                                                  |
| κ\_ROOT\_rsa          | [\`root\_investment!\`](@ref)                                                                  |
| γ\_RAD1               | [\`radiation\_reduction!\`](@ref)                                                              |
| γ\_RAD2               | [\`radiation\_reduction!\`](@ref)                                                              |
| ω\_TEMP\_T1           | [\`temperature\_reduction!\`](@ref)                                                            |
| ω\_TEMP\_T2           | [\`temperature\_reduction!\`](@ref)                                                            |
| ω\_TEMP\_T3           | [\`temperature\_reduction!\`](@ref)                                                            |
| ω\_TEMP\_T4           | [\`temperature\_reduction!\`](@ref)                                                            |
| ζ\_SEA\_ST1           | [\`seasonal\_reduction!\`](@ref)                                                               |
| ζ\_SEA\_ST2           | [\`seasonal\_reduction!\`](@ref)                                                               |
| ζ\_SEAmin             | [\`seasonal\_reduction!\`](@ref)                                                               |
| ζ\_SEAmax             | [\`seasonal\_reduction!\`](@ref)                                                               |
| α\_SEN                | [\`initialize\_senescence\_rate!\`](@ref)                                                      |
| β\_SEN\_sla           | [\`initialize\_senescence\_rate!\`](@ref)                                                      |
| ψ\_SEN\_ST1           | [\`seasonal\_component\_senescence\`](@ref)                                                    |
| ψ\_SEN\_ST2           | [\`seasonal\_component\_senescence\`](@ref)                                                    |
| ψ\_SENmax             | [\`seasonal\_component\_senescence\`](@ref)                                                    |
| β\_GRZ\_lnc           | [\`grazing!\`](@ref)                                                                           |
| β\_GRZ\_H             | [\`grazing!\`](@ref)                                                                           |
| η\_GRZ                | [\`grazing!\`](@ref)                                                                           |
| κ\_GRZ                | [\`grazing!\`](@ref)                                                                           |
| ϵ\_GRZ\_minH          | [\`grazing!\`](@ref)                                                                           |
| β\_SND\_WHC           | [\`input\_WHC\_PWP!\`](@ref)                                                                   |
| β\_SLT\_WHC           | [\`input\_WHC\_PWP!\`](@ref)                                                                   |
| β\_CLY\_WHC           | [\`input\_WHC\_PWP!\`](@ref)                                                                   |
| β\_OM\_WHC            | [\`input\_WHC\_PWP!\`](@ref)                                                                   |
| β\_BLK\_WHC           | [\`input\_WHC\_PWP!\`](@ref)                                                                   |
| β\_SND\_PWP           | [\`input\_WHC\_PWP!\`](@ref)                                                                   |
| β\_SLT\_PWP           | [\`input\_WHC\_PWP!\`](@ref)                                                                   |
| β\_CLY\_PWP           | [\`input\_WHC\_PWP!\`](@ref)                                                                   |
| β\_OM\_PWP            | [\`input\_WHC\_PWP!\`](@ref)                                                                   |
| β\_BLK\_PWP           | [\`input\_WHC\_PWP!\`](@ref)                                                                   |

## How to change a parameter value

```@example
import GrasslandTraitSim as sim
using Unitful

# default parameter values
sim.SimulationParameter() 

# optimized/calibrated parameter values
sim.optim_parameter()

# you can change parameter values with keyword arguments, when you create the parameter object
p = sim.SimulationParameter(γ_RUE_k  = 0.65,  ϕ_TRSA = 0.05u"m^2 / g")

# or you can change the parameter values after the object is created
p.ϕ_TAMC = 0.1
p.ϕ_sla = 0.01u"m^2 / g"

p
```

## API

```@docs
SimulationParameter
```