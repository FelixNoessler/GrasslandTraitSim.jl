


# Parameter in the model {#Parameter-in-the-model}

```julia
import GrasslandTraitSim as sim
sim.parameter_doc(; html = true)
```

<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: right;">Parameter</th>
      <th style = "text-align: left;">Value</th>
      <th style = "text-align: left;">Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">ϕ_TRSA</td>
      <td style = "text-align: left;">0.0683575 m^2 g^-1</td>
      <td style = "text-align: left;">Reference root surace area</td>
    </tr>
    <tr>
      <td style = "text-align: right;">ϕ_TAMC</td>
      <td style = "text-align: left;">0.108293</td>
      <td style = "text-align: left;">Reference arbuscular mycorriza colonisation rate</td>
    </tr>
    <tr>
      <td style = "text-align: right;">ϕ_sla</td>
      <td style = "text-align: left;">0.008808 m^2 g^-1</td>
      <td style = "text-align: left;">Reference specific leaf area</td>
    </tr>
    <tr>
      <td style = "text-align: right;">γ_RUEmax</td>
      <td style = "text-align: left;">0.003 kg MJ^-1</td>
      <td style = "text-align: left;">Maximum radiation use efficiency</td>
    </tr>
    <tr>
      <td style = "text-align: right;">γ_RUE_k</td>
      <td style = "text-align: left;">0.6</td>
      <td style = "text-align: left;">Extinction coefficient</td>
    </tr>
    <tr>
      <td style = "text-align: right;">α_RUE_cwmH</td>
      <td style = "text-align: left;">0.998592</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">β_LIG_H</td>
      <td style = "text-align: left;">NaN</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">α_WAT_rsa05</td>
      <td style = "text-align: left;">0.822698</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">β_WAT_rsa</td>
      <td style = "text-align: left;">8.12609</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">δ_WAT_rsa</td>
      <td style = "text-align: left;">1.60378 g m^-2</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">α_NUT_Nmax</td>
      <td style = "text-align: left;">35.0 g kg^-1</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">α_NUT_TSB</td>
      <td style = "text-align: left;">5001.26 kg ha^-1</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">α_NUT_maxadj</td>
      <td style = "text-align: left;">10.0</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">α_NUT_amc05</td>
      <td style = "text-align: left;">0.700429</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">α_NUT_rsa05</td>
      <td style = "text-align: left;">0.959764</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">β_NUT_rsa</td>
      <td style = "text-align: left;">8.13689</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">β_NUT_amc</td>
      <td style = "text-align: left;">15.9892</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">δ_NUT_rsa</td>
      <td style = "text-align: left;">10.3304 g m^-2</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">δ_NUT_amc</td>
      <td style = "text-align: left;">15.0</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">κ_ROOT_amc</td>
      <td style = "text-align: left;">0.0723991</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">κ_ROOT_rsa</td>
      <td style = "text-align: left;">0.00761945</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">γ_RAD1</td>
      <td style = "text-align: left;">4.45e-6 ha MJ^-1</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">γ_RAD2</td>
      <td style = "text-align: left;">50000.0 MJ ha^-1</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">ω_TEMP_T1</td>
      <td style = "text-align: left;">4.0 °C</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">ω_TEMP_T2</td>
      <td style = "text-align: left;">10.0 °C</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">ω_TEMP_T3</td>
      <td style = "text-align: left;">20.0 °C</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">ω_TEMP_T4</td>
      <td style = "text-align: left;">35.0 °C</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">ζ_SEA_ST1</td>
      <td style = "text-align: left;">787.414 °C</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">ζ_SEA_ST2</td>
      <td style = "text-align: left;">1800.0 °C</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">ζ_SEAmin</td>
      <td style = "text-align: left;">0.987514</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">ζ_SEAmax</td>
      <td style = "text-align: left;">2.44419</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">α_SEN</td>
      <td style = "text-align: left;">0.0452193</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">β_SEN_sla</td>
      <td style = "text-align: left;">1.41955</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">ψ_SEN_ST1</td>
      <td style = "text-align: left;">1765.52 °C</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">ψ_SEN_ST2</td>
      <td style = "text-align: left;">3000.0 °C</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">ψ_SENmax</td>
      <td style = "text-align: left;">1.55784</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">β_GRZ_lnc</td>
      <td style = "text-align: left;">0.578292</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">β_GRZ_H</td>
      <td style = "text-align: left;">0.0563242</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">η_GRZ</td>
      <td style = "text-align: left;">2.0</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">κ_GRZ</td>
      <td style = "text-align: left;">22.0 kg</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">ϵ_GRZ_minH</td>
      <td style = "text-align: left;">0.05 m</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">β_SND_WHC</td>
      <td style = "text-align: left;">0.5678</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">β_SLT_WHC</td>
      <td style = "text-align: left;">0.9228</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">β_CLY_WHC</td>
      <td style = "text-align: left;">0.9135</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">β_OM_WHC</td>
      <td style = "text-align: left;">0.6103</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">β_BLK_WHC</td>
      <td style = "text-align: left;">-0.2696 cm^3 g^-1</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">β_SND_PWP</td>
      <td style = "text-align: left;">-0.0059</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">β_SLT_PWP</td>
      <td style = "text-align: left;">0.1142</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">β_CLY_PWP</td>
      <td style = "text-align: left;">0.5766</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">β_OM_PWP</td>
      <td style = "text-align: left;">0.2228</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
    <tr>
      <td style = "text-align: right;">β_BLK_PWP</td>
      <td style = "text-align: left;">0.02671 cm^3 g^-1</td>
      <td style = "text-align: left;">TODO</td>
    </tr>
  </tbody>
</table>


## Which method uses a parameter? {#Which-method-uses-a-parameter?}
<details>
<summary>show code</summary>


```julia
import GrasslandTraitSim as sim
using Glob
using PrettyTables

function read_files_to_string(directory::String)
    file_paths = [
        glob("**/**/**/*.jl", directory)...,
        glob("**/**/*.jl", directory)...,
        glob("**/*.jl", directory)...,
        glob("*.jl", directory)...]

    all_contents = ""

    for file_path in file_paths
        all_contents *= read(file_path, String) * "\n\n\n\n"
    end

    return all_contents
end

let
    contents = read_files_to_string(dirname(pathof(sim)))
    create_regex = x -> Regex("function $x\\(.*?\\n(.*?\\n)*?end")

    prep_method = names(sim, all = true)
    f1 = [isa(getfield(sim, n), Function) for n in prep_method]
    f2 = .! startswith.(String.(prep_method), "#")
    f3 = .! startswith.(String.(prep_method), "plot")
    f4 = .! startswith.(String.(prep_method), "initialization")
    f5 = .! startswith.(String.(prep_method), "parameter_doc")

    method_names = String.(prep_method[f1 .&& f2 .&& f3 .&& f4 .&& f5])

    methods_dict = Dict{String, String}()
    for method_name in method_names
        method_match = match(create_regex(method_name), contents)
        if method_match !== nothing
            methods_dict[method_name] = method_match.match
        end
    end

    pnames = String.(keys(sim.SimulationParameter()))

    p_in_methods = []
    for pname in pnames 
        p_functions = String[]             
        for k in keys(methods_dict)
            if occursin(pname, methods_dict[k])
                push!(p_functions, k)
            end
        end

        fun_format = join(["[`$f`](@ref); " for f in p_functions])[1:end-2]
        push!(p_in_methods, fun_format) 
    end

    pretty_table([collect(pnames) p_in_methods]; 
                header = ["Parameter", "Used in..."],       
                backend = Val(:markdown))
end
```

</details>


| **Parameter** |                                                                                                                                                                                                                                                                                                                **Used in...** |
| -------------:| -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
|         ϕ_rsa | [`root_investment!`](/model/biomass/growth_species_specific_roots#GrasslandTraitSim.root_investment!); [`nutrient_reduction!`](/model/biomass/growth_species_specific_nutrients#GrasslandTraitSim.nutrient_reduction!); [`water_reduction!`](/model/biomass/growth_species_specific_water#GrasslandTraitSim.water_reduction!) |
|         ϕ_amc |                                                                                                        [`root_investment!`](/model/biomass/growth_species_specific_roots#GrasslandTraitSim.root_investment!); [`nutrient_reduction!`](/model/biomass/growth_species_specific_nutrients#GrasslandTraitSim.nutrient_reduction!) |
|         ϕ_sla |                                                                                                                                                                                                                      [`initialize_senescence_rate!`](/model/biomass/senescence#GrasslandTraitSim.initialize_senescence_rate!) |
|      γ_RUEmax |                                                                                                                                                                                                                             [`potential_growth!`](/model/biomass/growth_potential_growth#GrasslandTraitSim.potential_growth!) |
|       γ_RUE_k |                                                                                        [`light_competition_height_layer!`](/model/biomass/growth_species_specific_light#GrasslandTraitSim.light_competition_height_layer!); [`potential_growth!`](/model/biomass/growth_potential_growth#GrasslandTraitSim.potential_growth!) |
|    α_RUE_cwmH |                                                                                                                                                                                                                             [`potential_growth!`](/model/biomass/growth_potential_growth#GrasslandTraitSim.potential_growth!) |
|       β_LIG_H |                                                                                                                                                                                                       [`light_competition_simple!`](/model/biomass/growth_species_specific_light#GrasslandTraitSim.light_competition_simple!) |
|   α_WAT_rsa05 |                                                                                                                                                                                                                         [`water_reduction!`](/model/biomass/growth_species_specific_water#GrasslandTraitSim.water_reduction!) |
|     β_WAT_rsa |                                                                                                                                                                                                                         [`water_reduction!`](/model/biomass/growth_species_specific_water#GrasslandTraitSim.water_reduction!) |
|     δ_WAT_rsa |                                                                                                                                                                                                                         [`water_reduction!`](/model/biomass/growth_species_specific_water#GrasslandTraitSim.water_reduction!) |
|    α_NUT_Nmax |                                                                                                                                                                                                                     [`input_nutrients!`](/model/biomass/growth_species_specific_nutrients#GrasslandTraitSim.input_nutrients!) |
|     α_NUT_TSB |                                                                                                                                                                                                           [`nutrient_competition!`](/model/biomass/growth_species_specific_nutrients#GrasslandTraitSim.nutrient_competition!) |
|  α_NUT_maxadj |                                                                                                                                                                                                           [`nutrient_competition!`](/model/biomass/growth_species_specific_nutrients#GrasslandTraitSim.nutrient_competition!) |
|   α_NUT_amc05 |                                                                                                                                                                                                               [`nutrient_reduction!`](/model/biomass/growth_species_specific_nutrients#GrasslandTraitSim.nutrient_reduction!) |
|   α_NUT_rsa05 |                                                                                                                                                                                                               [`nutrient_reduction!`](/model/biomass/growth_species_specific_nutrients#GrasslandTraitSim.nutrient_reduction!) |
|     β_NUT_rsa |                                                                                                                                                                                                               [`nutrient_reduction!`](/model/biomass/growth_species_specific_nutrients#GrasslandTraitSim.nutrient_reduction!) |
|     β_NUT_amc |                                                                                                                                                                                                               [`nutrient_reduction!`](/model/biomass/growth_species_specific_nutrients#GrasslandTraitSim.nutrient_reduction!) |
|     δ_NUT_rsa |                                                                                                                                                                                                               [`nutrient_reduction!`](/model/biomass/growth_species_specific_nutrients#GrasslandTraitSim.nutrient_reduction!) |
|     δ_NUT_amc |                                                                                                                                                                                                               [`nutrient_reduction!`](/model/biomass/growth_species_specific_nutrients#GrasslandTraitSim.nutrient_reduction!) |
|    κ_ROOT_amc |                                                                                                                                                                                                                         [`root_investment!`](/model/biomass/growth_species_specific_roots#GrasslandTraitSim.root_investment!) |
|    κ_ROOT_rsa |                                                                                                                                                                                                                         [`root_investment!`](/model/biomass/growth_species_specific_roots#GrasslandTraitSim.root_investment!) |
|        γ_RAD1 |                                                                                                                                                                                                                            [`radiation_reduction!`](/model/biomass/growth_env_factors#GrasslandTraitSim.radiation_reduction!) |
|        γ_RAD2 |                                                                                                                                                                                                                            [`radiation_reduction!`](/model/biomass/growth_env_factors#GrasslandTraitSim.radiation_reduction!) |
|     ω_TEMP_T1 |                                                                                                                                                                                                                        [`temperature_reduction!`](/model/biomass/growth_env_factors#GrasslandTraitSim.temperature_reduction!) |
|     ω_TEMP_T2 |                                                                                                                                                                                                                        [`temperature_reduction!`](/model/biomass/growth_env_factors#GrasslandTraitSim.temperature_reduction!) |
|     ω_TEMP_T3 |                                                                                                                                                                                                                        [`temperature_reduction!`](/model/biomass/growth_env_factors#GrasslandTraitSim.temperature_reduction!) |
|     ω_TEMP_T4 |                                                                                                                                                                                                                        [`temperature_reduction!`](/model/biomass/growth_env_factors#GrasslandTraitSim.temperature_reduction!) |
|     ζ_SEA_ST1 |                                                                                                                                                                                                                              [`seasonal_reduction!`](/model/biomass/growth_env_factors#GrasslandTraitSim.seasonal_reduction!) |
|     ζ_SEA_ST2 |                                                                                                                                                                                                                              [`seasonal_reduction!`](/model/biomass/growth_env_factors#GrasslandTraitSim.seasonal_reduction!) |
|      ζ_SEAmin |                                                                                                                                                                                                                              [`seasonal_reduction!`](/model/biomass/growth_env_factors#GrasslandTraitSim.seasonal_reduction!) |
|      ζ_SEAmax |                                                                                                                                                                                                                              [`seasonal_reduction!`](/model/biomass/growth_env_factors#GrasslandTraitSim.seasonal_reduction!) |
|   α_SEN_month |                                                                                                                                                                                                                      [`initialize_senescence_rate!`](/model/biomass/senescence#GrasslandTraitSim.initialize_senescence_rate!) |
|     β_SEN_sla |                                                                                                                                                                                                                      [`initialize_senescence_rate!`](/model/biomass/senescence#GrasslandTraitSim.initialize_senescence_rate!) |
|     ψ_SEN_ST1 |                                                                                                                                                                                                                  [`seasonal_component_senescence`](/model/biomass/senescence#GrasslandTraitSim.seasonal_component_senescence) |
|     ψ_SEN_ST2 |                                                                                                                                                                                                                  [`seasonal_component_senescence`](/model/biomass/senescence#GrasslandTraitSim.seasonal_component_senescence) |
|      ψ_SENmax |                                                                                                                                                                                                                  [`seasonal_component_senescence`](/model/biomass/senescence#GrasslandTraitSim.seasonal_component_senescence) |
|     β_GRZ_lnc |                                                                                                                                                                                                                                                        [`grazing!`](/model/biomass/mowing_grazing#GrasslandTraitSim.grazing!) |
|       β_GRZ_H |                                                                                                                                                                                                                                                        [`grazing!`](/model/biomass/mowing_grazing#GrasslandTraitSim.grazing!) |
|         η_GRZ |                                                                                                                                                                                                                                                        [`grazing!`](/model/biomass/mowing_grazing#GrasslandTraitSim.grazing!) |
|         κ_GRZ |                                                                                                                                                                                                                                                        [`grazing!`](/model/biomass/mowing_grazing#GrasslandTraitSim.grazing!) |
|    ϵ_GRZ_minH |                                                                                                                                                                                                                                                        [`grazing!`](/model/biomass/mowing_grazing#GrasslandTraitSim.grazing!) |


## How to change a parameter value {#How-to-change-a-parameter-value}

```julia
import GrasslandTraitSim as sim
using Unitful

# default parameter values
sim.SimulationParameter()

# you can change parameter values with keyword arguments
sim.SimulationParameter(γ_RUE_k  = 0.65,  ϕ_TRSA = 0.05u"m^2 / g")
```


```
┌──────────────┬───────────────────┐
│    Parameter │ Value             │
├──────────────┼───────────────────┤
│       ϕ_TRSA │ 0.05 m^2 g^-1     │
│       ϕ_TAMC │ 0.2               │
│        ϕ_sla │ 0.009 m^2 g^-1    │
│     γ_RUEmax │ 0.003 kg MJ^-1    │
│      γ_RUE_k │ 0.65              │
│   α_RUE_cwmH │ 0.95              │
│      β_LIG_H │ 1.0               │
│  α_WAT_rsa05 │ 0.9               │
│    β_WAT_rsa │ 7.0               │
│    δ_WAT_rsa │ 20.0 g m^-2       │
│   α_NUT_Nmax │ 35.0 g kg^-1      │
│    α_NUT_TSB │ 15000.0 kg ha^-1  │
│ α_NUT_maxadj │ 10.0              │
│  α_NUT_amc05 │ 0.95              │
│  α_NUT_rsa05 │ 0.95              │
│    β_NUT_rsa │ 15.0              │
│    β_NUT_amc │ 15.0              │
│    δ_NUT_rsa │ 20.0 g m^-2       │
│    δ_NUT_amc │ 10.0              │
│   κ_ROOT_amc │ 0.02              │
│   κ_ROOT_rsa │ 0.01              │
│       γ_RAD1 │ 4.45e-6 ha MJ^-1  │
│       γ_RAD2 │ 50000.0 MJ ha^-1  │
│    ω_TEMP_T1 │ 4.0 °C            │
│    ω_TEMP_T2 │ 10.0 °C           │
│    ω_TEMP_T3 │ 20.0 °C           │
│    ω_TEMP_T4 │ 35.0 °C           │
│    ζ_SEA_ST1 │ 775.0 °C          │
│    ζ_SEA_ST2 │ 1450.0 °C         │
│     ζ_SEAmin │ 0.9               │
│     ζ_SEAmax │ 1.5               │
│        α_SEN │ 0.05              │
│    β_SEN_sla │ 1.5               │
│    ψ_SEN_ST1 │ 775.0 °C          │
│    ψ_SEN_ST2 │ 3000.0 °C         │
│     ψ_SENmax │ 1.5               │
│    β_GRZ_lnc │ 1.2               │
│      β_GRZ_H │ 2.0               │
│        η_GRZ │ 2.0               │
│        κ_GRZ │ 22.0 kg           │
│   ϵ_GRZ_minH │ 0.05 m            │
│    β_SND_WHC │ 0.5678            │
│    β_SLT_WHC │ 0.9228            │
│    β_CLY_WHC │ 0.9135            │
│     β_OM_WHC │ 0.6103            │
│    β_BLK_WHC │ -0.2696 cm^3 g^-1 │
│    β_SND_PWP │ -0.0059           │
│    β_SLT_PWP │ 0.1142            │
│    β_CLY_PWP │ 0.5766            │
│     β_OM_PWP │ 0.2228            │
│    β_BLK_PWP │ 0.02671 cm^3 g^-1 │
└──────────────┴───────────────────┘

```


## API
<details class='jldocstring custom-block' open>
<summary><a id='GrasslandTraitSim.SimulationParameter' href='#GrasslandTraitSim.SimulationParameter'><span class="jlbinding">GrasslandTraitSim.SimulationParameter</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



Parameter of the GrasslandTraitSim.jl model


[source](https://github.com/FelixNoessler/GrasslandTraitSim.jl/blob/083386dc75748e31525cf4ea66f74778601f0f0c/src/1_parameter/1_parameter.jl#L1)

</details>

