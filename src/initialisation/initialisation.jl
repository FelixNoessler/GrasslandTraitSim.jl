include("preallocation.jl")
include("preallocation_struct.jl")
include("nutrients_whc_pwp_init.jl")
include("senescence_init.jl")
include("transferfunctions_init.jl")


"""
    initialization(; input_obj, inf_p, calc, trait_input = nothing)

Initialize the simulation object.
"""
function initialization(; input_obj, inf_p, calc, trait_input = nothing)
    p_fixed = fixed_parameter(; input_obj)
    p = tuplejoin(inf_p, p_fixed)

    ################## Cutted biomass for validation
    biomass_cutting_t = Int64[]
    biomass_cutting_numeric_date = Float64[]
    if haskey(input_obj, :output_validation)
        @unpack biomass_cutting_t, biomass_cutting_numeric_date = input_obj.output_validation
    end
    cutted_biomass = DimArray(
        fill(NaN64, length(biomass_cutting_t))u"kg/ha",
        (; t = biomass_cutting_t),
        name = :cutted_biomass)
    cutted_biomass_tuple =
        (; output_validation = (; cutted_biomass, biomass_cutting_t,
                                biomass_cutting_numeric_date))

    ################## Traits ##################
    if isnothing(trait_input)
        # generate random traits
        random_traits!(; calc, input_obj)
    else
        # use traits from input
        for key in keys(trait_input)
            # getfield(calc.traits, key) .= trait_input[key]
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
    input_nutrients!(; calc, input_obj)

    ################## Store everything in one object ##################
    p = (; p = p)
    container = tuplejoin(p, input_obj, calc, cutted_biomass_tuple)

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

    return temperature_sum * u"°C"
end

function fixed_parameter(; input_obj)
    @unpack included = input_obj.simp

    # TODO add all parameters with a fixed value

    # likelihood_p = (;)
    # if likelihood_included.soilmoisture
    #     likelihood_p = (;
    #         moistureconv_alpha = -10.0
    #     )
    # end

    potential_growth_p = (;)
    if included.potential_growth
        potential_growth_p = (;
            RUE_max = 3 / 1000 * u"kg / MJ", # Maximum radiation use efficiency 3 g DM MJ-1
            α = 0.6   # Extinction coefficient
        )
    end

    potential_evaporation_p = (;)
    if included.water_growth_reduction
        potential_evaporation_p = (;
            α_pet = 2.0u"mm / d",  # potential evaporation --> plant available water
        )
    end

    p_senescence = (;)
    if included.senescence
        p_senescence = (;
            α_ll = 2.41,  # specific leaf area --> leaf lifespan
            β_ll = 0.38,  # specific leaf area --> leaf lifespan
            Ψ₁ = 775,     # temperature threshold: senescence starts to increase
            Ψ₂ = 3000,    # temperature threshold: senescence reaches maximum
            SENₘₐₓ = 3    # maximal seasonality factor for the senescence rate
        )
    end

    transfer_functions_p = (;)
    if included.water_growth_reduction
        added_p =  (;
            ϕ_sla = 0.025u"m^2 / g",
            η_min_sla = -0.8,
            η_max_sla = 0.8,
            β_η_sla = 75u"g / m^2",
            β_sla = 5,)

        transfer_functions_p = tuplejoin(transfer_functions_p, added_p)
    end

    if included.nutrient_growth_reduction
        added_p =  (;
            ϕ_amc = 0.35,
            η_min_amc = 0.05,
            η_max_amc = 0.6,
            κ_min_amc = 0.7,
            β_κη_amc = 10,
            β_amc = 7)

        transfer_functions_p = tuplejoin(transfer_functions_p, added_p)
    end

    if included.nutrient_growth_reduction || included.water_growth_reduction
        added_p =  (;
            ϕ_rsa = 0.12u"m^2 / g",
            η_min_rsa = 0.05,
            η_max_rsa = 0.6,
            κ_min_rsa = 0.7,
            β_κη_rsa = 40u"g / m^2 ",
            β_rsa = 7)

        transfer_functions_p = tuplejoin(transfer_functions_p, added_p)
    end

    return tuplejoin(p_senescence, potential_growth_p, potential_evaporation_p,
    transfer_functions_p)
end
