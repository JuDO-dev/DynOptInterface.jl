"""
    DynamicVariableIndex(value::Int64, phase::PhaseIndex)

An object for use in referencing dynamic variables in a model.

A sub-type of [`AbstractDynamicFunction`](@ref). Represents a dynamic variable
``t_i \\mapsto y_j(t_i)`` defined in the domain ``[t_i^0, t_i^f]``. The `Int64`
index is stored in the `value` field. To allow for deletion, indices need not be
consecutive.
"""
struct DynamicVariableIndex <: AbstractDynamicFunction
    value::Int64
    phase::PhaseIndex
end

function MOI.Utilities._to_string(
    ::MOI.Utilities._PrintOptions,
    ::MOI.ModelLike,
    dyn_var::DynamicVariableIndex,
)
    return string("y[", dyn_var.value, "]")
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

The message `String` is stored in the `message` field.
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

Return a `Bool` indicating whether `index` refers to a valid object in `model`.
"""
MOI.is_valid(model::MOI.ModelLike, index::DynamicVariableIndex)

"""
    InvalidDynamicVariableIndex(index::DynamicVariableIndex)

An error indicating that the dynamic variable `index` is invalid.
"""
struct InvalidDynamicVariableIndex <: Exception
    index::DynamicVariableIndex
end