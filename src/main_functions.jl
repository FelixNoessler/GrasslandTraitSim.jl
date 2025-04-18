"""
Solve the model for one site.

All input variables are explained in a tutorial:
[How to prepare the input data to start a simulation](@ref)

There is also a tutorial on the model output:
[How to analyse the model output](@ref)
"""
function solve_prob(; input_obj, p, prealloc = nothing,
                    callback = (; t = []))

    if ! (p isa SimulationParameter)
        simulation_keys = keys(SimulationParameter())
        p_subset = NamedTuple{filter(x -> x ∈ simulation_keys, keys(p))}(p)
        p = SimulationParameter(; p_subset...)
    end

    if isnothing(prealloc)
        prealloc = preallocate_vectors(; input_obj)
    end

    container = initialization(; input_obj, p, prealloc, callback)
    main_loop!(; container)

    return container
end

"""
Run the main loop for all days. Calls the function [`one_day!`](@ref) for each day
and set the calculated density differences to the output variables.
"""
function main_loop!(; container)
    @unpack u_biomass, u_above_biomass, u_below_biomass, u_height,
            du_biomass, du_above_biomass, du_below_biomass, du_height = container.u
    @unpack output, state_water = container
    @unpack ts, nspecies = container.simp

    for t in ts
        one_day!(; t, container)

        u_biomass .+= du_biomass
        u_above_biomass .+= du_above_biomass
        u_below_biomass .+= du_below_biomass
        u_height .+= du_height

        for s in Base.OneTo(nspecies)
            output.biomass[t+1, s] = max(u_biomass[s], 0.0u"kg/ha")
            output.above_biomass[t+1, s] = max(u_above_biomass[s], 0.0u"kg/ha")
            output.below_biomass[t+1, s] = max(u_below_biomass[s], 0.0u"kg/ha")
            output.height[t+1, s] = u_height[s]
        end

        state_water.u_water += state_water.du_water
        output.water[t+1] = state_water.u_water

        callback_above_biomass!(; t, container)
    end

    return nothing
end

function callback_above_biomass!(; t, container)
    @unpack callback = container
    @unpack u_above_biomass, u_below_biomass, u_biomass = container.u
    @unpack nspecies = container.simp
    @unpack above_divided_below = container.calc

    if t ∈ callback.t
        for s in 1:nspecies
            above_divided_below[s] = u_above_biomass[s] / u_below_biomass[s]

            if iszero(above_divided_below[s]) || isinf(above_divided_below[s]) || isnan(above_divided_below[s])
                above_divided_below[s] = 1.0
            end
        end

        if hasdim(callback.above_biomass, :species)
            for s in 1:nspecies
                u_above_biomass[s] = callback.above_biomass[time = At(t), species = s]
                u_below_biomass[s] = u_above_biomass[s] / above_divided_below[s]
                u_biomass[s] = u_above_biomass[s] + u_below_biomass[s]
            end
        else
            @. u_above_biomass = callback.above_biomass[time = At(t)]
            @. u_below_biomass = u_above_biomass / above_divided_below
            @. u_biomass = u_above_biomass + u_below_biomass
        end
    end
end


### helper functions
@inline tuplejoin(x) = x
@inline tuplejoin(x, y) = (; x..., y...)
@inline tuplejoin(x, y, z...) = (; x..., tuplejoin(y, z...)...)

celsius_int = typeof(1u"°C")
celsius_float = typeof(1.0u"°C")

Base.:+(a::celsius_int, b::celsius_int) = float(a) + float(b)
Base.:+(a::celsius_float, b::celsius_int) = a + float(b)
Base.:+(a::celsius_int, b::celsius_float) = float(a) + b
Base.:+(a::celsius_float, b::celsius_float) = (ustrip(a) + ustrip(b)) * u"°C"

Base.:-(a::celsius_int, b::celsius_int) = float(a) - float(b)
Base.:-(a::celsius_float, b::celsius_int) = a - float(b)
Base.:-(a::celsius_int, b::celsius_float) = float(a) - b
Base.:-(a::celsius_float, b::celsius_float) = (ustrip(a) - ustrip(b)) * u"°C"

Base.:/(a::celsius_int, b::celsius_int) = float(a) / float(b)
Base.:/(a::celsius_float, b::celsius_int) = a / float(b)
Base.:/(a::celsius_int, b::celsius_float) = float(a) / b
Base.:/(a::celsius_float, b::celsius_float) = ustrip(a) / ustrip(b)

Base.:*(a::Number, b::celsius_int) = a * float(b)
Base.:*(a::celsius_int, b::Number) = float(a) * b
Base.:*(a::celsius_float, b::Number) = ustrip(a) * b * u"°C"
Base.:*(a::Number, b::celsius_float) = a * ustrip(b) * u"°C"

celsius_vec_int = typeof([1u"°C"])
celsius_vec_float = typeof([1.0u"°C"])

Statistics.mean(x::celsius_vec_int) = mean(float.(x))
Statistics.mean(x::celsius_vec_float) = mean(ustrip.(x)) * u"°C"

to_numeric(d::Dates.Date) = Dates.year(d) + (Dates.dayofyear(d) - 1) /
                            Dates.daysinyear(Dates.year(d))
