@doc raw"""
Yearly clonal growth.

```math
\begin{align}
\text{growth_factor} &= \frac{0.05}{\text{nneighbours}} \\
\text{crowded_factor} &=
    \min(\frac{\text{msurrounded_biomass}}{\text{biomass_target}}, 2.0) \\
\text{clonalgrowth} &=
    \text{growth_factor} \cdot \text{crowded_factor} \cdot \text{biomass} \\
\end{align}
```

The biomass is transferred from the home patch to the neighbour (target) patches.
This is done for all patches once per year.

- `clonalgrowth`: biomass that is transferred from the home to the target patch [kg ha⁻¹]
- `nneighbours`: number of neighbour patches of the home patch. For a grid this
   value lies between 2 (edge) and 4 (middle).
- `msurrounded_biomass`: mean biomass of the home and the
   (upto 4) neighbour patches [kg ha⁻¹]
- `biomass_target`: biomass of the target patch [kg ha⁻¹]
- `growth_factor`: proportion of biomass that is transferred from the home
   patch to one neighbour patch. This factor is modified by the `crowded_factor` [-]
- `crowded_factor`: factor to adapth clonal growth based on the biomass distribution
    of the patches in the direct surroundings. The value lies between 0
    (no clonal growth due to high surrounded biomass) and
    2 (high clonal growth due to high own biomass).

![](../img/clonalgrowth.svg)
"""
function clonalgrowth!(; container)
    @unpack patch_xdim, patch_ydim, nspecies = container.simp
    @unpack clonalgrowth, biomass_per_patch = container.calc
    @unpack u_biomass = container.u
    @unpack clonalgrowth_factor = container.p

    calculate_relbiomass!(; container)

    clonalgrowth .= 0.0u"kg / ha"

    x_add = [0, 1, 0, -1, 0]
    y_add = [0, 0, 1, 0, -1]

    for x in Base.OneTo(patch_xdim)
        for y in Base.OneTo(patch_ydim)


            #### mean biomass of the home and the (upto 4) neighbour patches
            nsurroundings = 0
            surrounded_biomass = 0.0u"kg / ha"
            for i in 1:5
                x_neighbour = x + x_add[i]
                y_neighbour = y + y_add[i]

                if x_neighbour < 1 || x_neighbour > patch_xdim ||
                   y_neighbour < 1 || y_neighbour > patch_ydim
                     continue
                end

                nsurroundings += 1
                surrounded_biomass += biomass_per_patch[x_neighbour, y_neighbour]
            end

            nneighbours_patch = nsurroundings - 1
            msurrounded_biomass = surrounded_biomass / nsurroundings

            #### clonal growth to neighbour patches
            for i in 2:5
                x_neighbour = x + x_add[i]
                y_neighbour = y + y_add[i]

                if x_neighbour < 1 || x_neighbour > patch_xdim ||
                   y_neighbour < 1 || y_neighbour > patch_ydim
                    continue
                end

                crowded_factor =
                    msurrounded_biomass / biomass_per_patch[x_neighbour, y_neighbour]
                crowded_factor = min(crowded_factor, 2.0)
                growth_factor = clonalgrowth_factor / nneighbours_patch


                for s in Base.OneTo(nspecies)
                    ## growth to neighbour patch
                    clonalgrowth[x_neighbour, y_neighbour, s] +=
                        u_biomass[x, y, s] * growth_factor * crowded_factor

                    ## biomass is removed from own patch
                    clonalgrowth[x, y, s] -=
                       u_biomass[x, y, s] * growth_factor * crowded_factor
                end
            end

        end
    end

    u_biomass .+= clonalgrowth

    return nothing
end
