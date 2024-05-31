"""
    DomainIndex <: AbstractAlgebraicFunction

```math
t_i
```
A type-safe wrapper for `Int64` for use in referencing domains.
"""
struct DomainIndex <: AbstractAlgebraicFunction
    value::Int64
end

function MOI.Utilities._to_string(::MOI.Utilities._PrintOptions, ::MOI.ModelLike,
    t_i::DomainIndex
)
    return string("t[", t_i.value, "]")
end

"""
    supports_domain(model::MOI.ModelLike)

Return a `Bool` indicating whether `model` supports domains.
"""
supports_domain(::MOI.ModelLike) = false

"""
    UnsupportedDomain <: MOI.UnsupportedError

An error indicating that domains are not supported by the model, that is, 
that [`supports_domain`](@ref) returns `false`.
"""
struct UnsupportedDomain <: MOI.UnsupportedError
    message::String
end

"""
    AddDomainNotAllowed <: MOI.NotAllowedError

An error indicating that domains cannot be added to the model in its
current state.
"""
struct AddDomainNotAllowed <: MOI.NotAllowedError
    message::String
end

MOI.operation_name(::AddDomainNotAllowed) = "Adding a domain"

"""
    add_domain(model::MOI.ModelLike)

Add a domain to `model`, returning a [`DomainIndex`](@ref). An
[`AddDomainNotAllowed`](@ref) is thrown if a domain cannot be added
to the `model` in its current state.
"""
add_domain(::MOI.ModelLike) = throw(AddDomainNotAllowed(""))