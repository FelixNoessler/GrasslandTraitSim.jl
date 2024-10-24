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
function senescence_rate!(; container)
    @unpack included = container.simp
    @unpack μ, senescence_sla =  container.calc

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
    @unpack Ψ_ST1, Ψ_ST2, Ψ_SENmax = container.p

    lin_increase = ST -> 1 + (Ψ_SENmax - 1) * (ST - Ψ_ST1) / (Ψ_ST2 - Ψ_ST1)
    SEN = ST < Ψ_ST1 ? 1 : ST < Ψ_ST2 ? lin_increase(ST) : Ψ_SENmax

    return SEN
end

function plot_seasonal_component_senescence(;
    STs = LinRange(0, 4000, 500),
    θ = nothing, path = nothing)

    nspecies, container = create_container_for_plotting(; nspecies = 1, θ)
    STs = sort(STs)

    y = Float64[]
    for ST in STs
        g = seasonal_component_senescence(; container, ST = ST * u"°C")
        push!(y, g)
    end

    fig = Figure(; size = (700, 400))
    Axis(fig[1, 1];
        ylabel = "Seasonal factor for senescence (SEN)",
        xlabel = "Annual cumulative temperature (ST) [°C]",
        title = "")

    if length(y) > 1000
        scatter!(STs, y;
            markersize = 3,
            color = (:navajowhite4, 0.1))
    else
        lines!(STs, y;
            linewidth = 3,
            color = :navajowhite4)
    end
    ylims!(-0.05, 3.5)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end


function plot_senescence_rate(; θ = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; θ)
    @unpack sla = container.traits
    @unpack β_sen_sla, α_sen_month = container.p
    @unpack p = container
    nvals = 200
    β_sen_sla_values = LinRange(0, 2, nvals)
    ymat = Array{Float64}(undef, nvals, nspecies)

    for i in eachindex(β_sen_sla_values)
        p.β_sen_sla = β_sen_sla_values[i]
        senescence_rate!(; container)
        @. ymat[i, :] = container.calc.μ
    end

    sla_plot = ustrip.(sla)
    colorrange = (minimum(sla_plot), maximum(sla_plot))
    fig = Figure()
    Axis(fig[1,1]; xlabel = "β_sen_sla [Mg ha⁻¹]", ylabel = "Senescence rate [-]")

    for i in 1:nspecies
        lines!(β_sen_sla_values, ymat[:, i]; color = sla_plot[i], colorrange)
    end
    hlines!(α_sen_month; color = :orange, linewidth = 3, linestyle = :dash)
    vlines!(ustrip(β_sen_sla))
    text!(1.5, α_sen_month * 1.01, text = "α_sen_month";)

    Colorbar(fig[1, 2]; colorrange, label = "Specific leaf area [m² g⁻¹]")


    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
