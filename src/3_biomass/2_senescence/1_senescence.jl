"""
Calculate the biomass that dies due to senescence.
"""
function senescence!(; container, ST, total_biomass)
    @unpack senescence, senescence_rate, com = container.calc
    @unpack included, time_step_days = container.simp

    if !included.senescence
        @. senescence = 0.0u"kg/ha"
        return nothing
    end

    com.SEN_season = if included.senescence_season
        seasonal_component_senescence(; container, ST)
    else
        1.0
    end

    @. senescence = (1 - (1 - senescence_rate * com.SEN_season) ^ time_step_days.value) * total_biomass

    return nothing
end

"""
Intialize the basic senescence rate based on the specific leaf area.
"""
function initialize_senescence_rate!(; container)
    @unpack included = container.simp
    @unpack senescence_rate, senescence_sla =  container.calc

    if !included.senescence
        @. senescence_rate = 0.0
        return nothing
    end

    if included.senescence_sla
        @unpack β_SEN_sla, ϕ_sla = container.p
        @unpack sla = container.traits
        @. senescence_sla = (sla / ϕ_sla) ^ β_SEN_sla
    else
        @. senescence_sla = 1.0
    end

    @unpack α_SEN_month = container.p
    days_per_month = 30.44
    senescence_per_day = 1 - (1 - α_SEN_month) ^ (1 / days_per_month)

    @. senescence_rate  = senescence_per_day * senescence_sla
    return nothing
end


"""
Seasonal factor for the senescence rate.
"""
function seasonal_component_senescence(; container, ST,)
    @unpack ψ_SEN_ST1, ψ_SEN_ST2, ψ_SENmax = container.p

    lin_increase = ST -> 1 + (ψ_SENmax - 1) * (ST - ψ_SEN_ST1) / (ψ_SEN_ST2 - ψ_SEN_ST1)
    SEN = ST < ψ_SEN_ST1 ? 1 : ST < ψ_SEN_ST2 ? lin_increase(ST) : ψ_SENmax

    return SEN
end
