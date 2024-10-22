"""
Simulates the change of the soil water content in the rooting zone within one time step.
"""
function change_water_reserve(; container, patch_above_biomass, water, precipitation,
                              PET, WHC, PWP)
    @unpack LAItot = container.calc.com

    # -------- Evapotranspiration
    AEv = evaporation(; water, WHC, PET, LAItot)
    ATr = transpiration(; container, patch_above_biomass, water, PWP, WHC, PET, LAItot)
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
function transpiration(; container, patch_above_biomass, water, PWP, WHC, PET, LAItot)
    @unpack included = container.simp

    ###### SLA effect
    sla_effect = 1.0
    if included.sla_transpiration
        @unpack sla = container.traits
        @unpack ϕ_sla, β_TR_sla = container.p
        @unpack relative_sla = container.calc

        # community weighted mean specific leaf area
        relative_sla .= sla .* patch_above_biomass ./ sum(patch_above_biomass)
        cwm_sla = sum(relative_sla)
        sla_effect = min(2.0, max(0.5, (cwm_sla / ϕ_sla) ^ β_TR_sla))  # TODO change in documentation and manusctipt
    end

    ####### plant available water:
    W = max(0.0, (water - PWP) / (WHC - PWP))

    return W * PET * sla_effect * LAItot / 3 # TODO
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
    @unpack sand, silt, clay, organic, bulk, rootdepth = container.site

    @. WHC = (0.5678 * sand +
        0.9228 * silt +
        0.9135 * clay +
        0.6103 * organic -
        0.2696u"cm^3/g" * bulk) * rootdepth
    @. PWP = (-0.0059 * sand +
        0.1142 * silt +
        0.5766 * clay +
        0.2228 * organic +
        0.02671u"cm^3/g" * bulk) * rootdepth

    return nothing
end
