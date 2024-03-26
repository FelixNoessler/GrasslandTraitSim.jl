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

import GrasslandTraitSim as sim

####### Copy files to docs folder
cp("README.md", "docs/src/index.md"; force = true)
cp("assets/ECEM_2023_presentation.pdf",
   "docs/src/assets/ECEM_2023_presentation.pdf"; force = true)
cp("assets/Assembly_2024_presentation.pdf",
   "docs/src/assets/Assembly_2024_presentation.pdf"; force = true)
cp("assets/screenshot.png",
   "docs/src/assets/screenshot.png"; force = true)
cp("assets/biomass_dynamic_overview.png",
   "docs/src/assets/biomass_dynamic_overview.png"; force = true)

####### Create Bilbiography
bib = CitationBibliography("docs/src/lit.bib"; style = :numeric)

####### create images for the document
docs_img = "docs/src/img"
f(path; show_img = false) = show_img ? nothing : path

#### potential growth
sim.potential_growth_lai(; path = f("$docs_img/potential_growth_lai.svg"))
sim.potential_growth_lai_height(; path = f("$docs_img/potential_growth_lai_height.svg"))
sim.potential_growth_height_lai(; path = f("$docs_img/potential_growth_height_lai.svg"))
sim.potential_growth_par_lai(; path = f("$docs_img/potential_growth_par_lai.svg"))
sim.lai_traits(; path = f("$docs_img/lai_traits.svg"))
sim.potential_growth_height(; path = f("$docs_img/potential_growth_height.svg"))
sim.community_height_influence(; path = f("$docs_img/community_height_influence.svg"))

#### transfer functions
sim.W_rsa_response(; path = f("$docs_img/W_rsa_response.svg"), δ_wrsa = 1.0)
sim.W_rsa_response(; path = f("$docs_img/W_rsa_response_0_5.svg"), δ_wrsa = 0.5)
sim.rsa_above_nut_response(; path = f("$docs_img/rsa_above_nut_response.svg"),
                           δ_nrsa = 1.0)
sim.rsa_above_nut_response(; path = f("$docs_img/rsa_above_nut_response_0_5.svg"),
                           δ_nrsa = 0.5)
sim.amc_nut_response(; path = f("$docs_img/amc_nut_response.svg"), δ_amc = 1.0)
sim.amc_nut_response(; path = f("$docs_img/amc_nut_response_0_5.svg"), δ_amc = 0.5)
sim.W_sla_response(; path = f("$docs_img/W_sla_response.svg"), δ_sla = 1.0)
sim.W_sla_response(; path = f("$docs_img/W_sla_response_0_5.svg"), δ_sla = 0.5)
sim.plant_available_water(; path = f("$docs_img/pet.svg"))

#### leaf lifespan
sim.leaflifespan(; path = f("$docs_img/leaflifespan.svg"))

#### reducer functions
sim.temperatur_reducer(; path = f("$docs_img/temperature_reducer.svg"))
sim.radiation_reducer(; path = f("$docs_img/radiation_reducer.svg"))
sim.height_influence(; path = f("$docs_img/height_influence.svg"))
sim.below_influence(; path = f("$docs_img/below_influence.svg"))

#### seasonal effects
sim.seasonal_effect(; path = f("$docs_img/seasonal_reducer.svg"))
sim.plot_seasonal_component_senescence(;
    path = f("$docs_img/seasonal_factor_senescence.svg"))

#### land use
sim.mowing(; path = f("$docs_img/mowing.svg"))
sim.mow_factor(; path = f("$docs_img/mow_factor.svg"))
sim.grazing(; leafnitrogen_graz_exp = 1.5, path = f("$docs_img/grazing_1_5.svg"))
sim.grazing(; leafnitrogen_graz_exp = 5.0, path = f("$docs_img/grazing_5.svg"))
sim.grazing_half_factor(; path = f("$docs_img/grazing_half_factor.svg"))
sim.trampling_biomass(; path = f("$docs_img/trampling_biomass.svg"))
sim.trampling_livestockdensity(; path = f("$docs_img/trampling_LD.svg"))
sim.trampling_biomass_individual(; path = f("$docs_img/trampling_biomass_individual.svg"))

## with patches
sim.planar_gradient(; path = f("$docs_img/gradient.svg"))
# sim.neighbours_surroundings(; path = "$docs_img/neighbours.svg")
sim.plot_clonalgrowth(; path = f("$docs_img/clonalgrowth.svg"))

# for prettyurls you need locally a live server
makedocs(;
    plugins = [bib],
    sitename = "GrasslandTraitSim.jl",
    modules = [GrasslandTraitSim],
    format = Documenter.HTML(;
        canonical="https://FelixNoessler.github.io/GrasslandTraitSim.jl",
        edit_link="master",
        assets = String[],
        size_threshold = nothing,
        prettyurls = true,
        mathengine = MathJax3()
    ),
    pages = Any["Home" => "index.md",
        "Model input and output" => "model_io.md",
        "Parameter" => "parameter.md",
        "Tutorials" => Any[
            "Prepare input and run simulation" => "tutorials/how_to_prepare_input.md",
            "Analyse model output" => "tutorials/how_to_analyse_output.md",
            "Heterogenous site or management conditions" => "tutorials/how_to_heterogeneous_site_management.md" ],
        "Model description" => Any[
            "Difference equation" => "Modelling_API/main_equations.md",
            "Initialization" => "Modelling_API/initialization.md",
            "Biomass dynamic" => Any[
                "Overview" => "Modelling_API/biomass_dynamic.md",
                "Growth" => "Modelling_API/growth.md",
                "Senescence" => "Modelling_API/senescence.md",
                "Mowing, grazing, and trampling" => "Modelling_API/defoliation.md",
                "Clonal growth" => "Modelling_API/clonalgrowth.md",
            ],
            "Water dynamics" => "Modelling_API/water.md"],
        "Calibration to grasslands of the Biodiversity Exploratories" => Any[
            "Calibration data" => "biodiversity_exploratories/calibration_data.md",
            "Likelihood" => "biodiversity_exploratories/likelihood.md",
            "Priors" => "biodiversity_exploratories/priors.md"],
        "TOC all functions" => "all_functions.md",
        "References & Acknowledgements" => "References.md"])

deploydocs(repo = "github.com/FelixNoessler/GrasslandTraitSim.jl",
           devbranch="master",)
