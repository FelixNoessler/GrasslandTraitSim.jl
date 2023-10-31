function prepare_input(; plot_obj, valid, posterior)
    # ------------- parameter values
    parameter_vals = nothing
    samplingtype = plot_obj.obs.menu_samplingtype.selection.val
    if samplingtype == :prior
        parameter_vals = valid.sample_prior()
    elseif samplingtype == :fixed
        parameter_vals = [s.value.val for s in plot_obj.obs.sliders_param.sliders]
    else
        samplingtype == :posterior
        if isnothing(posterior)
            error("No posterior draws given - cannot sample from posterior!")
        else
            parameter_vals = valid.sample_posterior(posterior)
        end
    end

    if samplingtype != :fixed
        for i in eachindex(parameter_vals)
            s = plot_obj.obs.sliders_param.sliders[i]
            set_close_to!(s, parameter_vals[i])
        end
    end

    parameter_names = valid.model_parameters().names
    inf_p = (; zip(Symbol.(parameter_names), parameter_vals)...)

    # ------------- whether parts of the simulation are included
    included = (;
        senescence_included = plot_obj.obs.toggle_senescence_included.active.val,
        potgrowth_included = plot_obj.obs.toggle_potgrowth_included.active.val,
        mowing_included = plot_obj.obs.toggle_mowing_included.active.val,
        grazing_included = plot_obj.obs.toggle_grazing_included.active.val,
        below_included = plot_obj.obs.toggle_below_included.active.val,
        height_included = plot_obj.obs.toggle_height_included.active.val,
        water_red = plot_obj.obs.toggle_water_red.active.val,
        nutrient_red = plot_obj.obs.toggle_nutr_red.active.val,
        temperature_red = plot_obj.obs.toggle_temperature_red.active.val,
        season_red = plot_obj.obs.toggle_season_red.active.val,
        radiation_red = plot_obj.obs.toggle_radiation_red.active.val)

    return inf_p, prepare_valid_input(; included, plot_obj, valid)
end

function prepare_valid_input(; included, plot_obj, valid)
    plotID = plot_obj.obs.menu_plotID.selection.val
    input_obj = valid.validation_input(;
        plotID,
        nspecies = plot_obj.obs.nspecies.val,
        npatches = plot_obj.obs.npatches.val,
        nutheterog = plot_obj.obs.slider_nutheterog.value.val,
        startyear = 2009,
        endyear = 2021,
        included...)

    return input_obj
end

# function prepare_scen_input(; included, plot_obj, scen)
#     # ------------- mowing
#     mowing_selected = [toggle.active.val for toggle in plot_obj.obs.toggles_mowing]
#     mowing_dates = [tb.stored_string.val for tb in plot_obj.obs.tb_mowing_date][mowing_selected]

#     ## final vectors of vectors
#     mowing_doys = Dates.dayofyear.(Dates.Date.(mowing_dates, "mm-dd"))

#     # ------------- grazing
#     grazing_selected = [toggle.active.val
#                         for toggle in plot_obj.obs.toggles_grazing]
#     grazing_start = [tb.stored_string.val
#                      for tb in plot_obj.obs.tb_grazing_start][grazing_selected]
#     grazing_end = [tb.stored_string.val
#                    for tb in plot_obj.obs.tb_grazing_end][grazing_selected]
#     grazing_intensity = [parse(Float64, tb.stored_string.val)
#                          for tb in plot_obj.obs.tb_grazing_intensity][grazing_selected]

#     # ------------- soil nutrients
#     nutrient_index = plot_obj.obs.slider_nut.value.val

#     # ------------- soil water properties
#     PWP, WHC = plot_obj.obs.slider_pwp_whc.interval.val

#     input_obj = scen.scenario_input(;
#         nyears = plot_obj.obs.nyears.val,
#         nspecies = plot_obj.obs.nspecies.val,
#         npatches = plot_obj.obs.npatches.val,
#         explo = plot_obj.obs.menu_explo.selection.val,
#         mowing_doys,
#         grazing_start,
#         grazing_end,
#         grazing_intensity,
#         nutrient_index,
#         WHC,
#         PWP,
#         included...)
#     return input_obj
# end
