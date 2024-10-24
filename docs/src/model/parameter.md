```@meta
CurrentModule = GrasslandTraitSim
```

# Parameter in the model



## Which method uses a parameter?
```@raw html
<details>
<summary>show code</summary>
```

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

contents = read_files_to_string(dirname(pathof(sim)))
create_regex = x -> Regex("function $x\\(.*?\\n(.*?\\n)*?end")


prep_method = names(sim, all = true)
f1 = [isa(getfield(sim, n), Function) for n in prep_method]
f2 = .! startswith.(String.(prep_method), "#")
f3 = .! startswith.(String.(prep_method), "plot")
method_names = String.(prep_method[f1 .&& f2 .&& f3 ])

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

    if pname != "k"                
        for k in keys(methods_dict)
            if occursin(pname, methods_dict[k])
                push!(p_functions, k)
            end
        end
    else
        push!(p_functions, "potential_growth!")
    end
    
    fun_format = join(["[`$f`](@ref); " for f in p_functions])[1:end-2]
    push!(p_in_methods, fun_format) 
end

pretty_table([collect(pnames) p_in_methods]; 
             header = ["Parameter", "Used in..."],       
             backend = Val(:markdown))
```

```@raw html
</details>
```

| **Parameter**           | **Used in...**                                                                                               |
|------------------------:|-------------------------------------------------------------------------------------------------------------:|
| ϕ\_rsa                  | [\`root\_investment!\`](@ref); [\`nutrient\_reduction!\`](@ref); [\`water\_reduction!\`](@ref)               |
| ϕ\_amc                  | [\`root\_investment!\`](@ref); [\`nutrient\_reduction!\`](@ref)                                              |
| ϕ\_sla                  | [\`senescence\_rate!\`](@ref)                                                                                |
| RUE\_max                | [\`potential\_growth!\`](@ref)                                                                               |
| k                       | [\`potential\_growth!\`](@ref)                                                                               |
| self\_shading\_severity | [\`potential\_growth!\`](@ref)                                                                               |
| α\_wrsa\_05             | [\`water\_reduction!\`](@ref)                                                                                |
| β\_wrsa                 | [\`water\_reduction!\`](@ref)                                                                                |
| δ\_wrsa                 | [\`water\_reduction!\`](@ref); [\`initialization\`](@ref)                                                    |
| N\_max                  | [\`seasonal\_component\_senescence\`](@ref); [\`nutrient\_reduction!\`](@ref); [\`input\_nutrients!\`](@ref) |
| TSB\_max                | [\`nutrient\_competition!\`](@ref)                                                                           |
| TS\_influence           | [\`nutrient\_competition!\`](@ref)                                                                           |
| nutadj\_max             | [\`nutrient\_competition!\`](@ref)                                                                           |
| α\_namc\_05             | [\`nutrient\_reduction!\`](@ref)                                                                             |
| α\_nrsa\_05             | [\`nutrient\_reduction!\`](@ref)                                                                             |
| β\_nrsa                 | [\`nutrient\_reduction!\`](@ref)                                                                             |
| β\_namc                 | [\`nutrient\_reduction!\`](@ref)                                                                             |
| δ\_nrsa                 | [\`nutrient\_reduction!\`](@ref); [\`initialization\`](@ref)                                                 |
| δ\_namc                 | [\`nutrient\_reduction!\`](@ref); [\`initialization\`](@ref)                                                 |
| κ\_maxred\_amc          | [\`root\_investment!\`](@ref)                                                                                |
| κ\_maxred\_srsa         | [\`root\_investment!\`](@ref)                                                                                |
| γ₁                      | [\`radiation\_reduction!\`](@ref)                                                                            |
| γ₂                      | [\`radiation\_reduction!\`](@ref)                                                                            |
| T₀                      | [\`temperature\_reduction!\`](@ref)                                                                          |
| T₁                      | [\`seasonal\_reduction!\`](@ref); [\`temperature\_reduction!\`](@ref)                                        |
| T₂                      | [\`seasonal\_reduction!\`](@ref); [\`temperature\_reduction!\`](@ref)                                        |
| T₃                      | [\`temperature\_reduction!\`](@ref)                                                                          |
| ST₁                     | [\`seasonal\_reduction!\`](@ref)                                                                             |
| ST₂                     | [\`seasonal\_reduction!\`](@ref)                                                                             |
| SEA\_min                | [\`seasonal\_reduction!\`](@ref)                                                                             |
| SEA\_max                | [\`seasonal\_reduction!\`](@ref)                                                                             |
| α\_sen\_month           | [\`senescence\_rate!\`](@ref)                                                                                |
| β\_sen\_sla             | [\`senescence\_rate!\`](@ref)                                                                                |
| Ψ₁                      | [\`seasonal\_component\_senescence\`](@ref)                                                                  |
| Ψ₂                      | [\`seasonal\_component\_senescence\`](@ref)                                                                  |
| SEN\_max                | [\`seasonal\_component\_senescence\`](@ref)                                                                  |
| β\_PAL\_lnc             | [\`grazing!\`](@ref)                                                                                         |
| β\_height\_GRZ          | [\`grazing!\`](@ref)                                                                                         |
| η\_GRZ                  | [\`grazing!\`](@ref)                                                                                         |
| κ                       | [\`root\_investment!\`](@ref); [\`grazing!\`](@ref)                                                          |




## How to change a parameter value

```@example
import GrasslandTraitSim as sim
using Unitful

# default parameter values
sim.SimulationParameter() 

# you can change parameter values with keyword arguments
sim.SimulationParameter(k = 0.65,  ϕ_rsa = 0.05u"m^2 / g")
```

## API

```@docs
SimulationParameter
```

