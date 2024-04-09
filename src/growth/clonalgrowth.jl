@doc raw"""
Yearly clonal growth.

The biomass is transferred from the home patch to the neighbour (target) patches.
This is done for all patches once per year.

![](../img/clonalgrowth.svg)
![](../img/clonalgrowth_animation.mp4)
"""
function clonalgrowth!(; container)
    @unpack patch_xdim, patch_ydim, nspecies = container.simp
    @unpack clonalgrowth = container.calc
    @unpack u_biomass = container.u
    @unpack clonalgrowth_factor = container.p

    clonalgrowth .= 0.0u"kg / ha"
    x_add = [1, 0, -1, 0]
    y_add = [0, 1, 0, -1]

    for x in Base.OneTo(patch_xdim)
        for y in Base.OneTo(patch_ydim)
            for i in 1:4
                x_neighbour = x + x_add[i]
                y_neighbour = y + y_add[i]

                if x_neighbour < 1 || x_neighbour > patch_xdim ||
                   y_neighbour < 1 || y_neighbour > patch_ydim
                    continue
                end

                for s in Base.OneTo(nspecies)
                    ## growth to neighbour patch
                    clonalgrowth[x_neighbour, y_neighbour, s] +=
                        u_biomass[x, y, s] * clonalgrowth_factor

                    ## biomass is removed from own patch
                    clonalgrowth[x, y, s] -= u_biomass[x, y, s] * clonalgrowth_factor
                end
            end

        end
    end

    u_biomass .+= clonalgrowth

    return nothing
end
