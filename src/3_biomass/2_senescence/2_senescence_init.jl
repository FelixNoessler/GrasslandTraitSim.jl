"""
Intialize the basic senescence rate based on the specific leaf area
"""
function senescence_rate!(; input_obj, prealloc, p)
    @unpack included = input_obj.simp
    @unpack sla = prealloc.traits
    @unpack μ, leaflifespan =  prealloc.calc

    if !included.senescence
        @. μ = 0.0
        @. leaflifespan = 0.0u"d"
        return nothing
    end

    @unpack α_ll, β_ll, α_sen, β_sen = p
    @. leaflifespan = 10^((α_ll - log10(sla * 10000u"g/m^2")) / β_ll) *
    365.25 / 12 * u"d"
    @. μ = α_sen + β_sen / leaflifespan

    return nothing
end

function plot_leaflifespan(; θ = nothing, path = nothing)
    nspecies, container = create_container_for_plotting(; θ)

    fig = Figure(; size = (700, 400))
    ax = Axis(fig[1, 1];
        xlabel = "Specific leaf area [m² g⁻¹]",
        ylabel = "Leaf lifespan [d]")
    scatter!(ustrip.(container.traits.sla), ustrip.(container.calc.leaflifespan);
             color = (:black, 0.7))

    if !isnothing(path)
        save(path, fig;)
    else
        display(fig)
    end

    return nothing
end
