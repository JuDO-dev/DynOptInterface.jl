## Types

"""
    struct DynamicVariableIndex <: AbstractDynamicFunction
        value::Int64
        t_i::PhaseIndex
    end

```math
t_i \\mapsto y_j(t_i)
```
An object used to refer to a dynamic variable, defined on phase `t_i`.
"""
struct DynamicVariableIndex <: AbstractDynamicFunction
    value::Int64
    t_i::PhaseIndex
end

function MOI.Utilities._to_string(::MOI.Utilities._PrintOptions, ::MOI.ModelLike,
    y_j::DynamicVariableIndex
)
    return string("y[", y_j.value, "]")
end

"""
    struct DynamicVariableDerivative <: AbstractDynamicFunction
        y_j::DynamicVariableIndex
    end

```math
t_i \\mapsto \\dot{y}_j(t_i)
```
An object used to refer to the derivative of the dynamic variable `y_j`.
"""
struct DynamicVariableDerivative <: AbstractDynamicFunction
    y_j::DynamicVariableIndex
end

function MOI.Utilities._to_string(::MOI.Utilities._PrintOptions, ::MOI.ModelLike,
    derivative::DynamicVariableDerivative,
)
    return string("ẏ[", derivative.y_j.value, "]")
end

"""
    AbstractDynamicVariableAttribute

Abstract supertype for attribute objects that can be used to set or get attributes
(properties) of dynamic variables in the model.
"""
abstract type AbstractDynamicVariableAttribute end

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

"""
    MOI.supports(
        model::MOI.ModelLike,
        attr::AbstractDynamicVariableAttribute,
        ::Type{DynamicVariableIndex},
    )

Return a `Bool` indicating whether `model` supports the dynamic variable attribute `attr`.
"""
function MOI.supports(
    ::MOI.ModelLike,
    ::AbstractDynamicVariableAttribute,
    ::Type{DynamicVariableIndex},
)
    return false
end

"""
    MOI.set(
        model::MOI.ModelLike,
        attr::AbstractDynamicVariableAttribute,
        y_j::DynamicVariableIndex,
        value,
    )

Assign `value` to the attribute `attr` of dynamic variable `y_j` in model `model`. A
[`MOI.UnsupportedAttribute`](@extref MathOptInterface.UnsupportedAttribute) error is thrown if `model` does not
support the attribute `attr`, and a [`MOI.SetAttributeNotAllowed`](@extref MathOptInterface.SetAttributeNotAllowed)
error is thrown if it supports the attribute `attr` but it cannot be set.
"""
function MOI.set(
    model::MOI.ModelLike,
    attr::AbstractDynamicVariableAttribute,
    ::DynamicVariableIndex,
    value
)
    if MOI.supports(model, attr)
        return throw(
            MOI.SetAttributeNotAllowed(
                attr,
                "$(model) does not support setting the "))
    else
        return throw(
            MOI.UnsupportedAttribute(
                attr,
                "$(typeof(model)) does not support the dynamic variable attribute $(attr).",
            )
        )
    end
end

"""
    MOI.get(model::MOI.ModelLike, attr::AbstractDynamicVariableAttribute, y_j::DynamicVariableIndex)

If the attribute `attr` is set for the dynamic variable `y_j`, return its value; return `nothing`
otherwise. If the attribute `attr` is not supported by `model`, an error is thrown.
"""
function MOI.get(model::MOI.ModelLike, attr::AbstractDynamicVariableAttribute, ::DynamicVariableIndex)
    return throw(
        MOI.GetAttributeNotAllowed(
            attr,
            "$(typeof(model)) does not support getting the attribute $(attr).",
        )
    )
end

## Attributes

"""
    DynamicVariableName <: AbstractDynamicVariableAttribute

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
as the [`MOI.VariablePrimal`](@extref MathOptInterface.VariablePrimal) attribute.
"""
struct DynamicVariablePrimal <: AbstractDynamicVariableAttribute
    result_index::Int
    DynamicVariablePrimal(result_index::Int=1) = new(result_index)
end