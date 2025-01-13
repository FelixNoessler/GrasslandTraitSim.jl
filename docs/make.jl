####### Build the documentation locally
# julia --project=.
# import Pkg; Pkg.develop(path="."); Pkg.instantiate(); include("docs/make.jl")
## to clean everything for commits/push:
# include("docs/clean_local_doc.jl")
# using DocumenterVitepress; DocumenterVitepress.dev_docs("build", md_output_path = "")

using CairoMakie
using Glob
using Documenter, DocumenterVitepress
using DocumenterCitations
using GrasslandTraitSim
using PrettyTables
import Markdown


####### Set theme for all plots in documentation
makie_theme = Theme(fontsize = 18,
    Axis = (xgridvisible = false, ygridvisible = false,
        topspinevisible = false, rightspinevisible = false))
set_theme!(makie_theme)

####### Create bilbiography
bib = CitationBibliography("docs/src/lit.bib"; style = :authoryear)

####### Cross-referencing for parameter
function parameter_in_methods()
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

    contents = read_files_to_string(dirname(pathof(GrasslandTraitSim)))
    create_regex = x -> Regex("function $x\\(.*?\\n(.*?\\n)*?end")

    prep_method = names(GrasslandTraitSim, all = true)
    prep_method = prep_method[prep_method .!== :measured_data]
    f1 = [isa(getfield(GrasslandTraitSim, n), Function) for n in prep_method]
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

    pnames = String.(keys(GrasslandTraitSim.SimulationParameter()))

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

    parameter_table_str = pretty_table(String, [collect(pnames) p_in_methods];
                header = ["Parameter", "Used in..."],
                backend = Val(:markdown))

    my_path = normpath(joinpath(Base.source_path(), "..", "src", "model", "parameter.md"))

    existing_content = readlines(my_path)
    existing_content = existing_content[.! startswith.(existing_content, "|")]
    my_line = 2 + findfirst(existing_content .== "## Which method uses a parameter?")

    table_lines = split(parameter_table_str, '\n')
    new_lines = vcat(existing_content[1:my_line-1], table_lines, existing_content[my_line+1:end])

    open(my_path, "w") do file
        write(file, join(new_lines, "\n"))
    end

    return nothing
end

parameter_in_methods()

####### Create documentation
makedocs(;
    draft = false,
    warnonly  = true,
    clean = true,
    plugins = [bib],
    sitename = "GrasslandTraitSim.jl",
    modules = [GrasslandTraitSim],
    authors="Felix Nößler",
    source = "src",
    build = "build",
    format = MarkdownVitepress(;
        repo = "github.com/FelixNoessler/GrasslandTraitSim.jl",
        devurl = "dev",
        devbranch = "master",
        # md_output_path = ".",
        # build_vitepress = false
    ),
    pages = [
        "Home" => "index.md",
        "Getting Started" => "basics.md",
        "Tutorials" => [
            "Prepare input and run simulation" => "tutorials/how_to_prepare_input.md",
            "Analyse model output" => "tutorials/how_to_analyse_output.md",
            "Heterogenous site or management conditions" => "tutorials/how_to_heterogeneous_site_management.md",
            "Turn-off subprocesses" => "tutorials/how_to_turnoff_subprocesses.md",],
        "Model description" => [
            "Overview" => "model/index.md",
            "Model inputs" => "model/inputs.md",
            "Parameter" => "model/parameter.md",
            "Plant biomass dynamics" => [
                "Overview" => "model/biomass/index.md",
                "Growth: overview" => "model/biomass/growth.md",
                "Growth: potential growth" => "model/biomass/growth_potential_growth.md",
                "Growth: community adjustment" => "model/biomass/growth_env_factors.md",
                "Growth: species-specific adjustment" => "model/biomass/growth_species_specific.md",
                "- for light" => "model/biomass/growth_species_specific_light.md",
                "- for soil water" => "model/biomass/growth_species_specific_water.md",
                "- for nutrients" => "model/biomass/growth_species_specific_nutrients.md",
                "- for investment into roots" => "model/biomass/growth_species_specific_roots.md",
                "Senescence" => "model/biomass/senescence.md",
                "Mowing and grazing" => "model/biomass/mowing_grazing.md"],
            "Plant height dynamics" => "model/height/index.md",
            "Soil water dynamics" => "model/water/index.md"],
        "Visualization" => [
            "Dashboard" => "viz/dashboard.md",
            "Visualize model components" => "viz/variables.md",
            "Varying the time step" => "viz/time_step.md",],
        "References" => "references.md"])

deploydocs(repo = "github.com/FelixNoessler/GrasslandTraitSim.jl",
           devbranch="master",
           branch = "gh-pages",
           target = "build")
