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

####### load fitted parameter values
θ = nothing

####### Create Bilbiography
bib = CitationBibliography("docs/src/lit.bib"; style = :numeric)

####### create images for the document
docs_img = "docs/src/img"
f(path; show_img = false) = show_img ? nothing : path

#### potential growth
sim.plot_potential_growth_lai_height(; θ, path = f("$docs_img/potential_growth_lai_height.png"))
sim.plot_potential_growth_height_lai(; θ, path = f("$docs_img/potential_growth_height_lai.png"))
sim.plot_potential_growth_height(; θ, path = f("$docs_img/potential_growth_height.png"))
sim.plot_lai_traits(; θ, path = f("$docs_img/lai_traits.png"))
sim.plot_community_height_influence(; θ, path = f("$docs_img/community_height_influence.png"))

#### transfer functions
sim.plot_W_srsa(; θ, path = f("$docs_img/plot_W_srsa.png"), δ_wrsa = 1.0)
sim.plot_W_srsa(; θ, path = f("$docs_img/W_rsa_response_0_5.png"), δ_wrsa = 0.5)
sim.plot_W_sla(; θ, path = f("$docs_img/W_sla_response.png"), δ_sla = 1.0)
sim.plot_W_sla(; θ, path = f("$docs_img/W_sla_response_0_5.png"), δ_sla = 0.5)
sim.plot_N_srsa(; θ, path = f("$docs_img/plot_N_srsa.png"), δ_nrsa = 1.0)
sim.plot_N_srsa(; θ, path = f("$docs_img/rsa_above_nut_response_0_5.png"), δ_nrsa = 0.5)
sim.plot_N_amc(; θ, path = f("$docs_img/plot_N_amc.png"), δ_amc = 1.0)
sim.plot_N_amc(; θ, path = f("$docs_img/amc_nut_response_0_5.png"), δ_amc = 0.5)
sim.plot_root_investment(; θ, path = f("$docs_img/root_investment.png"))

#### leaf lifespan
sim.plot_leaflifespan(; θ, path = f("$docs_img/leaflifespan.png"))

#### reducer functions
sim.plot_temperatur_reducer(; θ, path = f("$docs_img/temperature_reducer.png"))
sim.plot_radiation_reducer(; θ, path = f("$docs_img/radiation_reducer.png"))
sim.plot_height_influence(; θ, path = f("$docs_img/height_influence.png"))
sim.plot_below_influence(; θ, path = f("$docs_img/below_influence.png"))

#### seasonal effects
sim.plot_seasonal_effect(; θ, path = f("$docs_img/seasonal_reducer.png"))
sim.plot_seasonal_component_senescence(; θ, path = f("$docs_img/seasonal_factor_senescence.png"))

#### land use
sim.plot_mowing(; θ, path = f("$docs_img/mowing.png"))
sim.plot_grazing(; β_PAL_lnc = 1.0, θ, path = f("$docs_img/grazing_1_5.png"))
sim.plot_grazing(; β_PAL_lnc = 2.0, θ, path = f("$docs_img/grazing_5.png"))
sim.plot_α_GRZ(; θ, path = f("$docs_img/α_GRZ.png"))
sim.plot_trampling_biomass(; θ, path = f("$docs_img/trampling_biomass.png"))
sim.plot_trampling_livestockdensity(; θ, path = f("$docs_img/trampling_LD.png"))
sim.plot_trampling_biomass_individual(; θ, path = f("$docs_img/trampling_biomass_individual.png"))

##  clonal growth
sim.plot_clonalgrowth(; θ, path = f("$docs_img/clonalgrowth.png"))
sim.animate_clonalgrowth(; θ, path = f("$docs_img/clonalgrowth_animation.mp4"))

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
