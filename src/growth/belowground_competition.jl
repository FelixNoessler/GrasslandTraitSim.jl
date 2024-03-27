@doc raw"""
Models the below-ground competiton between plants.

Plant available nutrients and water are reduced if a large biomass of plant
species with similar root surface area per above ground biomass (`rsa_above`)
and arbuscular mycorrhizal colonisation (`amc`) is already present.

We define for $N$ species the trait similarity matrix $TS \in [0,1]^{N \times N}$ with
trait similarities between the species $i$ and $j$ ($ts_{i,j}$),
where $ts_{i,j} = ts_{j,i}$ and $ts_{i,i} = 1$:
```math
TS =
\begin{bmatrix}
    ts_{1,1} & ts_{1,2} & \dots &  & ts_{1,N} \\
    ts_{2,1} & ts_{2,2} &  & \\
    \vdots &  & \ddots &  & \\
    ts_{N,1} & & & & ts_{N,N} \\
\end{bmatrix}
= \begin{bmatrix}
    1 & ts_{1,2} & \dots &  & ts_{1,N} \\
    ts_{2,1} & 1 &  & \\
    \vdots &  & \ddots &  & \\
    ts_{N,1} & & & & 1 \\
\end{bmatrix}
```

and the biomass vector $B \in [0\,\text{kg ha⁻¹}, ∞\,\text{kg ha⁻¹}]^N$ with the biomass
of each plant species $b$:
```math
B =
\begin{bmatrix}
    b_1 \\
    b_2 \\
    \vdots \\
    b_N \\
\end{bmatrix}
```

Then, we multiply the trait similarity matrix $TS$ with the biomass vector $B$:
```math
TS \cdot B =
\begin{bmatrix}
    1 & ts_{1,2} & \dots &  & ts_{1,N} \\
    ts_{2,1} & 1 &  & \\
    \vdots &  & \ddots &  & \\
    ts_{N,1} & & & & 1 \\
\end{bmatrix} \cdot
\begin{bmatrix}
    b_1 \\
    b_2 \\
    \vdots \\
    b_N \\
\end{bmatrix} =
\begin{bmatrix}
    1 \cdot b_1 + ts_{1,2} \cdot b_2 + \dots + ts_{1,N} \cdot b_N \\
    ts_{2,1} \cdot b_1 + 1 \cdot b_2 + \dots + ts_{2,N} \cdot b_N \\
    \vdots \\
    ts_{N,1} \cdot b_1 + ts_{N,2} \cdot b_2 + \dots + 1 \cdot b_N \\
\end{bmatrix}
```

The factors are then calculated as follows:
```math
\text{biomass_density_factor} =
    \left(\frac{TS \cdot B}{\text{α_TSB}}\right) ^
    {- \text{β_TSB}} \\
```

The reduction factors control the density and increases the "functional dispersion"
of the root surface area per aboveground biomass and the arbuscular
mycorrhizal colonisation.

The `TS` matrix is computed before the start of the simulation
([calculation of trait similarity](@ref similarity_matrix!))
and includes the traits arbuscular mycorrhizal colonisation rate (`amc`)
and the root surface area devided by the above ground biomass (`rsa_above`).

- `biomass_density_factor` is the factor that adjusts the
  plant available nutrients and soil water [-]
- `TS` is the trait similarity matrix, $TS \in [0,1]^{N \times N}$ [-]
- `B` is the biomass vector, $B \in [0, ∞]^{N}$ [kg ha⁻¹]
- `β_TSB` is the exponent of the below ground
  competition factor [-]

![](../img/below_influence.svg)
"""
function below_ground_competition!(; container, biomass)
    @unpack biomass_density_factor, TS_biomass, TS = container.calc
    @unpack included = container.simp

    if !included.belowground_competition
        @info "No below ground competition for resources!" maxlog=1
        @. biomass_density_factor = 1.0
        return nothing
    end

    @unpack β_TSB, α_TSB = container.p
    LinearAlgebra.mul!(TS_biomass, TS, biomass)


    ## biomass density factor should be between 0.33 and 3.0
    for i in eachindex(biomass_density_factor)
        biomass_factor = (TS_biomass[i] / α_TSB) ^ -β_TSB

        if biomass_factor > 3.0
            biomass_factor = 3.0
        elseif biomass_factor < 0.33
            biomass_factor = 0.33
        end

        biomass_density_factor[i] = biomass_factor
    end

    return nothing
end


@doc raw"""
Reduction of growth based on the plant available water
and the traits specific leaf area and root surface area
per aboveground biomass.


Derives the plant available water.

The plant availabe water is dependent on the soil water content,
the water holding capacity (`WHC`), the permanent
wilting point (`PWP`), the potential evaporation (`PET`) and a
belowground competition factor:

```math
\begin{align*}
    W_{sc, txy} &= \frac{W_{txy} - PWP_{xy}}{WHC_{xy}-PWP_{xy}} \\
    W_{p, txys} &= D_{txys} \cdot 1 \bigg/ \left(1 + \frac{\text{exp}\left(\beta_{pet} \cdot \left(PET_{txy} - \alpha_{pet} \right) \right)}{ 1 / (1-W_{sc, txy}) - 1}\right)
\end{align*}
```

- ``W_{sc, txy}`` is the scaled soil water content ``\in [0, 1]`` [-]
- ``W_{txy}`` is the soil water content [mm]
- ``PWP_{xy}`` is the permanent wilting point [mm]
- ``WHC_{xy}`` is the water holding capacity [mm]
- ``W_{p, txys}`` is the plant available water [-]
- ``D_{txys}`` is the belowground competition factor [-], in the programming code
  is is called `biomass_density_factor`
- ``PET_{txy}`` is the potential evapotranspiration [mm]
- ``β_{pet}`` is a parameter that defines the steepness of the reduction function
- ``α_{pet}`` is a parameter that defines the midpoint of the reduction function

![](../img/pet.svg)

Derive the water stress based on the specific leaf area and the
plant availabe water.

It is assumed, that plants with a higher specific leaf area have a higher
transpiration per biomass and are therefore more sensitive to water stress.
A transfer function is used to link the specific leaf area to the water
stress reduction.

**Initialization:**

The specicies-specifc parameter `H_sla` is initialized
and later used in the reduction function.

```math
\text{H_sla} = \text{min_sla_mid} +
    \frac{\text{max_sla_mid} - \text{min_sla_mid}}
    {1 + exp(-\text{β_sla_mid} \cdot (sla - \text{mid_sla}))}
```

- `sla` is the specific leaf area of the species [m² g⁻¹]
- `min_sla_mid` is the minimum of `H_sla` that
  can be reached with a very low specific leaf area [-]
- `max_sla_mid` is the maximum of `H_sla` that
  can be reached with a very high specific leaf area [-]
- `mid_sla` is a mean specific leaf area [m² g⁻¹]
- `β_sla_mid` is a parameter that defines the steepness
  of function that relate the `sla` to `H_sla`


**Reduction factor based on the plant availabe water:**
```math
\text{W_sla} = 1 - \text{δ_sla} +
    \frac{\text{δ_sla}}
    {1 + exp(-\text{k_sla} \cdot
        (\text{Wp} - \text{H_sla}))}
```

- `W_sla` is the reduction factor for the growth based on the
  specific leaf area [-]
- `H_sla` is the value of the plant available water
  at which the reduction factor is in the middle between
  1 - `δ_sla` and 1 [-]
- `δ_sla` is the maximal reduction of the
  growth based on the specific leaf area
- `Wp` is the plant available water [-]
- `k_sla` is a parameter that defines the steepness of the reduction function

**Overview over the parameters:**

| Parameter                 | Type                      | Value          |
| ------------------------- | ------------------------- | -------------- |
| `min_sla_mid`             | fixed                     | -0.8 [-]       |
| `max_sla_mid`             | fixed                     | 0.8  [-]       |
| `mid_sla`                 | fixed                     | 0.025 [m² g⁻¹] |
| `β_sla_mid`               | fixed                     | 75 [g m⁻²]     |
| `k_sla`                   | fixed                     | 5 [-]          |
| `δ_sla` | calibrated                | -              |
| `H_sla`      | species-specific, derived | -              |

**Influence of the `δ_sla`:**

`δ_sla` equals 1:
![](../img/W_sla_response.svg)

`δ_sla` equals 0.5:
![](../img/W_sla_response_0_5.svg)


Reduction of growth due to stronger water stress for lower specific
root surface area per above ground biomass (`rsa_above`).

- the strength of the reduction is modified by the parameter `δ_wrsa`

`δ_wrsa` equals 1:
![Graphical overview of the functional response](../img/W_rsa_response.svg)

`δ_wrsa` equals 0.5:
# ![Graphical overview of the functional response](../img/W_rsa_response_0_5.svg)
"""
function water_reduction!(; container, W, PET, PWP, WHC)
    @unpack included = container.simp
    @unpack Waterred = container.calc
    if !included.water_growth_reduction
        @info "No water reduction!" maxlog=1
        @. Waterred = 1.0
        return nothing
    end

    Wsc = W > WHC ? 1.0 : W > PWP ? (W - PWP) / (WHC - PWP) : 0.0

    pet_adjustment = 1.0
    if included.pet_growth_reduction
        @unpack α_PET, β_PET = container.p
        pet_adjustment = exp(-β_PET * (PET - α_PET))
    end

    @unpack W_sla, W_rsa, Wp, biomass_density_factor = container.calc
    @unpack δ_sla, δ_wrsa, β_sla, β_rsa = container.p
    @unpack K_wrsa, H_rsa, H_sla = container.transfer_function

    @. Wp = min(biomass_density_factor * Wsc * pet_adjustment, 3.0)
    @. W_sla = 1 - δ_sla + δ_sla / (1 + exp(-β_sla * (Wp - H_sla)))
    @. W_rsa = 1 - δ_wrsa + (K_wrsa + δ_wrsa - 1) / (1 + exp(-β_rsa * (Wp - H_rsa)))
    @. Waterred = W_sla * W_rsa

    return nothing
end



"""
Reduction of growth based on plant available nutrients and
the traits arbuscular mycorrhizal colonisation and
root surface area / aboveground biomass.

Reduction of growth due to stronger nutrient stress for lower
arbuscular mycorrhizal colonisation (`AMC`).

- the strength of the reduction is modified by the parameter `δ_amc`

`δ_amc` equals 1:
![Graphical overview of the AMC functional response](../img/amc_nut_response.svg)

`δ_amc` equals 0.5:
![Graphical overview of the AMC functional response](../img/amc_nut_response_0_5.svg)

Reduction of growth due to stronger nutrient stress for lower specific
root surface area per above ground biomass (`rsa_above`).

- the strength of the reduction is modified by the parameter `δ_nrsa`

`δ_nrsa` equals 1:
![Graphical overview of the functional response](../img/rsa_above_nut_response.svg)

`δ_nrsa` equals 0.5:
![Graphical overview of the functional response](../img/rsa_above_nut_response_0_5.svg)
"""
function nutrient_reduction!(; container, nutrients)
    @unpack included = container.simp
    @unpack Nutred = container.calc

    if !included.nutrient_growth_reduction
        @info "No nutrient reduction!" maxlog=1
        @. Nutred = 1.0
        return nothing
    end

    @unpack K_amc, H_amc, K_nrsa, H_rsa = container.transfer_function
    @unpack δ_amc, δ_nrsa, β_amc, β_rsa = container.p
    @unpack nutrients_splitted, biomass_density_factor,
            amc_nut, nutrients_splitted, rsa_above_nut,
            nutrients_splitted = container.calc

    @. nutrients_splitted = nutrients * biomass_density_factor
    @. amc_nut = 1 - δ_amc + (K_amc + δ_amc - 1) /
                 (1 + exp(-β_amc * (nutrients_splitted - H_amc)))
    @. rsa_above_nut = 1 - δ_nrsa + (K_nrsa + δ_nrsa - 1) /
                       (1 + exp(-β_rsa * (nutrients_splitted - H_rsa)))
    @. Nutred = max(amc_nut, rsa_above_nut)

    return nothing
end
