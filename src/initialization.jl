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

"""
    derive_WHC_PWP_nutrients!(; calc, input_obj)

Derive water holding capacity (WHC), permanent wilting point (PWP) and nutrients
for all patches.

This function calls the functions [`input_WHC_PWP`](@ref) and [`input_nutrients!`](@ref).

A gradient of nutrients within the site can be added by setting `nutheterog` to a
value larger than zero. The gradient is created with [`planar_gradient!`](@ref).
"""
function derive_WHC_PWP_nutrients!(; calc, input_obj)
    @unpack patch_xdim, patch_ydim, nutheterog, = input_obj.simp
    @unpack sand, silt, clay, organic, bulk, rootdepth, totalN, CNratio = input_obj.site
    @unpack nutgradient = calc.calc

    if isone(patch_xdim) && isone(patch_ydim)
        nutgradient .= 0.5
    else
        planar_gradient!(; mat = nutgradient)
    end

    WHC, PWP = input_WHC_PWP(; sand, silt, clay, organic, bulk, rootdepth)
    input_nutrients!(; calc, input_obj, nutheterog, totalN, CNratio)

    calc.patch.WHC .= WHC * u"mm"
    calc.patch.PWP .= PWP * u"mm"

    return nothing
end

@doc raw"""
    input_nutrients(; gradientm, total_N, CN_ratio)

Derive a nutrient index by combining total nitrogen and carbon to nitrogen ratio.

```math
    N = \frac{1}{1 + exp(-β₁ ⋅ \text{total_N} -β₂ ⋅ \text{CN_ratio}⁻¹)}
```

- `CNratio`: carbon to nitrogen ratio [-]
- `totalN`: total nitrogen [g kg⁻¹]
"""
function input_nutrients!(; calc, input_obj, nutheterog, totalN, CNratio)
    @unpack patch_xdim, patch_ydim = input_obj.simp
    @unpack nutgradient = calc.calc
    @unpack nutrients = calc.patch

    #### data from the biodiversity exploratories
    # mintotal_N = 1.2525
    # maxtotal_N = 30.63
    # minCN_ratio = 9.0525
    # maxCN_ratio = 13.6025

    mintotal_N = 0.0
    maxtotal_N = 50.0
    minCN_ratio = 5.0
    maxCN_ratio = 25.0

    β₁ = β₂ = 0.1
    β₃ = 10.0 * nutheterog

    N = (totalN - mintotal_N) / (maxtotal_N - mintotal_N)
    CN = (CNratio - minCN_ratio) / (maxCN_ratio - minCN_ratio)

    for x in Base.OneTo(patch_xdim)
        for y in Base.OneTo(patch_ydim)
            nutrients[get_patchindex(x, y; patch_xdim)] = 1 /
                                                          (1 + exp(-β₁ * N - β₂ * 1 / CN -
                                                               β₃ *
                                                               (nutgradient[x, y] - 0.5)))
        end
    end

    return nothing
end

@doc raw"""
    input_WHC_PWP(; sand, silt, clay, organic, bulk, rootdepth)

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
function input_WHC_PWP(; sand, silt, clay, organic, bulk, rootdepth)
    θ₁ = 0.005678 * sand + 0.009228 * silt + 0.009135 * clay +
         0.006103 * organic - 0.2696 * bulk
    WHC = θ₁ * rootdepth

    θ₂ = -5.9e-5 * sand + 0.001142 * silt + 0.005766 * clay +
         0.002228 * organic + 0.02671 * bulk
    PWP = θ₂ * rootdepth

    return WHC, PWP
end

"""
    initialization(; input_obj, inf_p, calc)

Initialize the simulation object.
"""
function initialization(; input_obj, inf_p, calc)
    ################## Traits ##################
    # generate random traits
    Traits.random_traits!(; calc, input_obj)

    # distance matrix for below ground competition
    Traits.similarity_matrix!(; input_obj, calc)

    ################## Parameters ##################
    # leaf senescence rate μ [d⁻¹]
    Growth.senescence_rate!(; calc, inf_p)

    # palatability ρ [-]
    Growth.grazing_parameter!(; calc, inf_p)

    # functional response
    amc_nut_lower = FunctionalResponse.amc_nut_response(; calc, inf_p)
    rsa_above_water_lower = FunctionalResponse.rsa_above_water_response!(; calc, inf_p)
    rsa_above_nut_lower = FunctionalResponse.rsa_above_nut_response!(; calc, inf_p)
    sla_water_lower = FunctionalResponse.sla_water_response!(; calc, inf_p)

    # WHC, PWP and nutrient index
    derive_WHC_PWP_nutrients!(; calc, input_obj)

    ################## Patch neighbours ##################
    set_neighbours_surroundings!(; calc, input_obj)

    ################## Store everything in one object ##################
    p = (;
        p = (; inf_p...,
            amc_nut_lower,
            rsa_above_water_lower,
            rsa_above_nut_lower,
            sla_water_lower))
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
"""
function set_initialconditions!(; container)
    @unpack u_biomass, u_water = container.u
    @unpack initbiomass = container.site
    @unpack nspecies = container.simp

    u_biomass .= initbiomass / nspecies
    u_water .= 180.0u"mm"
end
