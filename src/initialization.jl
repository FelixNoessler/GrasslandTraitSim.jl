"""
    planar_gradient!(; mat, direction)

Fills a matrix with a gradient with values from 0 to 1.

The `direction` controls the direction of the gradient.

![](../img/gradient.svg)
"""
function planar_gradient!(; mat, direction = 100)
    # based on:
    # https://github.com/EcoJulia/NeutralLandscapes.jl/blob/main/src/makers/planargradient.jl

    eastness = sin(deg2rad(direction))
    southness = -1cos(deg2rad(direction))
    rows, cols = axes(mat)
    mat .= rows .* southness .+ cols' .* eastness

    mn = minimum(mat)
    mx = maximum(mat)
    mat .= (mat .- mn) ./ (mx - mn)

    return nothing
end



@doc raw"""
    input_nutrients!(; calc, input_obj, inf_p, nutheterog, totalN, CNratio)

Derive a nutrient index by combining total nitrogen and carbon to nitrogen ratio.

```math
\begin{align*}
\text{CN_scaled} &= \frac{\text{CNratio} - \text{minCNratio}}
                    {\text{maxCNratio} - \text{minCN_ratio}} \\
\text{totalN_scaled} &= \frac{\text{totalN} - \text{mintotalN}}
                        {\text{maxtotalN} - \text{mintotalN}} \\
\text{nutrients} &= \frac{1}{1 + exp(-\text{totalN_β} ⋅ \text{totalN_scaled}
                                     -\text{CN_β} ⋅ \text{CN_scaled}⁻¹)}
\end{align*}
```

- `CNratio`: carbon to nitrogen ratio [-]
- `totalN`: total nitrogen [g kg⁻¹]
- `minCNratio`: minimum carbon to nitrogen ratio [-]
- `maxCNratio`: maximum carbon to nitrogen ratio [-]
- `mintotalN`: minimum total nitrogen [g kg⁻¹]
- `maxtotalN`: maximum total nitrogen [g kg⁻¹]
- `totalN_β`: scaling parameter for total nitrogen [-]
- `CN_β`: scaling parameter for carbon to nitrogen ratio [-]
- `nutrients`: nutrient index [-]

Additionally if more than one patch is simulated a gradient of nutrients can be added
and the last equations changes to:

```math
\text{nutrients} = \frac{1}{1 + exp(-\text{totalN_β} ⋅ \text{totalN_scaled}
                                    -\text{CN_β} ⋅ \text{CN_scaled}⁻¹
                                    -\text{nutheterog} * (\text{nutgradient} - 0.5))}
```

- `nutheterog`: heterogeneity of nutrients [-]
- `nutgradient`: gradient of nutrients between 0 and 1 [-],
  created by [`planar_gradient!`](@ref)
"""
function input_nutrients!(; calc, input_obj, inf_p)
    @unpack nutrients = calc.u
    @unpack totalN, CNratio = input_obj.site
    @unpack totalN_β, CN_β = inf_p

    #### data from the biodiversity exploratories
    # mintotalN = 1.2525
    # maxtotalN = 30.63
    # minCNratio = 9.0525
    # maxCNratio = 13.6025

    mintotalN = 0.0
    maxtotalN = 50.0
    minCNratio = 5.0
    maxCNratio = 25.0

    totalN_scaled = @. (totalN - mintotalN) / (maxtotalN - mintotalN)
    CN_scaled = @. (CNratio - minCNratio) / (maxCNratio - minCNratio)

    @. nutrients = 1 / (1 + exp(-totalN_β * totalN_scaled - CN_β * 1 / CN_scaled ))

    return nothing
end

@doc raw"""
    input_WHC_PWP!(; calc, input_obj)

Derive walter holding capacity (WHC) and
permanent wilting point (PWP) from soil properties.

```math
\begin{align}
    θ₁ &= a₁ ⋅ \text{sand} + b₁ ⋅ \text{silt} + c₁ ⋅ \text{clay} +
            d₁ ⋅ \text{organic} + e₁ ⋅ \text{bulk} \\
    \text{WHC} &= θ₁ ⋅ \text{rootdepth} \\
    θ₂ &= a₂ ⋅ \text{sand} + b₂ ⋅ \text{silt} + c₂ ⋅ \text{clay} +
            d₂ ⋅ \text{organic} + e₂ ⋅ \text{bulk} \\
    \text{PWP} &= θ₂ ⋅ \text{rootdepth}
\end{align}
```

Equation and coefficients are taken from [Gupta1979](@cite).
The coefficients a, b, c, d and e differ for the water holding
capacity (matrix potential Ψ = -0.07 bar) and
the permanent wilting point (matrix potential Ψ = -15 bar).
The empirical coefficients that were estimated by [Gupta1979](@cite)
can be seen in the folling table:

| Ψ [bar] | a        | b        | c        | d        | e       |
| ------- | -------- | -------- | -------- | -------- | ------- |
| -0.07   | 0.005678 | 0.009228 | 0.009135 | 0.006103 | -0.2696 |
| -15     | -5.9e-5  | 0.001142 | 0.005766 | 0.002228 | 0.02671 |

- `sand`: sand content [%]
- `silt`: silt content [%]
- `clay`: clay content [%]
- `bulk`: bulk density [g cm⁻³]
- `organic`: organic matter content [%]
- `rootdepth`: rooting depth [mm]
- `θ`: water content [cm³ cm⁻³]
- `WHC`: water holding capacity [mm]
- `PWP`: permanent wilting point [mm]
"""
function input_WHC_PWP!(; calc, input_obj)
    @unpack WHC, PWP = calc.u
    @unpack sand, silt, clay, organic, bulk, rootdepth, totalN, CNratio = input_obj.site

    @. WHC = (0.005678 * sand +
              0.009228 * silt +
              0.009135 * clay +
              0.006103 * organic -
              0.2696 * bulk) * rootdepth * u"mm"
    @. PWP = (-5.9e-5 * sand +
              0.001142 * silt +
              0.005766 * clay +
              0.002228 * organic +
              0.02671 * bulk) * rootdepth * u"mm"

    return nothing
end

"""
    initialization(; input_obj, inf_p, calc)

Initialize the simulation object.
"""
function initialization(; input_obj, inf_p, calc, trait_input = nothing)
    ################## Traits ##################
    if isnothing(trait_input)
        # generate random traits
        random_traits!(; calc, input_obj)
    else
        # use traits from input
        for key in keys(trait_input)
            calc.traits[key] .= trait_input[key]
        end
    end

    # distance matrix for below ground competition
    similarity_matrix!(; input_obj, calc)

    ################## Parameters ##################
    # leaf senescence rate μ [d⁻¹]
    senescence_rate!(; calc, inf_p)

    # palatability ρ [-]
    grazing_parameter!(; calc, inf_p)

    # linking traits to water and nutrient stress
    amc_nut_init!(; calc, inf_p)
    rsa_above_water_init!(; calc, inf_p)
    rsa_above_nut_init!(; calc, inf_p)
    sla_water_init!(; calc, inf_p)

    # WHC, PWP and nutrient index
    input_WHC_PWP!(; calc, input_obj)
    input_nutrients!(; calc, input_obj, inf_p)

    ################## Store everything in one object ##################
    p = (; p = inf_p)
    container = tuplejoin(p, input_obj, calc)

    ################## Initial conditions ##################
    set_initialconditions!(; container)

    return container
end

"""
    set_initialconditions!(; container)

Set the initial conditions for the state variables.

Each plant species (`u_biomass`) gets an equal share of
the initial biomass (`initbiomass`). The soil water content
(`u_water`) is set to 180 mm.

- `u_biomass`: state variable biomass [kg ha⁻¹]
- `u_water`: state variable soil water content [mm]
- `initbiomass`: initial biomass [kg ha⁻¹]
- `initsoilwater`: initial soil water content [mm]
"""
function set_initialconditions!(; container)
    @unpack u_biomass, u_water, grazed, mown = container.u
    @unpack initbiomass, initsoilwater = container.site
    @unpack nspecies = container.simp

    @. u_biomass = initbiomass / nspecies
    @. u_water = initsoilwater

    grazed .= 0.0u"kg / ha"
    mown .= 0.0u"kg / ha"

    return nothing
end

function cumulative_temperature(; temperature, year)
    temperature = ustrip.(temperature)
    temperature_sum = Float64[]

    for y in year
        year_filter = y .== year
        append!(temperature_sum, cumsum(temperature[year_filter]))
    end

    return temperature_sum * u"°C"
end
