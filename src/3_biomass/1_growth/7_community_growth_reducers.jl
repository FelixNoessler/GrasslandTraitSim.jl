"""
Reduction of radiation use efficiency at high radiation levels.
"""
function radiation_reduction!(; container, PAR)
    @unpack included = container.simp
    @unpack com = container.calc

    if !included.radiation_growth_reduction
        @info "No radiation reduction!" maxlog=1
        com.RAD = 1.0
        return nothing
    end

    @unpack γ₁, γ₂ = container.p
    com.RAD = max(min(1.0, 1.0 − γ₁ * (PAR − γ₂)), 0.0)

    return nothing
end

"""
Reduction of the growth if the temperature is low or too high.
"""
function temperature_reduction!(; container, T)
    @unpack included = container.simp
    @unpack com = container.calc

    if !included.temperature_growth_reduction
        @info "No temperature reduction!" maxlog=1
        com.TEMP = 1.0
        return nothing
    end

    @unpack ω_TEMP_T1, ω_TEMP_T2, ω_TEMP_T3, ω_TEMP_T4 = container.p

    if T < ω_TEMP_T1
        com.TEMP = 0.0
    elseif T < ω_TEMP_T2
        com.TEMP = (T - ω_TEMP_T1) / (ω_TEMP_T2 - ω_TEMP_T1)
    elseif T < ω_TEMP_T3
        com.TEMP = 1.0
    elseif T < ω_TEMP_T4
        com.TEMP = (ω_TEMP_T4 - T) / (ω_TEMP_T4 - ω_TEMP_T3)
    else
        com.TEMP = 0.0
    end

    return nothing
end

"""
Adjustment of growth due to seasonal effects.
"""
function seasonal_reduction!(; container, ST)
    @unpack included = container.simp
    @unpack com = container.calc

    if !included.seasonal_growth_adjustment
        @info "No seasonal reduction!" maxlog=1
        com.SEA = 1.0
        return nothing
    end

    @unpack SEA_min, SEA_max, ST₁, ST₂ = container.p

    if ST < 200.0u"°C"
        com.SEA = SEA_min
    elseif ST < ST₁ - 200.0u"°C"
        com.SEA = SEA_min + (SEA_max - SEA_min) * (ST - 200.0u"°C") / (ST₁ - 400.0u"°C")
    elseif ST < ST₁ - 100.0u"°C"
        com.SEA = SEA_max
    elseif ST < ST₂
        com.SEA = SEA_min + (SEA_min - SEA_max) * (ST - ST₂) / (ST₂ - (ST₁ - 100.0u"°C"))
    else
        com.SEA = SEA_min
    end

    return nothing
end

function plot_radiation_reducer(; PARs = LinRange(0.0, 15.0 * 100^2, 1000)u"MJ / ha",
                           θ = nothing, path = nothing)

    nspecies, container = create_container_for_plotting(; nspecies = 1, θ)
    PARs = sort(ustrip.(PARs)) .* unit(PARs[1])

    y = Float64[]

    for PAR in PARs
        radiation_reduction!(; PAR, container)
        push!(y, container.calc.com.RAD)
    end

    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1];
        ylabel = "Growth reduction (RAD)",
        xlabel = "Photosynthetically active radiation (PAR) [MJ ha⁻¹]",
        title = "Radiation reducer function")

    PARs = ustrip.(PARs)

    if length(y) > 1000
        scatter!(PARs, y,
            markersize = 5,
            color = (:magenta, 0.05))
    else
        lines!(PARs, y,
            linewidth = 3,
            color = :magenta)
    end
    ylims!(-0.05, 1.05)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end

function plot_temperature_reducer(; Ts = collect(LinRange(0.0, 40.0, 500)) .* u"°C",
                            θ = nothing, path = nothing)

    nspecies, container = create_container_for_plotting(; nspecies = 1, θ)

    y = Float64[]
    for T in Ts
        temperature_reduction!(; T, container)
        push!(y, container.calc.com.TEMP)
    end

    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1];
        ylabel = "Growth reduction (TEMP)",
        xlabel = "Air temperature [°C]",
        title = "Temperature reducer function")

    if length(y) > 500
        scatter!(ustrip.(Ts), y,
            markersize = 5,
            color = (:coral3, 0.5))
    else
        lines!(ustrip.(Ts), y,
            linewidth = 3,
            color = :coral3)
    end

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end

function plot_seasonal_effect(; θ = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; nspecies = 1, θ)
    STs = LinRange(0, 3500, 1000)
    y = Float64[]
    for ST in STs
        seasonal_reduction!(; ST = ST * u"°C", container)
        push!(y, container.calc.com.SEA)
    end

    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1];
        ylabel = "Seasonal factor (SEA)",
        xlabel = "Yearly accumulated temperature (ST) [K]",
        title = "Seasonal effect")

    if length(y) > 1000
        scatter!(STs, y;
            markersize = 3,
            color = (:navajowhite4, 0.1))
    else
        lines!(ustrip.(STs), y;
            linewidth = 3,
            color = :navajowhite4)
    end

    ylims!(-0.05, 2.5)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
