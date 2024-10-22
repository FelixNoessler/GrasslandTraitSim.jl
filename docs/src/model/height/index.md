```@meta
CurrentModule=GrasslandTraitSim
```

# Plant height dynamics

The dynamics of the plant height of the species ``H_{txys}`` [m] are described by:
```math
\begin{align}
H_{t+1xys} &= H_{txys} \cdot \left(1 + \frac{A_{txys} \cdot G_{act, txys}}{B_{A, txys}} - \frac{MOW_{txys}}{B_{A, txys}} - \frac{GRZ_{txys}}{B_{A, txys}}\right) \\
A_{txys} &= \frac{\left(\frac{B_{A,txys}}{B_{txys}}\right)}{ABP_s}
\end{align}
```
If the plants are taller than their potential height ``PH_s``, their height is set to their potential height.


:::tabs

== Parameter

none

== Variables

state variables:
- ``H_{txys}`` plant height of each species [m]
- ``B_{A, txys}`` aboveground biomass of each species [kg ha⁻¹]
- ``B_{txys}`` biomass of each species [kg ha⁻¹]

intermediate variables:
- ``G_{act, txys}`` actual growth of each species [kg ha⁻¹]
- ``MOW_{txys}`` mown biomass of each species [kg ha⁻¹]
- ``GRZ_{txys}`` grazed biomass of each species [kg ha⁻¹]
- ``A_{txys}`` fraction between realised aboveground biomass proportion to the trait aboveground biomass proportion of each species [-]

morphological traits:
- ``ABP_s`` aboveground biomass per total biomass of each species [-]
- ``PH_s`` potential height of each species [-]

:::

## API

```@docs
height_dynamic!
```