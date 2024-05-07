@doc raw"""
Calculate the distribution of potential growth to each species based on share of the leaf
area index and the height of each species.

```math
\begin{align*}
LIG_{txys} &= \frac{LAI_{txys}}{LAI_{tot, txy}} \cdot \left(\frac{H_s}{H_{cwm, txy}} \right) ^ {\beta_H} \\
H_{cwm, txy} &= \sum_{s=1}^{S}\frac{B_{txys}}{B_{tot, txy}} \cdot H_s
\end{align*}
```

Parameter, see also [`SimulationParameter`](@ref):
- ``\beta_H`` (`β_height`) controls how strongly taller plants gets more light for growth [-]

Variables:
- ``LAI_{txys}`` (`LAI`) leaf area index of species `s` at time `t` and patch `xy` [-]
- ``LAI_{tot, txy}`` (`LAItot`) total leaf area index, see [`calculate_LAI!`](@ref) [-]
- ``B_{txys}`` (`biomass`) dry aboveground biomass of each species [kg ha⁻¹]
- ``H_s`` (`height`) potential plant height [m]
- ``H_{cwm, txy}`` (`height_cwm`) community weighted mean height [m]

Output:
- ``LIG_{txys}`` (`light_competition`) light competition factor,
  distributes total potential growth to each species [-]


Taller plants get more light and can therefore growth more than smaller plants.
This is modelled by the influence of the potential height in relation to the community
weighted mean potential height. The strenght of this relationship is modelled with the
parameter ``\beta_H``.

The potential height refers to the height that the plant would reach
if it would not be limited by other factors.

![light competition](../img/height_influence.svg)
"""
function light_competition!(; container, biomass)
    @unpack heightinfluence, light_competition, LAIs = container.calc
    @unpack LAItot = container.calc.com
    @unpack included = container.simp
    @unpack height = container.traits

    if !included.height_competition
        @info "Height influence turned off!" maxlog=1
        @. heightinfluence = 1.0
    else
        @unpack relative_height = container.calc
        @unpack β_height = container.p

        relative_height .= height .* biomass ./ sum(biomass)
        height_cwm = sum(relative_height)
        @. heightinfluence = (height / height_cwm) ^ β_height
    end

    @. light_competition = LAIs / LAItot * heightinfluence

    return nothing
end
