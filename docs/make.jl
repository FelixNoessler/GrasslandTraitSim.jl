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
f(path; show_img = false) = show_img ? nothing : path

#### transfer functions
vis.potential_growth(sim, valid; path = f("$docs_img/sla_potential_growth.svg"))
vis.W_rsa_response(sim, valid;
    path = f("$docs_img/W_rsa_response.svg"),
    δ_wrsa = 1)
vis.W_rsa_response(sim, valid;
    path = f("$docs_img/W_rsa_response_0_5.svg"),
    δ_wrsa = 0.5)
vis.rsa_above_nut_response(sim, valid;
    path = f("$docs_img/rsa_above_nut_response.svg"),
    δ_nrsa = 1)
vis.rsa_above_nut_response(sim, valid;
    path = f("$docs_img/rsa_above_nut_response_0_5.svg"),
    δ_nrsa = 0.5)
vis.amc_nut_response(sim, valid;
    path = f("$docs_img/amc_nut_response.svg"),
    δ_amc = 1)
vis.amc_nut_response(sim, valid;
    path = f("$docs_img/amc_nut_response_0_5.svg"),
    δ_amc = 0.5)
vis.W_sla_response(sim, valid;
    path = f("$docs_img/W_sla_response.svg"),
    δ_sla = 1.0)
vis.W_sla_response(sim, valid;
    path = f("$docs_img/W_sla_response_0_5.svg"),
    δ_sla = 0.5)
vis.plant_available_water(sim, valid;
    path = f("$docs_img/pet.svg"))

#### leaf lifespan
vis.leaflifespan(sim, valid; path = f("$docs_img/leaflifespan.svg"))

#### reducer functions
vis.temperatur_reducer(sim; path = f("$docs_img/temperature_reducer.svg"))
vis.radiation_reducer(sim; path = f("$docs_img/radiation_reducer.svg"))
vis.height_influence(sim, valid; path = f("$docs_img/height_influence.svg"))
vis.below_influence(sim, valid; path = f("$docs_img/below_influence.svg"))

#### seasonal effects
vis.seasonal_effect(sim; path = f("$docs_img/seasonal_reducer.svg"))
vis.seasonal_component_senescence(sim;
    path = f("$docs_img/seasonal_factor_senescence.svg"))

#### land use
vis.mowing(sim, valid; path = f("$docs_img/mowing.svg"))
vis.mow_factor(; path = f("$docs_img/mow_factor.svg"))
vis.grazing(sim, valid;
    leafnitrogen_graz_exp = 1.5,
    path = f("$docs_img/grazing_1_5.svg"))
vis.grazing(sim, valid;
    leafnitrogen_graz_exp = 5,
    path = f("$docs_img/grazing_5.svg"))
vis.grazing_half_factor(; path = f("$docs_img/grazing_half_factor.svg"))
vis.trampling(sim, valid; path = f("$docs_img/trampling.svg"))

## with patches
vis.planar_gradient(sim; path = f("$docs_img/gradient.svg"))
# vis.neighbours_surroundings(sim, valid; path = "$docs_img/neighbours.svg")
vis.plot_clonalgrowth(sim, valid; path = f("$docs_img/clonalgrowth.svg"))

# for prettyurls you need locally a live server
makedocs(;
    plugins = [bib],
    sitename = "GrasslandTraitSim.jl",
    format = Documenter.HTML(prettyurls = true, mathengine = MathJax3()),
    modules = [GrasslandTraitSim, GrasslandTraitSim.Valid, GrasslandTraitSim.Vis],
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
        "References" => "References.md"])

deploydocs(repo = "github.com/FelixNoessler/GrasslandTraitSim.jl.git")
