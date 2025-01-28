"""
Simulates the change of the soil water content in the rooting zone within one time step.
"""
function change_water_reserve(; container, water, precipitation,
                              PET, WHC, PWP)
    @unpack LAItot = container.calc.com

    # -------- Evapotranspiration
    AEv = evaporation(; water, WHC, PET, LAItot)
    ATr = transpiration(; container, water, PWP, WHC, PET, LAItot)
    AET = min(water, ATr + AEv)

    # -------- Drainage
    excess_water = water - WHC
    drain = max(excess_water + precipitation -AET, zero(excess_water))

    # -------- Total change in the water reserve
    du_water = precipitation - drain - AET

    return du_water
end

"""
Simulates transpiration from the vegetation.
"""
function transpiration(; container, water, PWP, WHC, PET, LAItot)
    ### plant available water
    Wp = max(0.0, (water - PWP) / (WHC - PWP))

    return Wp * PET  * LAItot / 3
end

"""
Simulate evaporation of water from the soil.
"""
function evaporation(; water, WHC, PET, LAItot)
    return water / WHC * PET * (1 - min(1, LAItot / 3))
end

"""
Derive walter holding capacity (WHC) and permanent wilting point (PWP) from soil properties.
"""
function input_WHC_PWP!(; container)
    @unpack WHC, PWP = container.patch_variables
    @unpack sand, silt, clay, organic, bulk, rootdepth = container.input
    @unpack β_SND_WHC, β_SLT_WHC, β_CLY_WHC, β_OM_WHC, β_BLK_WHC,
            β_SND_PWP, β_SLT_PWP, β_CLY_PWP, β_OM_PWP, β_BLK_PWP = container.p
    @unpack patch_xdim, patch_ydim, years = container.simp

    for year in years
        for x in 1:patch_xdim
            for y in 1:patch_ydim
                WHC[year = At(year), x = At(x), y = At(y)] = (
                    β_SND_WHC * sand[year = At(year), x = At(x), y = At(y)] +
                    β_SLT_WHC * silt[year = At(year), x = At(x), y = At(y)] +
                    β_CLY_WHC * clay[year = At(year), x = At(x), y = At(y)] +
                    β_OM_WHC * organic[year = At(year), x = At(x), y = At(y)] +
                    β_BLK_WHC * bulk[year = At(year), x = At(x), y = At(y)]) *
                        rootdepth[year = At(year), x = At(x), y = At(y)]

                PWP[year = At(year), x = At(x), y = At(y)] = (
                    β_SND_PWP * sand[year = At(year), x = At(x), y = At(y)] +
                    β_SLT_PWP * silt[year = At(year), x = At(x), y = At(y)] +
                    β_CLY_PWP * clay[year = At(year), x = At(x), y = At(y)] +
                    β_OM_PWP * organic[year = At(year), x = At(x), y = At(y)] +
                    β_BLK_PWP * bulk[year = At(year), x = At(x), y = At(y)]) *
                        rootdepth[year = At(year), x = At(x), y = At(y)]
            end
        end
    end

    return nothing
end
