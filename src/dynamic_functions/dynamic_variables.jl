"""
    DynamicVariableIndex(value::Int64, phase::DynamicVariableIndex)

An object for use in referencing dynamic variables in a model.

It is a sub-type of [`AbstractDynamicFunction`](@ref). It represents a
dynamic variable ``t_i \\mapsto y_j(t_i)`` defined in the domain
``[t_i^0, t_i^f]``. The `Int64` index value is stored in the `value` field.
To allow for deletion, indices need not be consecutive.
"""
struct DynamicVariableIndex <: AbstractDynamicFunction
    value::Int64
    phase::PhaseIndex
end

function MOI.Utilities._to_string(
    ::MOI.Utilities._PrintOptions,
    ::MOI.ModelLike,
    index::DynamicVariableIndex,
)
    return string("DynamicVariableIndex(", index.value, ")")
end

phase_index(dyn_var::DynamicVariableIndex) = dyn_var.phase

"""
    supports_dynamic_variable(model::MOI.ModelLike)::Bool

Return a `Bool` indicating whether `model` supports dynamic variables.
"""
supports_dynamic_variable(::MOI.ModelLike) = false

"""
    UnsupportedDynamicVariable(message::String)

An error indicating that dynamic variables are not supported by the model.

That is, that [`supports_dynamic_variable`](@ref) returns `false`. The message
`String` is stored in the `message` field.
"""
struct UnsupportedDynamicVariable <: MOI.UnsupportedError
    message::String
end

"""
    AddDynamicVariableNotAllowed(message::String)

An error indicating that dynamic variables cannot be added to the model
in its current state.

The `String` error message is stored in the `message` field.
"""
struct AddDynamicVariableNotAllowed <: MOI.NotAllowedError
    message::String
end

MOI.operation_name(::AddDynamicVariableNotAllowed) = "Adding a dynamic variable"

"""
    add_dynamic_variable(model::MOI.ModelLike, phase::PhaseIndex)::DynamicVariableIndex

Add a dynamic variable to `model`, returning a [`DynamicVariableIndex`](@ref).

An [`AddDynamicVariableNotAllowed`](@ref) is thrown if a dynamic variable cannot be added
to `model` in its current state.
"""
add_dynamic_variable(::MOI.ModelLike, ::PhaseIndex) =
    throw(AddDynamicVariableNotAllowed(""))

"""
    MOI.is_valid(model::MOI.ModelLike, index::DynamicVariableIndex)::Bool

Return a `Bool` indicating whether `index` refers to a valid [`DynamicVariableIndex`](@ref)
in `model`.
"""
MOI.is_valid(model::MOI.ModelLike, index::DynamicVariableIndex) = false

"""
    InvalidDynamicVariableIndex(index::DynamicVariableIndex)

An error indicating that the dynamic variable `index` is not valid.
"""
struct InvalidDynamicVariableIndex <: Exception
    index::DynamicVariableIndex
end

## Attributes

"""
    MOI.supports(
        model::MOI.ModelLike,
        attr::MOI.AbstractVariableAttribute,
        ::Type{DynamicVariableIndex},
    )::Bool

Return a `Bool` indicating whether `model` supports the attribute `attr` for
[`DynamicVariableIndex`](@ref)s.
"""
function MOI.supports(
    ::MOI.ModelLike,
    ::MOI.AbstractVariableAttribute,
    ::Type{DynamicVariableIndex},
)
    return false
end

"""
    MOI.set(
        model::MOI.ModelLike,
        attr::MOI.AbstractVariableAttribute,
        index::DynamicVariableIndex,
        value,
    )

Assign `value` to the attribute `attr` of dynamic variable `index` in model `model`.

An [`MOI.UnsupportedAttribute`](@extref MathOptInterface.UnsupportedAttribute)
error is thrown if `model` does not support the attribute `attr`, and a
[`MOI.SetAttributeNotAllowed`](@extref MathOptInterface.SetAttributeNotAllowed)
error is thrown if it supports the attribute `attr` but it cannot be set.
"""
function MOI.set(
    model::MOI.ModelLike,
    attr::MOI.AbstractVariableAttribute,
    index::DynamicVariableIndex,
    ::Any,
)
    if MOI.supports(model, attr, typeof(index))
        throw(MOI.SetAttributeNotAllowed(attr))
    else
        throw(MOI.UnsupportedAttribute(attr))
    end
    return nothing
end

"""
    MOI.get(
        model::MOI.ModelLike,
        attr::MOI.AbstractVariableAttribute,
        index::DynamicVariableIndex,
    )

Return the value of the attribute `attr` set to dynamic variable `index` in model `model`.

If the attribute `attr` is not supported by `model` then an error should be thrown.
If the attribute is supported but has not been set, `nothing` is returned.
"""
function MOI.get(
    model::MOI.ModelLike,
    attr::MOI.AbstractVariableAttribute,
    index::DynamicVariableIndex,
)
    throw(MOI.GetAttributeNotAllowed(
        attr,
        "$(typeof(model)) does not support getting the attribute $(attr) for $(typeof(index)).",
    ))
    return nothing
end