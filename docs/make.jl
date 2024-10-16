####### build the documentation locally
# julia --project=docs/
# import Pkg; Pkg.develop(path="."); Pkg.instantiate(); include("docs/make.jl")
## to redo the documentation:
# include("docs/make.jl")
## to clean everything for commits/push:
# include("docs/clean_local_doc.jl")
# using DocumenterVitepress; DocumenterVitepress.dev_docs("build", md_output_path = "")

using Documenter, DocumenterVitepress
using DocumenterCitations
using GrasslandTraitSim

####### Create Bilbiography
bib = CitationBibliography("docs/src/lit.bib"; style = :numeric)

# for prettyurls you need locally a live server
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
            "Model input and output" => "model/inputs_outputs.md",
            "Parameter" => "model/parameter.md",
            "Time step" => "model/time_step.md",
            "Initialization" => "model/initialization.md",
            "Plant dynamics" => [
                "Overview" => "model/plant/index.md",
                "Growth: overview" => "model/plant/growth.md",
                "Growth: potential growth" => "model/plant/growth_potential_growth.md",
                "Growth: community adjustment" => "model/plant/growth_env_factors.md",
                "Growth: species-specific adjustment" => "model/plant/growth_species_specific.md",
                "- for light" => "model/plant/growth_species_specific_light.md",
                "- for soil water" => "model/plant/growth_species_specific_water.md",
                "- for nutrients" => "model/plant/growth_species_specific_nutrients.md",
                "- for investment into roots" => "model/plant/growth_species_specific_roots.md",
                "Senescence" => "model/plant/senescence.md",
                "Mowing and grazing" => "model/plant/mowing_grazing.md"],
            "Soil water dynamics" => [
                "Dynamics" => "model/water/index.md"
        ]],
        "Visualization" => [
            "Dashboard" => "viz/dashboard.md",
            "Visualize model components" => "viz/variables.md",],
        "References & Acknowledgements" => "references.md"])

deploydocs(repo = "github.com/FelixNoessler/GrasslandTraitSim.jl",
           devbranch="master",
           branch = "gh-pages",
           target = "build")
