@doc raw"""
Calculate the total potential growth of the plant community.

```math
\begin{align*}
G_{pot, txy} &= PAR_{txy} \cdot RUE_{max} \cdot fPARi_{txy} \\
fPARi_{txy} &= \left(1 - \exp\left(-k \cdot LAI_{tot, txy}\right)\right) \cdot
    \frac{1}
    {1 + \exp\left(\beta_{comH} \cdot \left(\alpha_{comH} - H_{cwm, txy}\right)\right)}
\end{align*}
```

Parameter, see also [`SimulationParameter`](@ref):
- ``RUE_{max}`` (`RUE_max`) maximum radiation use efficiency [kg MJ⁻¹]
- ``k`` (`k`) extinction coefficient [-]
- ``\alpha_{comH}`` (`α_com_height`) is the community weighted mean height, where the community height growth reducer is 0.5 [m]
- ``\beta_{comH}`` (`β_com_height`) is the slope of the logistic function that relates the community weighted mean height to the community height growth reducer [m⁻¹]

Variables:
- ``PAR_{txy}`` (`PAR`) photosynthetically active radiation [MJ ha⁻¹]
- ``LAI_{tot, txy}`` (`LAItot`) total leaf area index, see [`calculate_LAI!`](@ref) [-]

Output:
- ``G_{pot; txy}`` (`potgrowth_total`) total potential growth of the plant community [kg ha⁻¹]

Note:
The community height growth reduction factor is the second part of the ``fPARi_{txy}`` equation.

![](../img/potential_growth_lai_height.svg)
![](../img/potential_growth_height_lai.svg)
![](../img/potential_growth_height.svg)
![](../img/community_height_influence.svg)
"""
function potential_growth!(; container, biomass, PAR)
    @unpack included = container.simp
    @unpack com = container.calc

    calculate_LAI!(; container, biomass)

    if !included.potential_growth
        @info "Zero potential growth!" maxlog=1
        com.potgrowth_total = 0.0u"kg / ha"
        return nothing
    end

    if !included.community_height_red
        @info "No community height growth reduction!" maxlog=1
        com.comH_reduction = 1.0
    else
        @unpack relative_height = container.calc
        @unpack height = container.traits
        @unpack α_com_height, β_com_height = container.p
        relative_height .= height .* biomass ./ sum(biomass)
        height_cwm = sum(relative_height)
        com.comH_reduction = 1 / (1 + exp(β_com_height * (α_com_height - height_cwm)))
    end

    @unpack RUE_max, k = container.p
    com.potgrowth_total = PAR * RUE_max * (1 - exp(-k * com.LAItot)) * com.comH_reduction

    return nothing
end

@doc raw"""
Calculate the leaf area index of all species.

```math
\begin{align}
LAI_{txys} &= B_{txys} \cdot SLA_s \cdot \frac{LBP_s}{ABP_s} \\
LAI_{tot, txy} &= \sum_{s=1}^{S} LAI_{txys}
\end{align}
```

Variables:
- ``B_{txys}`` (`biomass`) dry aboveground biomass of each species  [kg ha⁻¹]
- ``SLA_s`` (`sla`) specific leaf area [m² g⁻¹]
- ``LBP_s`` (`lbp`) leaf biomass per plant biomass [-]
- ``ABP_s`` (`abp`) aboveground biomass per plant biomass [-]

There is a unit conversion from the ``SLA_s`` and the biomass ``B_{txys}``
to the unitless ``LAI_{txys}`` involved.

Output:
- ``LAI_{txys}`` (`LAIs`) leaf area index of each species [-]
- ``LAI_{tot, txy}`` (`LAItot`) total leaf area index of the plant community [-]

![](../img/lai_traits.png)
"""
function calculate_LAI!(; container, biomass)
    @unpack LAIs, com = container.calc
    @unpack sla, lbp = container.traits

    for s in eachindex(LAIs)
        LAIs[s] = uconvert(NoUnits, sla[s] * biomass[s] * lbp[s])
    end
    com.LAItot = sum(LAIs)

    return nothing
end


################################################################
# Plots for potential growth
################################################################
function plot_potential_growth_lai_height(; path = nothing)
    nspecies, container = create_container_for_plotting(; )
    biomass = container.u.u_biomass[1, 1, :]
    biomass_vals = LinRange(0, 100, 150)u"kg / ha"

    height_vals = reverse([0.2, 0.5, 1.0, 100000.0]u"m")
    ymat = Array{Float64}(undef, length(height_vals), length(biomass_vals))
    lai_tot = Array{Float64}(undef, length(biomass_vals))

    for (hi, h) in enumerate(height_vals)
        container.traits.height .= h
        for (i,b) in enumerate(biomass_vals)
            biomass .= b
            potential_growth!(; container, biomass, PAR = container.input.PAR[150])

            ymat[hi, i] = ustrip(container.calc.com.potgrowth_total)
            lai_tot[i] = sum(container.calc.LAIs)
        end
    end

    fig = Figure(; size = (600, 400))
    Axis(fig[1, 1],
        xlabel = "Total leaf area index [-]",
        ylabel = "Total potential growth [kg ha⁻¹]")
    lines!(lai_tot, ymat[1, :]; linewidth = 3.0,
           label = "without com. height red.")
    lines!(lai_tot, ymat[2, :]; linewidth = 3.0,
        label = "$(ustrip(height_vals[2]))")
    lines!(lai_tot, ymat[3, :]; linewidth = 3.0,
        label = "$(ustrip(height_vals[3]))")
    lines!(lai_tot, ymat[4, :]; linewidth = 3.0,
        label = "$(ustrip(height_vals[4]))")
    axislegend("Community weighted\nmean height [m]";
               position = :lt, framevisible = true)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end

function plot_potential_growth_height_lai(; path = nothing)
    nspecies, container = create_container_for_plotting()
    biomass_val = [50.0, 35.0, 10.0]u"kg / ha"
    biomass = container.u.u_biomass[1,1,:]
    lais = zeros(3)
    heights = LinRange(0.01, 2, 300)
    red = Array{Float64}(undef, 3, length(heights))
    for (li, l) in enumerate(lais)
        for (hi, h) in enumerate(heights)
            biomass .= biomass_val[li]
            @reset container.traits.height = [h * u"m"]
            potential_growth!(; container, biomass, PAR = container.input.PAR[150])
            pot_gr = ustrip(container.calc.com.potgrowth_total)

            lais[li] = round(container.calc.com.LAItot; digits = 1)
            red[li, hi] = pot_gr
        end
    end

    fig = Figure()
    Axis(fig[1,1]; xlabel = "Community weighted mean height [m]",
         ylabel = "Total potential growth [kg ha⁻¹]")
    linewidth = 3.0
    lines!(heights, red[1, :]; linewidth, label = "$(lais[1])")
    lines!(heights, red[2, :]; linewidth, label = "$(lais[2])")
    lines!(heights, red[3, :]; linewidth, label = "$(lais[3])")
    axislegend("Total leaf\narea index [-]"; framevisible = false, position = :rb)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end

################################################################
# Plots for leaf area index
################################################################
function plot_lai_traits(; path = nothing)
    nspecies, container = create_container_for_plotting()
    biomass = container.u.u_biomass[1, 1, :]

    potential_growth!(; container, biomass, PAR = container.input.PAR[150])
    val = container.calc.LAIs

    idx = sortperm(container.traits.sla)
    ymat = val[idx]
    sla = ustrip.(container.traits.sla[idx])


    abp = (container.traits.abp)[idx]
    colorrange = (minimum(abp), maximum(abp))
    colormap = :viridis

    fig = Figure()
    ax = Axis(fig[1, 1]; xlabel = "Specific leaf area [m² g⁻¹]", ylabel = "Leaf area index [-]", title = "")
    sc = scatter!(sla, ustrip(ymat), color = abp, colormap = colormap)
    Colorbar(fig[1,2], sc; label = "Aboveground biomass per total biomass")

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end

################################################################
# Plots for community height reduction
################################################################
function plot_potential_growth_height(; path = nothing)
    nspecies, container = create_container_for_plotting()

    biomass = container.u.u_biomass[1,1,:]

    heights = LinRange(0.01, 2, 300)
    red = Array{Float64}(undef, length(heights))

    for (hi, h) in enumerate(heights)
        @reset container.traits.height = [h * u"m"]
        potential_growth!(; container, biomass, PAR = container.input.PAR[150])
        red[hi] = container.calc.com.comH_reduction
    end

    fig = Figure()
    Axis(fig[1,1]; xlabel = "Community weighted mean height [m]",
         ylabel = "Community height growth reduction factor [-]")
    lines!(heights, red; linewidth = 3.0)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end

function plot_community_height_influence(; path = nothing)
    trait_input = input_traits()
    for k in keys(trait_input)
        @reset trait_input[k] = [mean(trait_input[k])]
    end
    input_obj = validation_input(;
        plotID = "HEG01", nspecies = 1);
    input_obj.input.LD_grazing .= NaN * u"ha^-1"
    input_obj.input.CUT_mowing .= NaN * u"m"
    p = SimulationParameter()

    function sim_community_height(; community_height_red)
        @reset input_obj.simp.included.community_height_red .= community_height_red
        @reset trait_input.height = [0.1u"m"]
        sol_small = solve_prob(; input_obj, p, trait_input);
        s = vec(ustrip.(sol_small.output.biomass[:, 1, 1, 1]))

        @reset trait_input.height = [1.0u"m"]
        sol_large = solve_prob(; input_obj, p, trait_input);
        l = vec(ustrip.(sol_large.output.biomass[:, 1, 1, 1]))

        return sol_small.simp.output_date_num, s, l
    end
    tstep = 30

    fig = Figure(; size = (600, 600))

    Axis(fig[1, 1]; limits = (nothing, nothing, 0, nothing),
         title = "Without community height reduction",
         xlabel = "", ylabel = "", xticklabelsvisible = false)
    t, s, l = sim_community_height(; community_height_red = false)
    lines!(t[1:tstep:end], l[1:tstep:end]; label = "1.0 m")
    lines!(t[1:tstep:end], s[1:tstep:end]; label = "0.1 m")

    Axis(fig[2, 1]; limits = (nothing, nothing, 0, nothing),
        title = "With community height reduction",
        xlabel = "Date [year]", ylabel = "")
    t, s, l = sim_community_height(; community_height_red = true)

    lines!(t[1:tstep:end], l[1:tstep:end]; label = "1.0 m")
    lines!(t[1:tstep:end], s[1:tstep:end]; label = "0.1 m")
    axislegend(; framevisible = false, position = :rb)

    Label(fig[1:2, 0], "Dry aboveground biomass [kg ha⁻¹]",
          rotation= pi/2, fontsize = 16)

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
