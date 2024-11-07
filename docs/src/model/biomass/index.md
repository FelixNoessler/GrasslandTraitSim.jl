# Plant biomass dynamics

Click on a process to view detailed documentation:

```mermaid
flowchart LR
    A[Growth Gact] --> B[Change in biomass during one time step]
    C[Senescence S] --> B
    D[Mowing and grazing M] --> B

click C "senescence" "Go"
click A "growth" "Go"
click D "mowing_grazing" "Go"
```

The change in the biomass ``B`` from day ``t`` to ``t+1`` of species ``s`` in patch ``x,y`` [kg ha⁻¹] is calculated based on the actual growth ``G_{act, txys}`` [kg ha⁻¹], and the losses by senescence ``S_{txys}`` [kg ha⁻¹] and management ``M_{txys}`` [kg ha⁻¹]: 
```math
B_{t+1xys} = B_{txys} + G_{act, txys} - S_{txys} - M_{txys}
```

The change in the total biomass ``B_{txys}`` is divided into the change in above-ground ``B_{A,txys}`` [kg ha⁻¹] and below-ground biomass ``B_{txys}`` [kg ha⁻¹]. We assume that plants aim to achieve a similar level of above-ground biomass per total biomass similar to the time-invariant trait above-ground biomass per total biomass ``abp_s`` [-]. We therefore calculate ``A_{txys}`` [-] the ratio between the actual biomass ratio and the trait ``abp_s``:
```math
A_{txys} = \frac{\left(\frac{B_{A,txys}}{B_{txys}}\right)}{abp_s}
```

``A_{txys}`` is less than one if the above-ground biomass per total biomass is less than expected by the trait ``abp_s``, for example after a mowing event. This variable can be used to allocate biomass changes by growth and senescence to above-ground and below-ground biomass. Biomass loss by mowing and grazing affects only the above-ground biomass:
```math
\begin{align}
    B_{A, t+1xys} &= B_{A, txys} + A_{txys} \cdot G_{act, txys} -  (1 - A_{txys}) \cdot S_{txys} - M_{txys} \\
    B_{B, t+1xys} &= B_{B, txys} + (1 - A_{txys}) \cdot G_{act, txys} - A_{txys} \cdot S_{txys} 
\end{align}
```