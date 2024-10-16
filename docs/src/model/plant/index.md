# Plant dynamics

Click on a process to view detailed documentation:

```mermaid
flowchart LR
    A[Growth] --> B[Change in biomass and height in one day]
    C[Senescence] --> B
    D[Mowing and grazing] --> B
    B --update--> K[States: biomass & height ]

click C "senescence" "Go"
click A "growth" "Go"
click D "mowing_grazing" "Go"
```
