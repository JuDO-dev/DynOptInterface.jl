"""
    supports_domain(
        model::MOI.ModelLike,
        ::Type{<:AbstractDomain},
    )::Bool

Returns true if a domain type is supported and false ortherwise.
"""
function supports_domain(
    ::MOI.ModelLike,
    ::Type{<:AbstractDomain})
    return false
end

"""
    FixedDomain{T} <: AbstractDomain
        initial::T
        final::T
    end

A domain type with fixed initial and final limits.
"""
struct FixedDomain{T} <: AbstractDomain
    initial::T
    final::T
end