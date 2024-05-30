"""
The actual height is reduced if plant species have a low biomass.

![image relating actual height to aboveground biomass](../img/actual_height.png)
"""
function actual_height!(; container, biomass, state_height)
    @unpack β_lowB, α_lowB = container.p
    @unpack height, abp = container.traits
    @unpack above_biomass, actual_height = container.calc

    @. above_biomass = abp * biomass
    @. actual_height = state_height #height * 1.0 / (1.0 + exp(-β_lowB * (above_biomass - α_lowB)))

    return nothing
end


function plot_actual_height(; path = nothing, θ = nothing)
    nspecies, container = create_container_for_plotting(; θ)
    abp = container.traits.abp
    nbiomass = 150
    biomass_vec = LinRange(0, 200, nbiomass)u"kg / ha"
    actual_height_mat = zeros(nbiomass, nspecies)u"m"

    for i in eachindex(biomass_vec)
        biomass = 1 ./ abp .* biomass_vec[i]
        actual_height!(; container, biomass)
        actual_height_mat[i, :] .= container.calc.actual_height
    end

    biomass_plotting = ustrip.(biomass_vec)
    actual_height_mat_plotting = ustrip.(actual_height_mat)

    fig = Figure()
    Axis(fig[1,1]; xlabel = "Aboveground biomass [kg ha⁻¹]",
         ylabel = "Actual height [m]")
    for i in 1:nspecies
        lines!(biomass_plotting, actual_height_mat_plotting[:, i]; color = (:black, 0.5))
    end

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
