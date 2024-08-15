####### build the documentation locally
# julia --project=docs/
# import Pkg; Pkg.develop(path="."); Pkg.instantiate(); include("docs/make.jl")
## to redo the documentation:
# include("docs/make.jl")
## to clean everything for commits/push:
# include("docs/clean_local_doc.jl")

using Documenter
using DocumenterCitations
using GrasslandTraitSim

####### Copy files to docs folder
cp("README.md", "docs/src/index.md"; force = true)
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
    warnonly  = true,
    plugins = [bib],
    sitename = "GrasslandTraitSim.jl",
    modules = [GrasslandTraitSim],
    format = Documenter.HTML(;
        canonical = "https://FelixNoessler.github.io/GrasslandTraitSim.jl",
        edit_link = "master",
        prettyurls = true,
        mathengine = MathJax3()
    ),
    pages = [
        "Home" => "index.md",
        "Model input and output" => "model_io.md",
        "Parameter" => "parameter.md",
        "Dashboard" => "dashboard.md",
        "Visualize model components" => "variables.md",
        "Time step" => "time_step.md",
        "Tutorials" => [
            "Prepare input and run simulation" => "tutorials/how_to_prepare_input.md",
            "Analyse model output" => "tutorials/how_to_analyse_output.md",
            "Heterogenous site or management conditions" => "tutorials/how_to_heterogeneous_site_management.md",
            "Turn-off subprocesses" => "tutorials/how_to_turnoff_subprocesses.md",],
        "Model description" => [
            "Difference equation" => "Modelling_API/main_equations.md",
            "Initialization" => "Modelling_API/initialization.md",
            "Biomass dynamic" => [
                "Overview" => "Modelling_API/biomass_dynamic.md",
                "Growth: overview" => "Modelling_API/growth.md",
                "Growth: potential growth" => "Modelling_API/growth_potential_growth.md",
                "Growth: community adjustment" => "Modelling_API/growth_env_factors.md",
                "Growth: species-specific adjustment" => "Modelling_API/growth_species_specific.md",
                "Senescence" => "Modelling_API/senescence.md",
                "Mowing and grazing" => "Modelling_API/defoliation.md"],
            "Water dynamics" => "Modelling_API/water.md"],

        "TOC all functions" => "all_functions.md",
        "Create all figures in documentation" => "create_all_doc_figures.md",
        "References & Acknowledgements" => "References.md"])

deploydocs(repo = "github.com/FelixNoessler/GrasslandTraitSim.jl",
           devbranch="master",)
