"""
Initialize the simulation object. The function is called once at the beginning of the simulation within [`solve_prob`](@ref).
"""
function initialization(; input_obj, p, prealloc,
                        callback = (; t = []))

    ###### Store everything in one object
    container = tuplejoin((; p = p), input_obj, prealloc, (; callback = callback))

    ###### Set some variables that do not vary with each time step
    initialize_senescence_rate!(; container)
    input_WHC_PWP!(; container)
    input_nutrients!(; container)

    ###### Initial conditions
    set_initialconditions!(; container)

    if p.δ_NUT_amc <= 0.0 throw(DomainError(p.δ_NUT_amc, "δ_NUT_amc must be larger than zero")) end
    if p.δ_NUT_rsa <= 0.0u"g/m^2" throw(DomainError(p.δ_NUT_rsa, "δ_NUT_rsa must be larger than zero")) end
    if p.δ_WAT_rsa <= 0.0u"g/m^2" throw(DomainError(p.δ_WAT_rsa, "δ_WAT_rsa must be larger than zero")) end

    return container
end

"""
Set the initial conditions for the state variables.
"""
function set_initialconditions!(; container)
    @unpack u_biomass, u_above_biomass, u_below_biomass, u_height = container.u
    @unpack output, state_water, init = container
    @unpack nspecies = container.simp
    @unpack maxheight, abp = container.traits

    @. u_biomass = init.AbovegroundBiomass + init.BelowgroundBiomass
    @. u_above_biomass = init.AbovegroundBiomass
    @. u_below_biomass = init.BelowgroundBiomass
    @. u_height = init.Height
    state_water.u_water = init.Soilwater

    output.grazed .= 0.0u"kg / ha"
    output.mown .= 0.0u"kg / ha"

    for s in Base.OneTo(nspecies)
        output.biomass[1, s] = u_biomass[s]
        output.above_biomass[1, s] = u_above_biomass[s]
        output.below_biomass[1, s] = u_below_biomass[s]
        output.height[1, s] = u_height[s]
    end

    output.water[1] = state_water.u_water

    return nothing
end
