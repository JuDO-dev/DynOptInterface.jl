## Type

"""
    DynamicVariableIndex <: AbstractDynamicFunction

```math
t_i \\mapsto y_j(t_i)
```
A type-safe wrapper for `Int64` for use in referencing dynamic variables.
"""
struct DynamicVariableIndex <: AbstractAlgebraicFunction
    value::Int64
    t_i::DomainIndex
end

function MOI.Utilities._to_string(::MOI.Utilities._PrintOptions, ::MOI.ModelLike,
    y_j::DynamicVariableIndex
)
    return string("y[", y_j.value, "]")
end

# Errors

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

## Functions

"""
    supports_dynamic_variable(model::MOI.ModelLike)

Return a `Bool` indicating whether `model` supports dynamic variables.
"""
supports_dynamic_variable(::MOI.ModelLike) = false



"""
    add_dynamic_variable(model::MOI.ModelLike)

Add a dynamic variable to `model`, returning a [`DynamicVariableIndex`](@ref). An 
[`AddDynamicVariableNotAllowed`](@ref) is thrown if a dynamic variable cannot be added
to `model` in its current state.
"""
add_dynamic_variable(::MOI.ModelLike) = throw(AddDynamicVariableNotAllowed(""))

## Attributes

"""
    DynamicVariableName <: AbstractDomainAttribute

A dynamic variable attribute for a `String` identifying a
[`DynamicVariableIndex`](@ref). If not set, it has a default value of `""`.
"""
struct DynamicVariableName <: AbstractDynamicVariableAttribute end

MOI.attribute_value_type(::DynamicVariableName) = String

"""
    DynamicVariablePrimalStart <: AbstractDynamicVariableAttribute

A dynamic variable attribute for setting a starting function for ``y_j(t_i)``,
which may help warm-start the optimizer. It is either a `nothing` (unset)
or a single-argument function of `T<:Real`.
"""
struct DynamicVariablePrimalStart <: AbstractDynamicVariableAttribute end

"""
    DynamicVariablePrimal <: AbstractDynamicVariableAttribute

A dynamic variable attribute for setting or getting ``y_j(t_i)``. It should
be a single-argument function of `T<:Real`. It should have the same behaviour
as the [`MathOptInterface.VariablePrimal`](@extref) attribute.
"""
struct DynamicVariablePrimal <: AbstractDynamicVariableAttribute
    result_index::Int
    DynamicVariablePrimal(result_index::Int=1) = new(result_index)
end