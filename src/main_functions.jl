"""
    solve_prob(; input_obj, inf_p, calc = nothing)

Solve the model for one site.

Intialize the parameters, the state variables and the output vectors.
In addition some vectors are preallocated to avoid allocations in the main loop.
Then, run the main loop and store the results with all parameters in a container.
"""
function solve_prob(; input_obj, inf_p, calc = nothing, trait_input = nothing)
    if isnothing(calc)
        calc = preallocate_vectors(; input_obj, dtype = typeof(inf_p[1]))
    end

    container = initialization(; input_obj, inf_p, calc, trait_input)

    main_loop!(; container)


    @unpack biomass = container.u
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
    @unpack u_biomass, u_water, du_biomass, du_water, biomass, water = container.u
    @unpack patch_xdim, patch_ydim, nspecies = container.simp

    for t in container.ts
        one_day!(; t, container)

        for x in Base.OneTo(patch_xdim)
            for y in Base.OneTo(patch_ydim)
                for s in Base.OneTo(nspecies)
                    u_biomass[x, y, s] += du_biomass[x, y, s] * u"d"
                    biomass[t, x, y, s] = u_biomass[x, y, s]
                end

                u_water[x, y] += du_water[x, y] * u"d"
                water[t, x, y] = u_water[x, y]
            end
        end
    end

    return nothing
end

### helper functions
@inline tuplejoin(x) = x
@inline tuplejoin(x, y) = (; x..., y...)
@inline tuplejoin(x, y, z...) = (; x..., tuplejoin(y, z...)...)
