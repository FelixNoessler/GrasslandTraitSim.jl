```@meta
CurrentModule = GrasslandTraitSim
```

# Parameter in the model

```@eval
import GrasslandTraitSim as sim
import Markdown
using PrettyTables

function parameter_doc()
    param_description = (;
        ϕ_TRSA = "Reference root surface area per total biomass, used in nutrient stress function and maintenance costs for roots function, set to mean of community: ``\\phi_{TRSA} = \\text{mean}((1 - \\mathbf{abp}) \\cdot \\mathbf{rsa})``",
        ϕ_TAMC = "Reference arbuscular mycorriza colonisation rate per total biomass, used in nutrient stress function and maintenance costs for mycorrhizae function, set to mean of community: ``\\phi_{TAMC} = \\text{mean}((1 - \\mathbf{abp}) \\cdot \\mathbf{amc})``",
        ϕ_sla = "Reference specific leaf area, used in senescence function, set to mean of community: ``\\phi_{sla} = \\text{mean}(\\mathbf{sla})``",
        
        γ_RUEmax = "Maximum radiation use efficiency",
        γ_RUE_k =  "Light extinction coefficient",
        α_RUE_cwmH = "Reduction factor of radiation use efficiency at a height of 0.2 m ∈ [0, 1]",
        β_LIG_H = "Exponent that coontrols how strongly taller plants intercept more light than smaller plants",
        
        α_WAT_rsa05 = "Water stress growth reduction factor for species with mean trait: ``TRSA = \\phi_{TRSA}``, when the plant available water equals: ``W_{p,txy} = 0.5``",

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

let
    contents = read_files_to_string(dirname(pathof(sim)))
    create_regex = x -> Regex("function $x\\(.*?\\n(.*?\\n)*?end")

    prep_method = names(sim, all = true)
    f1 = [isa(getfield(sim, n), Function) for n in prep_method]
    f2 = .! startswith.(String.(prep_method), "#")
    f3 = .! startswith.(String.(prep_method), "plot")
    f4 = .! startswith.(String.(prep_method), "initialization")

    method_names = String.(prep_method[f1 .&& f2 .&& f3 .&& f4])

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

```@raw html
</details>
```

| **Parameter**  | **Used in...**                                                                                 |
|---------------:|-----------------------------------------------------------------------------------------------:|
| ϕ\_rsa         | [\`root\_investment!\`](@ref); [\`nutrient\_reduction!\`](@ref); [\`water\_reduction!\`](@ref) |
| ϕ\_amc         | [\`root\_investment!\`](@ref); [\`nutrient\_reduction!\`](@ref)                                |
| ϕ\_sla         | [\`initialize\_senescence\_rate!\`](@ref)                                                      |
| γ\_RUEmax      | [\`potential\_growth!\`](@ref)                                                                 |
| γ\_RUE\_k      | [\`light\_competition\_height\_layer!\`](@ref); [\`potential\_growth!\`](@ref)                 |
| α\_RUE\_cwmH   | [\`potential\_growth!\`](@ref)                                                                 |
| β\_LIG\_H      | [\`light\_competition\_simple!\`](@ref)                                                        |
| α\_WAT\_rsa05  | [\`water\_reduction!\`](@ref)                                                                  |
| β\_WAT\_rsa    | [\`water\_reduction!\`](@ref)                                                                  |
| δ\_WAT\_rsa    | [\`water\_reduction!\`](@ref)                                                                  |
| α\_NUT\_Nmax   | [\`input\_nutrients!\`](@ref)                                                                  |
| α\_NUT\_TSB    | [\`nutrient\_competition!\`](@ref)                                                             |
| α\_NUT\_maxadj | [\`nutrient\_competition!\`](@ref)                                                             |
| α\_NUT\_amc05  | [\`nutrient\_reduction!\`](@ref)                                                               |
| α\_NUT\_rsa05  | [\`nutrient\_reduction!\`](@ref)                                                               |
| β\_NUT\_rsa    | [\`nutrient\_reduction!\`](@ref)                                                               |
| β\_NUT\_amc    | [\`nutrient\_reduction!\`](@ref)                                                               |
| δ\_NUT\_rsa    | [\`nutrient\_reduction!\`](@ref)                                                               |
| δ\_NUT\_amc    | [\`nutrient\_reduction!\`](@ref)                                                               |
| κ\_ROOT\_amc   | [\`root\_investment!\`](@ref)                                                                  |
| κ\_ROOT\_rsa   | [\`root\_investment!\`](@ref)                                                                  |
| γ\_RAD1        | [\`radiation\_reduction!\`](@ref)                                                              |
| γ\_RAD2        | [\`radiation\_reduction!\`](@ref)                                                              |
| ω\_TEMP\_T1    | [\`temperature\_reduction!\`](@ref)                                                            |
| ω\_TEMP\_T2    | [\`temperature\_reduction!\`](@ref)                                                            |
| ω\_TEMP\_T3    | [\`temperature\_reduction!\`](@ref)                                                            |
| ω\_TEMP\_T4    | [\`temperature\_reduction!\`](@ref)                                                            |
| ζ\_SEA\_ST1    | [\`seasonal\_reduction!\`](@ref)                                                               |
| ζ\_SEA\_ST2    | [\`seasonal\_reduction!\`](@ref)                                                               |
| ζ\_SEAmin      | [\`seasonal\_reduction!\`](@ref)                                                               |
| ζ\_SEAmax      | [\`seasonal\_reduction!\`](@ref)                                                               |
| α\_SEN\_month  | [\`initialize\_senescence\_rate!\`](@ref)                                                      |
| β\_SEN\_sla    | [\`initialize\_senescence\_rate!\`](@ref)                                                      |
| ψ\_SEN\_ST1    | [\`seasonal\_component\_senescence\`](@ref)                                                    |
| ψ\_SEN\_ST2    | [\`seasonal\_component\_senescence\`](@ref)                                                    |
| ψ\_SENmax      | [\`seasonal\_component\_senescence\`](@ref)                                                    |
| β\_GRZ\_lnc    | [\`grazing!\`](@ref)                                                                           |
| β\_GRZ\_H      | [\`grazing!\`](@ref)                                                                           |
| η\_GRZ         | [\`grazing!\`](@ref)                                                                           |
| κ\_GRZ         | [\`grazing!\`](@ref)                                                                           |
| ϵ\_GRZ\_minH   | [\`grazing!\`](@ref)                                                                           |




## How to change a parameter value

```@example
import GrasslandTraitSim as sim
using Unitful

# default parameter values
sim.SimulationParameter() 

# you can change parameter values with keyword arguments
sim.SimulationParameter(γ_RUE_k  = 0.65,  ϕ_TRSA = 0.05u"m^2 / g")
```

## API

```@docs
SimulationParameter
```

