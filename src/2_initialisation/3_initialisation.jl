"""
Initialize the simulation object. The function is called once at the beginning of the simulation within [`solve_prob`](@ref).
"""
function initialization(; input_obj, p, prealloc, trait_input,
                        callback = (; t = []))

    ###### Store everything in one object
    container = tuplejoin((; p = p), input_obj, prealloc, (; callback = callback))

    ###### Traits
    if isnothing(trait_input)
        random_traits!(; container)
    else
        @reset container.traits = trait_input
    end
    similarity_matrix!(; container)

    ###### Set some variables that do not vary with time
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
    @unpack u_biomass, u_above_biomass, u_below_biomass, u_water, u_height = container.u
    @unpack output = container
    @unpack initbiomass, initsoilwater, nspecies, patch_xdim, patch_ydim = container.simp
    @unpack maxheight, abp = container.traits

    @. u_biomass = initbiomass / nspecies
    @. u_water = initsoilwater

    output.grazed .= 0.0u"kg / ha"
    output.mown .= 0.0u"kg / ha"

    for x in Base.OneTo(patch_xdim)
        for y in Base.OneTo(patch_ydim)
            for s in Base.OneTo(nspecies)
                output.biomass[1, x, y, s] = u_biomass[x, y, s]

                u_above_biomass[x, y, s] = u_biomass[x, y, s] * abp[s]
                u_below_biomass[x, y, s] = u_biomass[x, y, s] * (1-abp[s])
                output.above_biomass[1, x, y, s] = u_above_biomass[x, y, s]
                output.below_biomass[1, x, y, s] = u_below_biomass[x, y, s]

                u_height[x, y, s] = maxheight[s] / 2
                output.height[1, x, y, s] = u_height[x, y, s]
            end

            output.water[1, x, y] = u_water[x, y]
        end
    end


    return nothing
end
