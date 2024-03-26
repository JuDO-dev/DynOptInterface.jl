"""
    AbstractDomain

Abstract supertype for domains.
"""
abstract type AbstractDomain end

"""
    DomainIndex{D}

A type-safe wrapper for `Int64` for use in referencing domains.
The parameter `D` is the type of the domain.
"""
struct DomainIndex{D}
    value::Int64
end

"""
    supports_domain(
        model::ModelLike,
        ::Type{D},
    ) where {D<:AbstractDomain}

Return a `Bool` indicating whether `model` supports domains of type `D`.
"""
function supports_domain(::Model, ::Type{<:AbstractDomain})
    return false
end

"""
    struct UnsupportedDomain{D<:AbstractDomain} <: MOI.UnsupportedError
        message::String
    end

An error indicating that domains of type `D` are not supported by the model,
that is, that [`supports_domain`](@ref) returns `false`.
"""
struct UnsupportedDomain{D<:AbstractDomain} <: MOI.UnsupportedError
    message::String
end

"""
    struct AddDomainNotAllowed{D<:AbstractDomain} <: MOI.NotAllowedError
        message::String
    end

An error indicating that domains of type `D` are supported but cannot be added 
to the current state of the model.
"""
struct AddDomainNotAllowed{D<:AbstractDomain} <: MOI.NotAllowedError
    message::String
end
AddDomainNotAllowed{D}() where {D} = AddDomainNotAllowed{D}("")

"""
    add_domain()

Add `domain` to the model. An [`UnsupportedDomain`](@ref) error is thrown if 
`model` does not support 
"""
function add_domain(model::MOI.ModelLike, domain::AbstractDomain)
    return throw_add_domain_error_fallback(model, domain)
end

function throw_add_domain_error_fallback(
    model::MOI.ModelLike,
    domain::AbstractDomain;
    error_if_supported = AddDomainNotAllowed{typeof(domain)}(),
)
    if supports_domain(model, typeof(domain))
        throw(error_if_supported)
    else
        throw(UnsupportedConstraint{typeof(domain)}())
    end
end

"""
    struct Interval{T0, TF} <: AbstractDomain
        t_0::T0
        t_f::TF
    end

A one-dimensional domain where `t_0` and `t_f` may be real numbers or variable indices.  
"""
struct Interval{T0, TF} <: AbstractDomain
    t_0::T0
    t_f::TF
end