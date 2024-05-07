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

![](../img/lai_traits.svg)
"""
function calculate_LAI!(; container, biomass)
    @unpack LAIs, com = container.calc
    @unpack sla, lbp, abp = container.traits

    for s in eachindex(LAIs)
        LAIs[s] = uconvert(NoUnits, sla[s] * biomass[s] * lbp[s] / abp[s])
    end
    com.LAItot = sum(LAIs)

    return nothing
end
