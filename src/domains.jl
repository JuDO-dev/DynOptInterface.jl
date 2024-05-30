"""
    DomainIndex <: AbstractDynamicFunction

```math
t_i
```
A type-safe wrapper for `Int64` for use in referencing domains.
"""
struct DomainIndex <: AbstractDynamicFunction
    value::Int64
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

Add a domain to the model, returning a [`DomainIndex`](@ref). An
[`AddDomainNotAllowed`](@ref) is thrown if a domain cannot be added
to the `model` in its current state.
"""
add_domain(::MOI.ModelLike) = throw(AddDomainNotAllowed(""))

#=


# Parameters
@parameter(model, t_0)

# Design Variables
@variable(model, 1.0 ≤ t_f ≤ 2.0)

# Time Domains
@domain(model, t ∈ [0.0, t_f])
add_domain()::Tuple{DomainIndex, ConstraintIndex, ConstraintIndex}
# start(t) ∈ EqualTo
# final(t) ∈ Interval

# Algebraic Variables
@algebraic(model, u(t))
add_algebraic()::AlgebraicVariableIndex()

# Differential Variable
@differential(model, y(t))
add_differential()::DynamicVariableIndex()

=#