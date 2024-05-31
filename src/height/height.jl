function height_dynamic!(; container, actual_height, above_biomass)
    @unpack abp,  height = container.traits
    @unpack mown, grazed, act_growth, senescence, height_gain,
            height_loss_grazing, height_loss_mowing = container.calc

    @. height_gain = act_growth / above_biomass * (1 - actual_height / height) * actual_height
    @. height_loss_mowing = mown / above_biomass * actual_height
    @. height_loss_grazing = grazed / above_biomass * actual_height

    return nothing
end
