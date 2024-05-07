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
