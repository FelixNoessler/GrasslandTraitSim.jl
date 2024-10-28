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

    @unpack γ_RAD1, γ_RAD2 = container.p
    com.RAD = max(min(1.0, 1.0 − γ_RAD1 * (PAR − γ_RAD2)), 0.0)

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

    @unpack ζ_SEAmin, ζ_SEAmax, ζ_SEA_ST1, ζ_SEA_ST2 = container.p

    if ST < 200.0u"°C"
        com.SEA = ζ_SEAmin
    elseif ST < ζ_SEA_ST1 - 200.0u"°C"
        com.SEA = ζ_SEAmin + (ζ_SEAmax - ζ_SEAmin) * (ST - 200.0u"°C") / (ζ_SEA_ST1 - 400.0u"°C")
    elseif ST < ζ_SEA_ST1 - 100.0u"°C"
        com.SEA = ζ_SEAmax
    elseif ST < ζ_SEA_ST2
        com.SEA = ζ_SEAmin + (ζ_SEAmin - ζ_SEAmax) * (ST - ζ_SEA_ST2) / (ζ_SEA_ST2 - (ζ_SEA_ST1 - 100.0u"°C"))
    else
        com.SEA = ζ_SEAmin
    end

    return nothing
end
