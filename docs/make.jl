####### Build the documentation locally
# julia --project=docs/
# import Pkg; Pkg.develop(path="."); Pkg.instantiate(); include("docs/make.jl")
## to redo the documentation:
# include("docs/make.jl")
## to clean everything for commits/push:
# include("docs/clean_local_doc.jl")
# using DocumenterVitepress; DocumenterVitepress.dev_docs("build", md_output_path = "")

using CairoMakie
using Documenter, DocumenterVitepress
using DocumenterCitations
using GrasslandTraitSim

####### Set theme for all plots in documentation
makie_theme = Theme(fontsize = 18,
    Axis = (xgridvisible = false, ygridvisible = false,
        topspinevisible = false, rightspinevisible = false))
set_theme!(makie_theme)

####### Create bilbiography
bib = CitationBibliography("docs/src/lit.bib"; style = :numeric)

####### Create documentation
makedocs(;
    draft = false,
    warnonly  = true,
    # clean = false,
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
            "Plant height dynamics" => [
                "Dynamics" => "model/height/index.md"
            ],
            "Soil water dynamics" => [
                "Dynamics" => "model/water/index.md"
        ]],
        "Visualization" => [
            "Dashboard" => "viz/dashboard.md",
            "Visualize model components" => "viz/variables.md",
            "Varying the time step" => "viz/time_step.md",],
        "References" => "references.md"])

deploydocs(repo = "github.com/FelixNoessler/GrasslandTraitSim.jl",
           devbranch="master",
           branch = "gh-pages",
           target = "build")
