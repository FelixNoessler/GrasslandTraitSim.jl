# Create all figures in the documentation

```@example 
import GrasslandTraitSim as sim

####### load fitted parameter values
# θ = nothing
θ = sim.load_optim_result()

####### create images for the document
docs_img = "img"
f(path; show_img = true) = show_img ? nothing : path

#### potential growth
sim.plot_potential_growth_lai_height(; θ, path = f("$docs_img/potential_growth_lai_height.png"))
sim.plot_potential_growth_height_lai(; θ, path = f("$docs_img/potential_growth_height_lai.png"))
sim.plot_potential_growth_height(; θ, path = f("$docs_img/potential_growth_height.png"))
sim.plot_lai_traits(; θ, path = f("$docs_img/lai_traits.png"))
sim.plot_community_height_influence(; θ, path = f("$docs_img/community_height_influence.png"))

#### transfer functions
sim.plot_W_srsa(; θ, path = f("$docs_img/W_rsa_default.png"))
sim.plot_N_srsa(; θ, path = f("$docs_img/N_rsa_default.png"))
sim.plot_N_amc(; θ, path = f("$docs_img/N_amc_default.png"))
sim.plot_root_investment(; θ, path = f("$docs_img/root_investment.png"))

#### reducer functions
sim.plot_temperature_reducer(; θ, path = f("$docs_img/temperature_reducer.png"))
sim.plot_radiation_reducer(; θ, path = f("$docs_img/radiation_reducer.png"))
sim.plot_height_influence(; θ, path = f("$docs_img/height_influence.png"))

#### seasonal effects
sim.plot_seasonal_effect(; θ, path = f("$docs_img/seasonal_reducer.png"))
sim.plot_seasonal_component_senescence(; θ, path = f("$docs_img/seasonal_factor_senescence.png"))
sim.plot_nutrient_adjustment(; θ, path = f("$docs_img/nut_adjustment.png"))

#### land use
sim.plot_mowing(; θ, path = f("$docs_img/mowing.png"))
sim.plot_grazing(; β_PAL_lnc = 1.0, θ, path = f("$docs_img/grazing_default.png"))
sim.plot_grazing(; β_PAL_lnc = 2.0, θ, path = f("$docs_img/grazing_2.png"))
sim.plot_η_GRZ(; θ, path = f("$docs_img/η_GRZ.png"))

##  clonal growth
sim.plot_clonalgrowth(; θ, path = f("$docs_img/clonalgrowth.png"))
sim.animate_clonalgrowth(; θ, path = f("$docs_img/clonalgrowth_animation.mp4"))
```