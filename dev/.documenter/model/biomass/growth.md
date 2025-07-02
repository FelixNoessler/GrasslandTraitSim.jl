


# Growth {#Growth}

Click on a process to view detailed documentation:

```mermaid
flowchart LR
    A[[potential growth Gpot]] ==> D(actual growth Gact)
    B[[community adjustment by environmental and seasonal factors ENV]] ==> D
    C[[species-specific adjustment]] ==> D
    subgraph " "
    L[↓ radiation RAD] -.-> B
    M[↓ temperature TEMP] -.-> B
    N[⇅ seasonal factor SEA] -.-> B
    end
    subgraph " "
    F[⇅ light competition LIG] -.-> C
    H[↓ water stress WAT] -.-> C
    I[↓ nutrient stress NUT] -.-> C
    P[↓ investment into roots and mycorrhiza ROOT] -.-> C
    end
click A "growth_potential_growth" "Go"
click B "growth_env_factors" "Go"
click C "growth_species_specific" "Go"
click L "growth_env_factors#Radiation-influence" "Go"
click M "growth_env_factors#Temperature-influence" "Go"
click N "growth_env_factors#Seasonal-effect" "Go"
click F "growth_species_specific_light" "Go"
click H "growth_species_specific_water" "Go"
click I "growth_species_specific_nutrients" "Go"
click P "growth_species_specific_roots" "Go"
```


The actual growth $G_{act, ts}$ [kg ha⁻¹] is derived from the community potential growth $G_{pot, t}$ [kg ha⁻¹] and the multiplicative effect of five growth adjustment factors:

$$G_{act, ts} = G_{pot, t} \cdot LIG_{ts} \cdot NUT_{ts} \cdot WAT_{ts} \cdot ROOT_{ts} \cdot ENV_{t}$$

where $LIG_{ts}$ [-] is the species-specific competition for light, $NUT_{ts}$ [-] is the species-specific competition for nutrients, $WAT_{ts}$ [-] is the species-specific competition for soil water, $ROOT_{ts}$ [-] is the species-specific cost for maintaining roots and mycorrhiza, and $ENV_{t}$ [-] is the non-species specific adjustment based on environmental and seasonal factors.

## API {#API}
<details class='jldocstring custom-block' open>
<summary><a id='GrasslandTraitSim.growth!' href='#GrasslandTraitSim.growth!'><span class="jlbinding">GrasslandTraitSim.growth!</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
growth!(
;
    t,
    container,
    above_biomass,
    total_biomass,
    actual_height,
    W,
    nutrients,
    WHC,
    PWP
)

```


Calculates the growth of the plant species.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/FelixNoessler/GrasslandTraitSim.jl/blob/8fcf43661af2b44d618f4d4a9ad9c58c594c000a/src/3_biomass/1_growth/1_growth.jl#L8" target="_blank" rel="noreferrer">source</a></Badge>

</details>

