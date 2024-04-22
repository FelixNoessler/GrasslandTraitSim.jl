# Likelihood calculation for the Biodiversity Exploratories data set

We can compute the probability of observing the data ``x``, given the simulation of the model with the parameters ``\theta``, by calculating the likelihood function ``\mathcal{L}(\theta \mid x)``.

## Soil water content

In the Biodiversity Exploratories, data of the soil moisture ``SM_m`` is in ``\%`` available. The model simulates the soil water content ``SWC_{sim}`` in ``mm``. We first transform the measured soil moisture ``SM_{m}`` to a soil water content ``SWC_{m}``. Afterwards, we calculate the likelihood of observing the measured soil water content ``SWC_{m}`` given the simulated soil water content ``SWC_{sim}``.

```math
\begin{align}
    SWC_{m} &= \text{moistureconv_alpha} + \text{moistureconv_beta} \cdot \text{rootdepth} \cdot SM_{m} \\
    SWC_{m} &\sim \text{truncated}(\text{Laplace}(\mu = SWC_{sim}, b = \text{b_soilmoisture}); \text{ lower}=0)
\end{align}
```

## Biomass

We calculate the likelihood of observing the measured biomass ``B_{m}`` given the simulated biomass ``B_{sim}`` (both in ``\frac{kg}{ha}``): 

```math
    B_{m} \sim \text{truncated}(\text{Laplace}(\mu = B_{sim}, b = \text{b_biomass}); \text{ lower}=0)
```

## Community weighted mean traits

We can calculate community weighted mean traits from the observed community composition by weighting species mean trait values by their cover. In the same way, we can calculate community weighted mean traits for our simulated plant community. Then, we can calculate the likelihood of observing the measured community weighted mean trait ``CWM_{m}`` (e.g. ``sla_m``) given the simulated community weighted mean trait ``CWM_{sim}`` (e.g. ``sla_{sim}``):

```math
    CWM_{m} \sim \text{truncated}(\text{Laplace}(\mu = CWM_{sim}, b = b\_cwm); \text{ lower}=0)
```

This can be done for all five traits that were part of the simulation model. All the traits have an own variance parameter (e.g. ``b\_sla``).


## Downweighting the likelihood

In the calibration of the simulation model we want to give each part (biomass, soil water content, community weighted mean traits) an equal influence.

Measured soil moisture content is available with a daily resolution. The other data is available with a yearly resolution. Therefore, we downweight the likelihood of the soil moisture content by number of measurements per year ``n_{SM}``.

Moreover, we downweight the likelihood of the community weighted mean traits by the number of traits ``n_{traits}``.

In this process, we emulate a scenario where each of the three calibration aspects (biomass, soil water content, and community weighted mean traits) is measured only once per year.

```math
    \text{log } \mathcal{L}(\theta \mid x) = \text{log }\mathcal{L}_{B}(\theta \mid x) + \frac{1}{n_{SM}} \cdot \text{log }\mathcal{L}_{SWC}(\theta \mid x) + \frac{1}{n_{traits}}\cdot \text{log }\mathcal{L}_{CWM}(\theta \mid x)
```