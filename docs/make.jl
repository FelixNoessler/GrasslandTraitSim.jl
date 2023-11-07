####### build the documentation locally
# julia --project=docs/ --startup-file=no
# using Revise; import Pkg; Pkg.instantiate(); Pkg.develop(path="."); include("docs/make.jl")
## to redo the documentation:
# include("docs/make.jl")
## to clean everything for commits/push:
# include("docs/clean_local_doc.jl")

using Documenter
using DocumenterCitations
using GrasslandTraitSim

import GrasslandTraitSim as sim
import GrasslandTraitSim.Valid as valid
import GrasslandTraitSim.Vis as vis

####### Create Bilbiography
bib = CitationBibliography("docs/src/lit.bib"; style = :numeric)

####### create images for the document
docs_img = "docs/src/img"

#### functional response
vis.potential_growth(sim, valid; path = "$docs_img/sla_potential_growth.svg")
vis.rsa_above_water_response(sim, valid;
    path = "$docs_img/rsa_above_water_response.svg",
    max_rsa_above_water_reduction = 1)
vis.rsa_above_water_response(sim, valid;
    path = "$docs_img/rsa_above_water_response_0_5.svg",
    max_rsa_above_water_reduction = 0.5)
vis.rsa_above_nut_response(sim, valid;
    path = "$docs_img/rsa_above_nut_response.svg",
    max_rsa_above_nut_reduction = 1)
vis.rsa_above_nut_response(sim, valid;
    path = "$docs_img/rsa_above_nut_response_0_5.svg",
    max_rsa_above_nut_reduction = 0.5)
vis.amc_nut_response(sim, valid;
    path = "$docs_img/amc_nut_response.svg",
    max_AMC_nut_reduction = 1)
vis.amc_nut_response(sim, valid;
    path = "$docs_img/amc_nut_response_0_5.svg",
    max_AMC_nut_reduction = 0.5)
vis.sla_water_response(sim, valid;
    path = "$docs_img/sla_water_response.svg",
    max_SLA_water_reduction = 1.0)
vis.sla_water_response(sim, valid;
    path = "$docs_img/sla_water_response_0_5.svg",
    max_SLA_water_reduction = 0.5)

#### reducer functions
vis.temperatur_reducer(sim; path = "$docs_img/temperature_reducer.svg")
vis.radiation_reducer(sim; path = "$docs_img/radiation_reducer.svg")
vis.height_influence(sim, valid; path = "$docs_img/height_influence.svg")
vis.below_influence(sim, valid; path = "$docs_img/below_influence.svg")

#### seasonal effects
vis.seasonal_effect(sim; path = "$docs_img/seasonal_reducer.svg")
vis.seasonal_component_senescence(sim;
    path = "$docs_img/seasonal_factor_senescence.svg")

#### land use
vis.mowing(sim, valid; path = "$docs_img/mowing.svg")
vis.mow_factor(; path = "$docs_img/mow_factor.svg")
vis.grazing(sim, valid;
    leafnitrogen_graz_exp = 1.5,
    path = "$docs_img/grazing_1_5.svg")
vis.grazing(sim, valid;
    leafnitrogen_graz_exp = 5,
    path = "$docs_img/grazing_5.svg")
vis.grazing_half_factor(; path = "$docs_img/grazing_half_factor.svg")
vis.trampling(sim, valid; path = "$docs_img/trampling.svg")

## with patches
vis.planar_gradient(sim; path = "$docs_img/gradient.svg")
vis.neighbours_surroundings(sim, valid; path = "$docs_img/neighbours.svg")
vis.plot_clonalgrowth(sim; path = "$docs_img/clonalgrowth.svg")

# for prettyurls you need locally a live server
makedocs(;
    plugins = [bib],
    sitename = "GrasslandTraitSim.jl",
    format = Documenter.HTML(prettyurls = true, mathengine = MathJax3()),
    modules = [GrasslandTraitSim, GrasslandTraitSim.Valid, GrasslandTraitSim.Vis],
    pages = Any["Home" => "index.md",
        "Model input and output" => "model_io.md",
        "Parameter" => "parameter.md",
        "Tutorials" => Any["Prepare input and run simulation" => "tutorials/how_to_prepare_input.md",
            "Analyse model output" => "tutorials/how_to_analyse_output.md"],
        "Model description" => Any["Difference equation" => "Modelling_API/main_equations.md",
            "Initialization" => "Modelling_API/initialization.md",
            "Growth" => "Modelling_API/growth.md",
            "Water dynamics" => "Modelling_API/water.md",
            "Functional response" => "Modelling_API/functional_response.md"],
        "Calibration to grasslands of the Biodiversity Exploratories" => Any["Calibration data" => "biodiversity_exploratories/calibration_data.md",
            "Likelihood" => "biodiversity_exploratories/likelihood.md",
            "Priors" => "biodiversity_exploratories/priors.md"],
        "TOC all functions" => "all_functions.md",
        "References" => "References.md"])

deploydocs(repo = "github.com/FelixNoessler/GrasslandTraitSim.jl.git")
