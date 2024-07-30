@doc raw"""
Calculate the biomass that dies due to senescence.

"""
function senescence!(; container, ST, total_biomass)
    @unpack senescence, μ, com = container.calc
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

    @. senescence = (1 - (1 - μ * com.SEN_season) ^ time_step_days.value) * total_biomass

    return nothing
end

"""
Intialize the basic senescence rate based on the specific leaf area
"""
function senescence_rate!(; container)
    @unpack included = container.simp
    @unpack μ, μ_sla =  container.calc

    if !included.senescence
        @. μ = 0.0
        return nothing
    end

    if included.senescence_sla
        @unpack β_sen_sla, ϕ_sen_sla = container.p
        @unpack sla = container.traits
        @. μ_sla = (sla / ϕ_sen_sla) ^ β_sen_sla
    else
        @. μ_sla = 1.0
    end

    @unpack α_sen = container.p
    @. μ  = α_sen * μ_sla # TODO
    return nothing
end


@doc raw"""
Seasonal factor for the senescence rate.

```math
\begin{align*}
SEN &=
\begin{cases}
1  & \text{if} \;\; ST < Ψ_1 \\
1+(SEN_{max} - 1) \frac{ST - Ψ_1}{Ψ_2 - Ψ_1} & \text{if}\;\; Ψ_1 < ST < Ψ_2 \\
SEN_{max}  & \text{if}\;\; ST > Ψ_2
\end{cases} \\ \\
\end{align*}
```

- ``ST`` annual cumulative temperature [$°C$]
- ``Ψ₁=775``  [$°C$]
- ``Ψ₂=3000`` [$°C$]
- ``SEN_{max}=3``

![Seasonal component death rate](../img/seasonal_factor_senescence.png)
"""
function seasonal_component_senescence(; container, ST,)
    @unpack Ψ₁, Ψ₂, SEN_max = container.p

    lin_increase(ST) = 1 + (SEN_max - 1) * (ST - Ψ₁) / (Ψ₂ - Ψ₁)
    SEN = ST < Ψ₁ ? 1 : ST < Ψ₂ ? lin_increase(ST) : SEN_max

    return SEN
end

function plot_seasonal_component_senescence(;
    STs = LinRange(0, 4000, 500),
    θ = nothing, path = nothing)

    nspecies, container = create_container_for_plotting(; nspecies = 1, θ)
    STs = sort(STs)

    y = Float64[]
    for ST in STs
        g = seasonal_component_senescence(; container, ST)
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
    @unpack β_sen_sla, α_sen = container.p
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
    hlines!(α_sen; color = :orange, linewidth = 3, linestyle = :dash)
    vlines!(ustrip(β_sen_sla))
    text!(1.5, α_sen * 1.01, text = "α_sen";)

    Colorbar(fig[1, 2]; colorrange, label = "Specific leaf area [m² g⁻¹]")


    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
