@doc raw"""
    below_ground_competition!(; container, biomass)

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
\begin{align}
\text{biomass_density_factor} &=
    \left(\frac{TS \cdot B}{\text{biomass_dens}}\right) ^
    {- \text{belowground_density_effect}} \\
\text{biomass_density_factor} &=
    \left(\frac{TS \cdot B}{\text{biomass_dens}}\right) ^
    {- \text{belowground_density_effect}} \\
\end{align}
```

The reduction factors control the density and increases the "functional dispersion"
of the root surface area per aboveground biomass and the arbuscular
mycorrhizal colonisation.

The `TS` matrix is computed before the start of the simulation
([calculation of traits similarity](@ref "Initialization of traits"))
and includes the traits arbuscular mycorrhizal colonisation rate (`amc`)
and the root surface area devided by the above ground biomass (`rsa_above`).

- `biomass_density_factor` is the factor that adjusts the plant available nutrients and soil water [-]
- `TS` is the trait similarity matrix, $TS \in [0,1]^{N \times N}$ [-]
- `B` is the biomass vector, $B \in [0, ∞]^{N}$ [kg ha⁻¹]
- `belowground_density_effect` is the exponent of the below ground
    competition factor [-]

![](../img/below_influence.svg)
"""
function below_ground_competition!(; container, biomass)
    @unpack biomass_density_factor, TS_biomass = container.calc
    @unpack below_included = container.simp.included
    @unpack belowground_density_effect, biomass_dens = container.p
    @unpack TS = container.traits

    if !below_included
        @info "No below ground competition for resources!" maxlog=1
        @. biomass_density_factor = 1.0
        return nothing
    end

    LinearAlgebra.mul!(TS_biomass, TS, biomass)
    biomass_density_factor .= (TS_biomass ./ (biomass_dens * u"kg / ha")) .^
                              -belowground_density_effect

    return nothing
end
