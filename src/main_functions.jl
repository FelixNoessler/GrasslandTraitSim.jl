"""
    solve_prob(; input_obj, inf_p, calc = nothing)

Solve the model for one site.

Intialize the parameters, the state variables and the output vectors.
In addition some vectors are preallocated to avoid allocations in the main loop.
Then, run the main loop and store the results with all parameters in a container.
"""
function solve_prob(; input_obj, inf_p, calc = nothing, trait_input = nothing)
    if isnothing(calc)
        calc = preallocate_vectors(; input_obj)
    end

    container = initialization(; input_obj, inf_p, calc, trait_input)

    main_loop!(; container)

    @unpack biomass = container.o
    @unpack negbiomass = container.calc

    ## set negative values to zero
    @. negbiomass = biomass < 0u"kg / ha"
    for i in eachindex(negbiomass)
        if negbiomass[i]
            biomass[i] = 0u"kg / ha"
        end
    end

    return container
end

"""
    main_loop!(; container)

Run the main loop for all days.

Calls the function [`one_day!`](@ref) for each day and set the
calculated density differences to the output variables.
"""
function main_loop!(; container)
    @unpack u_biomass, u_water = container.u
    @unpack du_biomass, du_water = container.du
    @unpack biomass, water = container.o

    for t in container.ts
        one_day!(; t, container)

        u_biomass .+= du_biomass .* u"d"
        u_water .+= du_water .* u"d"
        biomass[t, :, :] .= u_biomass
        water[t, :] .= u_water
    end
end

### helper functions
@inline tuplejoin(x) = x
@inline tuplejoin(x, y) = (; x..., y...)
@inline tuplejoin(x, y, z...) = (; x..., tuplejoin(y, z...)...)
