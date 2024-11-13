


# Plant height dynamics {#Plant-height-dynamics}

The dynamics of the plant height of the species $H_{txys}$ [m] are described by:

$$\begin{align}
H_{t+1xys} &= H_{txys} \cdot \left(1 + \frac{A_{txys} \cdot G_{act, txys}}{B_{A, txys}} - \frac{MOW_{txys}}{B_{A, txys}} - \frac{GRZ_{txys}}{B_{A, txys}}\right) \\
A_{txys} &= \frac{\left(\frac{B_{A,txys}}{B_{txys}}\right)}{abp_s}
\end{align}$$

If the plants are taller than their maximum height $maxheight_s$, their height is set to their maximum height.

:::tabs

== Parameter

none

== Variables

state variables:
- $H_{txys}$ plant height of each species [m]
  
- $B_{A, txys}$ aboveground biomass of each species [kg ha⁻¹]
  
- $B_{txys}$ biomass of each species [kg ha⁻¹]
  

intermediate variables:
- $G_{act, txys}$ actual growth of each species [kg ha⁻¹]
  
- $MOW_{txys}$ mown biomass of each species [kg ha⁻¹]
  
- $GRZ_{txys}$ grazed biomass of each species [kg ha⁻¹]
  
- $A_{txys}$ fraction between realised aboveground biomass proportion to the trait aboveground biomass proportion of each species [-]
  

morphological traits:
- $abp_s$ aboveground biomass per total biomass of each species [-]
  
- $maxheight_s$ maximum height of each species [-]
  

:::

## API
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


[source](https://github.com/FelixNoessler/GrasslandTraitSim.jl/blob/083386dc75748e31525cf4ea66f74778601f0f0c/src/4_height/height.jl#L1)

</details>

