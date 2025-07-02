


# Plant height dynamics {#Plant-height-dynamics}

The dynamics of the plant height of the species $H_{ts}$ [m] are described by:

$$\begin{align}
H_{t+1s} &= H_{ts} \cdot \left(1 + \frac{A_{ts} \cdot G_{act, ts}}{B_{A, ts}} - \frac{MOW_{ts}}{B_{A, ts}} - \frac{GRZ_{ts}}{B_{A, ts}}\right) \\
A_{ts} &= \frac{\left(\frac{B_{A,ts}}{B_{ts}}\right)}{abp_s}
\end{align}$$

If the plants are taller than their maximum height $maxheight_s$, their height is set to their maximum height.

:::tabs

== Parameter

none

== Variables

state variables:
- $H_{ts}$ plant height of each species [m]
  
- $B_{A, ts}$ aboveground biomass of each species [kg ha⁻¹]
  
- $B_{ts}$ biomass of each species [kg ha⁻¹]
  

intermediate variables:
- $G_{act, ts}$ actual growth of each species [kg ha⁻¹]
  
- $MOW_{ts}$ mown biomass of each species [kg ha⁻¹]
  
- $GRZ_{ts}$ grazed biomass of each species [kg ha⁻¹]
  
- $A_{ts}$ fraction between realised aboveground biomass proportion to the trait aboveground biomass proportion of each species [-]
  

morphological traits:
- $abp_s$ aboveground biomass per total biomass of each species [-]
  
- $maxheight_s$ maximum height of each species [-]
  

:::

## API {#API}
<details class='jldocstring custom-block' open>
<summary><a id='GrasslandTraitSim.height_dynamic!' href='#GrasslandTraitSim.height_dynamic!'><span class="jlbinding">GrasslandTraitSim.height_dynamic!</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
height_dynamic!(
;
    container,
    actual_height,
    above_biomass,
    allocation_above
)

```


Caculates the change in the plant height of each species during one time step.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/FelixNoessler/GrasslandTraitSim.jl/blob/8fcf43661af2b44d618f4d4a9ad9c58c594c000a/src/4_height/height.jl#L1" target="_blank" rel="noreferrer">source</a></Badge>

</details>

