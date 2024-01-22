@doc raw"""
    height_influence!(; container, biomass)

```math
\text{heightinfluence} =
    1 +
    \frac{\text{height}\cdot\text{height}_{\text{strength}}}{\text{height}_{\text{cwm}}}
    -\text{height}_{\text{strength}}
```

- `height_strength` lies between 0 (no influence) and 1
  (strong influence of the plant height) [-]
- `cwm_height` is community weighted mean height [m]

![](../img/height_influence.svg)
"""
function height_influence!(; container, biomass)
    @unpack relative_height, heightinfluence = container.calc
    @unpack height_included = container.simp.included
    @unpack height = container.traits

    if !height_included
        @info "Height influence turned off!" maxlog=1
        @. heightinfluence = 1.0
        return nothing
    end

    ## community weighted mean height
    relative_height .= height .* biomass ./ sum(biomass)
    height_cwm = sum(relative_height)

    @unpack height_strength = container.p
    @. heightinfluence = height * height_strength / height_cwm - height_strength + 1.0

    return nothing
end
