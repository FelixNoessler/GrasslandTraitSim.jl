@doc raw"""
```math
\text{heightinfluence} =
    1 +
    \frac{\text{height}\cdot\text{height}_{\text{strength}}}{\text{height}_{\text{cwm}}}
    -\text{height}_{\text{strength}}
```

- `height_strength_exp` lies between 0 (no influence) and 1
  (strong influence of the plant height) [-]
- `cwm_height` is community weighted mean height [m]

![light competition](../img/height_influence.svg)
"""
function light_competition!(; container, biomass)
    @unpack relative_height, heightinfluence = container.calc
    @unpack included = container.simp
    @unpack height = container.traits

    if !included.height_competition
        @info "Height influence turned off!" maxlog=1
        @. heightinfluence = 1.0
        return nothing
    end

    ## community weighted mean height
    relative_height .= height .* biomass ./ sum(biomass)
    height_cwm = sum(relative_height)

    @unpack height_strength_exp = container.p
    @. heightinfluence = (height / height_cwm) ^ height_strength_exp

    return nothing
end
