include("parameter.jl")
include("preallocation.jl")
include("preallocation_struct.jl")
include("nutrients_whc_pwp_init.jl")
include("senescence_init.jl")
include("transferfunctions_init.jl")


function init_cutted_biomass(; input_obj, T = Float64)
    cutting_height = Float64[]
    biomass_cutting_t = Int64[]
    biomass_cutting_numeric_date = Float64[]
    biomass_cutting_index = Int64[]
    if haskey(input_obj, :output_validation)
        @unpack biomass_cutting_t, biomass_cutting_numeric_date,
                cutting_height, biomass_cutting_index = input_obj.output_validation
    end
    cut_biomass = fill(T(NaN), length(biomass_cutting_t))u"kg/ha"

    return (; cut_biomass, biomass_cutting_t,
            biomass_cutting_numeric_date,
            cut_index = biomass_cutting_index,
            cutting_height = cutting_height)
end

"""
    initialization(; input_obj, inf_p, calc, trait_input = nothing)

Initialize the simulation object.
"""
function initialization(; input_obj, p, calc, trait_input = nothing, θ_type = Float64)

    ################## Traits ##################
    if isnothing(trait_input)
        # generate random traits
        random_traits!(; calc, input_obj)
    else
        calc = @set calc.traits = trait_input
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

function cumulative_temperature(; temperature, year)
    temperature = ustrip.(temperature)
    temperature_sum = Float64[]
    temperature_filter = temperature .> 0

    for y in year
        year_filter = y .== year
        append!(temperature_sum, cumsum(temperature[year_filter .&& temperature_filter]))
    end

    return temperature_sum #* u"°C"
end
