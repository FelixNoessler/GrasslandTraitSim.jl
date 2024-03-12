"""
    solve_prob(; input_obj, inf_p, calc = nothing)

Solve the model for one site.

Intialize the parameters, the state variables and the output vectors.
In addition some vectors are preallocated to avoid allocations in the main loop.
Then, run the main loop and store the results with all parameters in a container.
"""
function solve_prob(; input_obj, p, prealloc = nothing, prealloc_specific = nothing,
                     trait_input = nothing, θ_type = Float64)
    if isnothing(prealloc)
        prealloc = preallocate_vectors(; input_obj, T = θ_type)
    end

    if isnothing(prealloc_specific)
        prealloc_specific = preallocate_specific_vectors(; input_obj, T = θ_type)
    end

    container = initialization(; input_obj, p, prealloc, prealloc_specific,
                               trait_input, θ_type)

    main_loop!(; container)

    @unpack biomass = container.output
    @unpack negbiomass = container.calc

    negbiomass .= biomass .< 0.0u"kg / ha"
    if any(negbiomass)
        biomass[negbiomass] .= 0.0u"kg / ha"
    end

    ## this has fewer allocations, but is slower in for forwardiff
    # for i in eachindex(biomass)
    #     if biomass[i] < 0.0u"kg / ha"
    #         biomass[i] = 0.0u"kg / ha"
    #     end
    # end

    calc_cut_biomass!(; container)

    return container
end

"""
    main_loop!(; container)

Run the main loop for all days.

Calls the function [`one_day!`](@ref) for each day and set the
calculated density differences to the output variables.
"""
function main_loop!(; container)
    @unpack u_biomass, u_water, du_biomass, du_water = container.u
    @unpack biomass, water = container.output
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
