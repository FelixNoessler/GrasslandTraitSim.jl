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
sim.potential_growth_lai_height(; path = f("$docs_img/potential_growth_lai_height.svg"))
sim.potential_growth_height_lai(; path = f("$docs_img/potential_growth_height_lai.svg"))
sim.potential_growth_height(; path = f("$docs_img/potential_growth_height.svg"))
sim.lai_traits(; path = f("$docs_img/lai_traits.svg"))
sim.community_height_influence(; path = f("$docs_img/community_height_influence.svg"))

#### transfer functions
sim.plot_W_rsa(; path = f("$docs_img/plot_W_rsa.svg"), δ_wrsa = 1.0)
sim.plot_W_rsa(; path = f("$docs_img/W_rsa_response_0_5.svg"), δ_wrsa = 0.5)
sim.plot_N_rsa(; path = f("$docs_img/plot_N_rsa.svg"),
                           δ_nrsa = 1.0)
sim.plot_N_rsa(; path = f("$docs_img/rsa_above_nut_response_0_5.svg"),
                           δ_nrsa = 0.5)
sim.plot_N_amc(; path = f("$docs_img/plot_N_amc.svg"), δ_amc = 1.0)
sim.plot_N_amc(; path = f("$docs_img/amc_nut_response_0_5.svg"), δ_amc = 0.5)
sim.plot_W_sla(; path = f("$docs_img/plot_W_sla.svg"), δ_sla = 1.0)
sim.plot_W_sla(; path = f("$docs_img/W_sla_response_0_5.svg"), δ_sla = 0.5)
sim.plant_available_water(; path = f("$docs_img/pet.svg"))
sim.plot_root_investment(; path = f("$docs_img/root_investment.svg"))

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
sim.grazing(; β_PAL_lnc = 1.5, path = f("$docs_img/grazing_1_5.svg"))
sim.grazing(; β_PAL_lnc = 5.0, path = f("$docs_img/grazing_5.svg"))
sim.α_GRZ(; path = f("$docs_img/α_GRZ.svg"))
sim.trampling_biomass(; path = f("$docs_img/trampling_biomass.svg"))
sim.trampling_livestockdensity(; path = f("$docs_img/trampling_LD.svg"))
sim.trampling_biomass_individual(; path = f("$docs_img/trampling_biomass_individual.svg"))

##  clonal growth
sim.plot_clonalgrowth(; path = f("$docs_img/clonalgrowth.svg"))
sim.animate_clonalgrowth(; path = f("$docs_img/clonalgrowth_animation.mp4"))

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
                "Mowing, grazing, and trampling" => "Modelling_API/defoliation.md",
                "Clonal growth" => "Modelling_API/clonalgrowth.md"],
            "Water dynamics" => "Modelling_API/water.md"],
        "Calibration to grasslands of the Biodiversity Exploratories" => [
            "Calibration data" => "biodiversity_exploratories/calibration_data.md",
            "Time step" => "biodiversity_exploratories/time_step.md",
            "Trait data" => "biodiversity_exploratories/traits.md",
            "Likelihood" => "biodiversity_exploratories/likelihood.md",
            "Priors" => "biodiversity_exploratories/priors.md"],
        "TOC all functions" => "all_functions.md",
        "References & Acknowledgements" => "References.md"])

deploydocs(repo = "github.com/FelixNoessler/GrasslandTraitSim.jl",
           devbranch="master",)
