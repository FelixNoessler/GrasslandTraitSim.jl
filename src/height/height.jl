function height_dynamic(; container, state_height)
    @unpack abp,  height = container.traits
    @unpack mown, grazed, act_growth, senescence, above_biomass = container.calc

    r = act_growth ./ above_biomass
    height_gain = @. r * (1 - state_height / height) * state_height

    height_loss_mowing = mown ./ above_biomass .* state_height
    height_loss_grazing = grazed ./ above_biomass .* state_height

    return height_gain .- height_loss_mowing .- height_loss_grazing
end
