"""
    DynamicVariableIndex <: AbstractDynamicFunction

```math
t_i \\mapsto y_j(t_i)
```
A type-safe wrapper for `Int64` for use in referencing dynamic variables.
"""
struct DynamicVariableIndex <: AbstractAlgebraicFunction
    value::Int64
    domain::DomainIndex
end

"""
    supports_dynamic_variable(model::MOI.ModelLike)

Return a `Bool` indicating whether `model` supports dynamic variables.
"""
supports_dynamic_variable(::MOI.ModelLike) = false

"""
    UnsupportedDynamicVariable <: MOI.UnsupportedError

An error indicating that dynamic variables are not supported by the model, that is, 
that [`supports_dynamic_variable`](@ref) returns `false`.
"""
struct UnsupportedDynamicVariable <: MOI.UnsupportedError
    message::String
end

"""
    AddDynamicVariableNotAllowed <: MOI.NotAllowedError

An error indicating that dynamic variables cannot be added to the model
in its current state.
"""
struct AddDynamicVariableNotAllowed <: MOI.NotAllowedError
    message::String
end

MOI.operation_name(::AddDynamicVariableNotAllowed) = "Adding a dynamic variable"

"""
    add_dynamic_variable(::MOI.ModelLike)

Add
"""
add_dynamic_variable(::MOI.ModelLike) = throw(AddDynamicVariableNotAllowed(""))