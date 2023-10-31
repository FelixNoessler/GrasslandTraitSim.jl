@doc raw"""
    clonalgrowth!(; container)

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
    @unpack npatches = container.simp
    @unpack nneighbours, neighbours, surroundings = container.patch
    @unpack clonalgrowth, biomass_per_patch = container.calc
    @unpack u_biomass = container.u

    clonalgrowth_factor = 0.05
    clonalgrowth .= 0.0u"kg / ha"

    for pa in Base.OneTo(npatches)
        nneighbours_patch = nneighbours[pa]
        surrounding_index = surroundings[pa][.!ismissing.(surroundings[pa])]
        surrounded_biomass = @view biomass_per_patch[surrounding_index]
        msurrounded_biomass = mean(surrounded_biomass)

        for n in @view neighbours[pa, :]
            if ismissing(n)
                continue
            end
            crowded_factor = msurrounded_biomass / biomass_per_patch[n]
            crowded_factor = min(crowded_factor, 2.0)
            growth_factor = clonalgrowth_factor / nneighbours_patch

            ## growth to neighbour patch (n)
            @views clonalgrowth[n, :] .+= u_biomass[pa, :] .* growth_factor .*
                                          crowded_factor

            ## biomass is removed from own patch (pa)
            @views clonalgrowth[pa, :] .-= u_biomass[pa, :] .* growth_factor .*
                                           crowded_factor
        end
    end

    u_biomass .+= clonalgrowth

    return nothing
end
