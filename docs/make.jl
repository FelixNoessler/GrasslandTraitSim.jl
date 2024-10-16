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

####### Copy files to docs folder
cp("README.md", "docs/src/basics.md"; force = true)
cp("assets/ECEM_2023_presentation.pdf",
   "docs/src/assets/ECEM_2023_presentation.pdf"; force = true)
cp("assets/Assembly_2024_presentation.pdf",
   "docs/src/assets/Assembly_2024_presentation.pdf"; force = true)
cp("assets/biomass_dynamic_overview.png",
   "docs/src/assets/biomass_dynamic_overview.png"; force = true)

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
    repo="https://github.com/FelixNoessler/GrasslandTraitSim.jl",
    format = MarkdownVitepress(;
        repo = "https://github.com/FelixNoessler/GrasslandTraitSim.jl",
        devurl = "dev",
        deploy_url = "FelixNoessler.github.io/GrasslandTraitSim.jl",
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
            "Model input and output" => "model/inputs_outputs.md",
            "Parameter" => "model/parameter.md",
            "Time step" => "model/time_step.md",
            "Difference equation" => "model/main_equations.md",
            "Initialization" => "model/initialization.md",
            "Plant dynamics" => [
                "Overview" => "model/plant/index.md",
                "Growth: overview" => "model/plant/growth.md",
                "Growth: potential growth" => "model/plant/growth_potential_growth.md",
                "Growth: community adjustment" => "model/plant/growth_env_factors.md",
                "Growth: species-specific adjustment" => "model/plant/growth_species_specific.md",
                "Senescence" => "model/plant/senescence.md",
                "Mowing and grazing" => "model/plant/mowing_grazing.md"],
            "Soil water dynamics" => [
                "Dynamics" => "model/water/index.md"
        ]],
        "Visualization" => [
            "Dashboard" => "viz/dashboard.md",
            "Visualize model components" => "viz/variables.md",
            "Create all figures in documentation" => "viz/create_all_doc_figures.md",],
        "References & Acknowledgements" => "references.md"])

deploydocs(repo = "github.com/FelixNoessler/GrasslandTraitSim.jl",
           devbranch="master",)
