"""
Solve the model for one site.

All input variables are explained in a tutorial:
[How to prepare the input data to start a simulation](@ref)

There is also a tutorial on the model output:
[How to analyse the model output](@ref)
"""
function solve_prob(; input_obj, p, prealloc = nothing, trait_input = nothing,
                    callback = (; t = []))

    if ! (p isa SimulationParameter)
        simulation_keys = keys(SimulationParameter())
        p_subset = NamedTuple{filter(x -> x ∈ simulation_keys, keys(p))}(p)
        p = SimulationParameter(; p_subset...)
    end

    if isnothing(prealloc)
        prealloc = preallocate_vectors(; input_obj)
    end

    container = initialization(; input_obj, p, prealloc, trait_input, callback)
    main_loop!(; container)

    return container
end

"""
Run the main loop for all days. Calls the function [`one_day!`](@ref) for each day
and set the calculated density differences to the output variables.
"""
function main_loop!(; container)
    @unpack u_biomass, u_above_biomass, u_below_biomass, u_water, u_height,
            du_biomass, du_above_biomass, du_below_biomass, du_water, du_height = container.u
    @unpack output = container
    @unpack ts, patch_xdim, patch_ydim, nspecies = container.simp
    @unpack senescence = container.calc

    for t in ts
        one_day!(; t, container)

        for x in Base.OneTo(patch_xdim)
            for y in Base.OneTo(patch_ydim)
                for s in Base.OneTo(nspecies)
                    u_biomass[x, y, s] += du_biomass[x, y, s]
                    output.biomass[t+1, x, y, s] = max(u_biomass[x, y, s], 0.0u"kg/ha")

                    u_above_biomass[x, y, s] += du_above_biomass[x, y, s]
                    u_below_biomass[x, y, s] += du_below_biomass[x, y, s]
                    output.above_biomass[t+1, x, y, s] = max(u_above_biomass[x, y, s], 0.0u"kg/ha")
                    output.below_biomass[t+1, x, y, s] = max(u_below_biomass[x, y, s], 0.0u"kg/ha")

                    u_height[x, y, s] += du_height[x, y, s]
                    output.height[t+1, x, y, s] = u_height[x, y, s]
                end

                u_water[x, y] += du_water[x, y]
                output.water[t+1, x, y] = u_water[x, y]
            end
        end

        callback_above_biomass!(; t, container)
    end

    return nothing
end

function callback_above_biomass!(; t, container)
    @unpack callback = container
    @unpack u_above_biomass, u_below_biomass, u_biomass = container.u

    if t ∈ callback.t
        ab_bb = u_above_biomass ./ u_below_biomass
        @. u_above_biomass = callback.above_biomass[t = At(t)]
        @. u_below_biomass = u_above_biomass / ab_bb
        @. u_biomass = u_above_biomass + u_below_biomass
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
