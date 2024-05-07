# Traits

```@example
import GrasslandTraitSim as sim
using PairPlots
using DataFrames

traits = sim.input_traits()
df = DataFrame(traits)

pairplot( 
    df => (
        PairPlots.Scatter(color = (:blue, 0.5), markersize = 7), 
        # PairPlots.Correlation(; digits = 2, position=PairPlots.Makie.Point2f(0.2, 1.0)),
        PairPlots.MarginDensity(),
        PairPlots.MarginHist(color = (:black, 0.2)),
        PairPlots.MarginConfidenceLimits()))
```