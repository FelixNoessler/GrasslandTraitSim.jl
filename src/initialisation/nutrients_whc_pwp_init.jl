@doc raw"""
Derive a nutrient index by combining total nitrogen and carbon to nitrogen ratio.

```math
\begin{align*}
\text{CN_scaled} &= \frac{\text{CNratio} - \text{minCNratio}}
                    {\text{maxCNratio} - \text{minCN_ratio}} \\
\text{totalN_scaled} &= \frac{\text{totalN} - \text{mintotalN}}
                        {\text{N_max} - \text{mintotalN}} \\
\text{nutrients} &= \frac{1}{1 + exp(-\text{totalN_β} ⋅ \text{totalN_scaled}
                                     -\text{CN_β} ⋅ \text{CN_scaled}⁻¹)}
\end{align*}
```

- `CNratio`: carbon to nitrogen ratio [-]
- `totalN`: total nitrogen [g kg⁻¹]
- `minCNratio`: minimum carbon to nitrogen ratio [-]
- `maxCNratio`: maximum carbon to nitrogen ratio [-]
- `mintotalN`: minimum total nitrogen [g kg⁻¹]
- `N_max`: maximum total nitrogen [g kg⁻¹]
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
"""
function input_nutrients!(; prealloc, input_obj, p)
    @unpack nutrients = prealloc.patch_variables
    @unpack totalN = input_obj.site
    @unpack included = input_obj.simp

    #### data from the biodiversity exploratories
    # mintotalN = 1.2525
    # N_max = 30.63

    if !haskey(included, :nutrient_growth_reduction) || included.nutrient_growth_reduction
        @. nutrients = totalN / p.N_max
    end

    return nothing
end

@doc raw"""
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
function input_WHC_PWP!(; prealloc, input_obj)
    @unpack WHC, PWP = prealloc.patch_variables
    @unpack sand, silt, clay, organic, bulk, rootdepth = input_obj.site

    @. WHC = (0.5678 * sand +
        0.9228 * silt +
        0.9135 * clay +
        0.6103 * organic -
        0.2696u"cm^3/g" * bulk) * rootdepth
    @. PWP = (-0.0059 * sand +
        0.1142 * silt +
        0.5766 * clay +
        0.2228 * organic +
        0.02671u"cm^3/g" * bulk) * rootdepth

    return nothing
end
