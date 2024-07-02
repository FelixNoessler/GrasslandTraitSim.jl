"""
Initialize the simulation object.

The function is called once at the beginning of the simulation within [`solve_prob`](@ref).

The [traits](@ref "Initialization of traits") of the species are generated or
set if provided, the [parameters](@ref "Initialization of parameters") are initialized and the
[initial conditions of the state variables](@ref "Set the initial conditions of the state variables")
are set.
"""
function initialization(; input_obj, p, prealloc, prealloc_specific, trait_input,
                        callback = (; t = []))

    ###### Store everything in one object
    container = tuplejoin((; p = p), input_obj, prealloc, prealloc_specific,
                          (; callback = callback))

    ###### Traits
    if isnothing(trait_input)
        random_traits!(; container)
    else
        @reset container.traits = trait_input
    end
    similarity_matrix!(; container)

    ###### Set some variables that do not vary with time
    senescence_rate!(; container)
    input_WHC_PWP!(; container)
    input_nutrients!(; container)

    ###### Initial conditions
    set_initialconditions!(; container)

    return container
end

"""
Set the initial conditions for the state variables.

Each plant species (`u_biomass`) gets an equal share of
the initial biomass (`initbiomass`). The soil water content
(`u_water`) is set to 180 mm. The height is set to half of the
maximum height of the species. The above- and belowground biomass
(`u_above_biomass`, `u_below_biomass`) are calculated based on the
aboveground biomass proportion (`abp`).

- `u_biomass`: state variable biomass [kg ha⁻¹]
- `u_water`: state variable soil water content [mm]
- `u_height`: state variable height [m]
- `u_above_biomass`: state variable aboveground biomass [kg ha⁻¹]
- `u_below_biomass`: state variable belowground biomass [kg ha⁻¹]
- `initbiomass`: initial biomass [kg ha⁻¹]
- `initsoilwater`: initial soil water content [mm]
- `height`: potential height of the species [m]
- `abp`: aboveground biomass proportion [-]
"""
function set_initialconditions!(; container)
    @unpack u_biomass, u_above_biomass, u_below_biomass, u_water, u_height = container.u
    @unpack output = container
    @unpack initbiomass, initsoilwater = container.site
    @unpack nspecies, patch_xdim, patch_ydim = container.simp
    @unpack height, abp = container.traits

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

                u_height[x, y, s] = height[s] / 2
                output.height[1, x, y, s] = u_height[x, y, s]
            end

            output.water[1, x, y] = u_water[x, y]
        end
    end


    return nothing
end
