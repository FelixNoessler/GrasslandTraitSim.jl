"""
Initialize the simulation object.

The function is called once at the beginning of the simulation within [`solve_prob`](@ref).

The [traits](@ref "Initialization of traits") of the species are generated,
the [parameters](@ref "Initialization of parameters") are initialized and the
[initial conditions of the state variables](@ref "Set the initial conditions of the state variables")
are set.
"""
function initialization(; input_obj, p, prealloc, prealloc_specific,
                        trait_input = nothing, θ_type = Float64)

    ################## Traits ##################
    if isnothing(trait_input)
        # generate random traits
        random_traits!(; prealloc, input_obj)
    else
        prealloc = @set prealloc.traits = trait_input
    end

    # distance matrix for below ground competition
    similarity_matrix!(; input_obj, prealloc)

    ################## Parameters ##################
    # leaf senescence rate μ []
    senescence_rate!(; input_obj, prealloc, p)

    # linking traits to water and nutrient stress
    init_water_transfer_functions!(; input_obj, prealloc, p)
    init_nutrient_transfer_functions!(; input_obj, prealloc, p)

    # investment to roots
    root_investment!(; input_obj, prealloc, p)

    # WHC, PWP and nutrient index
    input_WHC_PWP!(; prealloc, input_obj)
    input_nutrients!(; prealloc, input_obj, p)

    ################## Store everything in one object ##################
    p = (; p = p)
    container = tuplejoin(p, input_obj, prealloc, prealloc_specific)

    ################## Initial conditions ##################
    set_initialconditions!(; container)

    return container
end

"""
Set the initial conditions for the state variables.

Each plant species (`u_biomass`) gets an equal share of
the initial biomass (`initbiomass`). The soil water content
(`u_water`) is set to 180 mm.

- `u_biomass`: state variable biomass [kg ha⁻¹]
- `u_water`: state variable soil water content [mm]
- `initbiomass`: initial biomass [kg ha⁻¹]
- `initsoilwater`: initial soil water content [mm]
"""
function set_initialconditions!(; container)
    @unpack u_biomass, u_water, u_height = container.u
    @unpack output = container
    @unpack initbiomass, initsoilwater = container.site
    @unpack nspecies, patch_xdim, patch_ydim = container.simp
    @unpack height = container.traits

    @. u_biomass = initbiomass / nspecies
    @. u_water = initsoilwater

    output.grazed .= 0.0u"kg / ha"
    output.mown .= 0.0u"kg / ha"

    for x in Base.OneTo(patch_xdim)
        for y in Base.OneTo(patch_ydim)
            for s in Base.OneTo(nspecies)
                output.biomass[1, x, y, s] = u_biomass[x, y, s]

                u_height[x, y, s] = height[s] / 2
                output.height[1, x, y, s] = u_height[x, y, s]
            end

            output.water[1, x, y] = u_water[x, y]
        end
    end


    return nothing
end
