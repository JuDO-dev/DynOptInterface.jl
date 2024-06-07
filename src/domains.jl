## Type

"""
    DomainIndex <: AbstractAlgebraicFunction

```math
t_i \\in [t_i^0, t_i^f]
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

## Attributes

"""
    DomainName <: AbstractDomainAttribute

A domain attribute for a `String` identifying a [`DomainIndex`](@ref).
If not set, it has a default value of `""`.
"""
struct DomainName <: AbstractDomainAttribute end

MOI.attribute_value_type(::DomainName) = String

"""
    DomainInitialPrimalStart <: AbstractDomainAttribute

A domain attribute for setting a starting value for ``t_i^0``, which may
help warm-start the optimizer. It is either a number or a `nothing` (unset).
"""
struct DomainInitialPrimalStart <: AbstractDomainAttribute end

"""
    DomainFinalPrimalStart <: AbstractDomainAttribute

A domain attribute for setting a starting value for ``t_i^f``, which may
help warm-start the optimizer. It is either a number or a `nothing` (unset).
"""
struct DomainFinalPrimalStart <: AbstractDomainAttribute end

"""
    DomainInitialPrimal <: AbstractDomainAttribute

A domain attribute for setting or getting ``t_i^0``. It should have the
same behaviour as the [`MathOptInterface.VariablePrimal`](@extref) attribute.
"""
struct DomainInitialPrimal <: AbstractDomainAttribute
    result_index::Int
    DomainInitialPrimal(result_index::Int=1) = new(result_index)
end

"""
    DomainFinalPrimal <: AbstractDomainAttribute

A domain attribute for setting or getting ``t_i^f``. It should have the
same behaviour as the [`MathOptInterface.VariablePrimal`](@extref) attribute.
"""
struct DomainFinalPrimal <: AbstractDomainAttribute
    result_index::Int
    DomainFinalPrimal(result_index::Int=1) = new(result_index)
end

## Functions and Errors
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