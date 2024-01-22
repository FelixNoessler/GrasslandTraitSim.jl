include("preallocation.jl")
include("nutrients_whc_pwp_init.jl")
include("senescence_init.jl")
include("transferfunctions_init.jl")


"""
    initialization(; input_obj, inf_p, calc, trait_input = nothing)

Initialize the simulation object.
"""
function initialization(; input_obj, inf_p, calc, trait_input = nothing)
    p = tuplejoin(inf_p, fixed_parameter())

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
    senescence_rate!(; input_obj, calc, p)

    # linking traits to water and nutrient stress
    init_transfer_functions!(; input_obj, calc, p)

    # WHC, PWP and nutrient index
    input_WHC_PWP!(; calc, input_obj)
    input_nutrients!(; calc, input_obj, p)

    ################## Store everything in one object ##################
    p = (; p = p)
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

function fixed_parameter()
    # TODO add all parameters with a fixed value
    p = (
        # potential growth
        RUE_max = 3 // 1000 * u"kg / MJ", # Maximum radiation use efficiency 3 g DM MJ-1
        α = 0.6,   # Extinction coefficient

        # potential evaporation --> plant available water
        α_pet = 2.0u"mm / d",

        # specific leaf area --> leaf lifespan
        α_ll = 2.41,
        β_ll = 0.38,

        # transfer functions
        ϕ_amc = 0.35,
        ϕ_rsa = 0.12u"m^2 / g",
        ϕ_sla = 0.025u"m^2 / g",
        η_min_amc = 0.05,
        η_min_rsa = 0.05,
        η_min_sla = -0.8,
        η_max_amc = 0.6,
        η_max_rsa = 0.6,
        η_max_sla = 0.8,
        κ_min_amc = 0.7,
        κ_min_rsa = 0.7,
        β_κη_amc = 10,
        β_κη_rsa = 40u"g / m^2 ",
        β_η_sla = 75u"g / m^2",
        β_sla = 5,
        β_rsa = 7,
        β_amc = 7
    )

    return p
end
