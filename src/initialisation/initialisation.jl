include("preallocation.jl")
include("nutrients_whc_pwp_init.jl")
include("senescence_init.jl")
include("transferfunctions_init.jl")


"""
    initialization(; input_obj, inf_p, calc)

Initialize the simulation object.
"""
function initialization(; input_obj, inf_p,
                        calc, trait_input = nothing)

    ################## Traits ##################
    if isnothing(trait_input)
        # generate random traits
        random_traits!(; calc, input_obj)
    else
        # use traits from input
        for key in keys(trait_input)
            calc.traits[key] .= trait_input[key]
        end
    end

    # distance matrix for below ground competition
    similarity_matrix!(; input_obj, calc)

    ################## Parameters ##################
    # leaf senescence rate μ [d⁻¹]
    senescence_rate!(; calc, inf_p)

    # linking traits to water and nutrient stress
    amc_nut_init!(; calc, inf_p)
    rsa_above_water_init!(; calc, inf_p)
    rsa_above_nut_init!(; calc, inf_p)
    sla_water_init!(; calc, inf_p)

    # WHC, PWP and nutrient index
    input_WHC_PWP!(; calc, input_obj)
    input_nutrients!(; calc, input_obj, inf_p)

    ################## Store everything in one object ##################
    p = (; p = inf_p)
    container = tuplejoin(p, input_obj, calc)

    ################## Initial conditions ##################
    set_initialconditions!(; container)

    return container
end

"""
    set_initialconditions!(; container)

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
    @unpack u_biomass, u_water, grazed, mown = container.u
    @unpack initbiomass, initsoilwater = container.site
    @unpack nspecies = container.simp

    @. u_biomass = initbiomass / nspecies
    @. u_water = initsoilwater

    grazed .= 0.0u"kg / ha"
    mown .= 0.0u"kg / ha"

    return nothing
end

function cumulative_temperature(; temperature, year)
    temperature = ustrip.(temperature)
    temperature_sum = Float64[]

    for y in year
        year_filter = y .== year
        append!(temperature_sum, cumsum(temperature[year_filter]))
    end

    return temperature_sum * u"°C"
end
