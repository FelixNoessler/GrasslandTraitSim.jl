include("parameter.jl")
include("preallocation.jl")
include("nutrients_whc_pwp_init.jl")
include("senescence_init.jl")
include("transferfunctions_init.jl")


"""
Initialize the simulation object.
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
    init_transfer_functions!(; input_obj, prealloc, p)

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
    @unpack u_biomass, u_water = container.u
    @unpack grazed, mown = container.output
    @unpack initbiomass, initsoilwater = container.site
    @unpack nspecies = container.simp

    @. u_biomass = initbiomass / nspecies
    @. u_water = initsoilwater

    grazed .= 0.0u"kg / ha"
    mown .= 0.0u"kg / ha"

    return nothing
end
