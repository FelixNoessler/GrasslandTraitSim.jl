```@meta
CurrentModule=GrasslandTraitSim
```

# Growth

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

The actual growth ``G_{act, ts}`` [kg ha⁻¹] is derived from the community potential growth ``G_{pot, t}`` [kg ha⁻¹] and the multiplicative effect of five growth adjustment factors:
```math
G_{act, ts} = G_{pot, t} \cdot LIG_{ts} \cdot NUT_{ts} \cdot WAT_{ts} \cdot ROOT_{ts} \cdot ENV_{t}
```
where ``LIG_{ts}`` [-] is the species-specific competition for light, ``NUT_{ts}`` [-] is the species-specific competition for nutrients, ``WAT_{ts}`` [-] is the species-specific competition for soil water, ``ROOT_{ts}`` [-] is the species-specific cost for maintaining roots and mycorrhiza, and ``ENV_{t}`` [-] is the non-species specific adjustment based on environmental and seasonal factors.

## API

```@docs
growth!
```
