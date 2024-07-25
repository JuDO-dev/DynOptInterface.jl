"""
    PhaseIndex(value::Int64)

A type-safe wrapper for `Int64` for use in referencing phases in a model.

A sub-type of [`AbstractDynamicFunction`](@ref). Represents an independent variable ``t_i``
in the domain ``[t_i^0, t_i^f]``. The `Int64` index is stored in the `value` field. To allow
for deletion, indices need not be consecutive.
"""
struct PhaseIndex <: AbstractDynamicFunction
    value::Int64
end

function MOI.Utilities._to_string(
    ::MOI.Utilities._PrintOptions,
    ::MOI.ModelLike,
    phase::PhaseIndex,
)
    return string("t[", phase.value, "]")
end

phase_index(t_i::PhaseIndex) = t_i

"""
    supports_phase(model::MOI.ModelLike)::Bool

Returns a `Bool` indicating whether `model` supports phases.
"""
supports_phase(::MOI.ModelLike) = false

"""
    UnsupportedPhase(message::String)

An error indicating that phases are not supported by the model.

That is, that [`supports_phase`](@ref) returns `false`. The message `String` is stored in the
`message` field.
"""
struct UnsupportedPhase <: MOI.UnsupportedError
    message::String
end

"""
    AddPhaseNotAllowed(message::String)

An error indicating that phases cannot be added to the model in its current state.

The message `String` is stored in the `message` field.
"""
struct AddPhaseNotAllowed <: MOI.NotAllowedError
    message::String
end

"""
    add_phase(model::MOI.ModelLike)::PhaseIndex

Add a phase to `model`, returning a [`PhaseIndex`](@ref).

An [`AddPhaseNotAllowed`](@ref) error is thrown if a phase cannot be added to the `model`
in its current state.
"""
add_phase(::MOI.ModelLike) = throw(AddPhaseNotAllowed(""))

MOI.operation_name(::AddPhaseNotAllowed) = "Adding a phase"

"""
    MOI.is_valid(model::MOI.ModelLike, index::PhaseIndex)::Bool

Return a `Bool` indicating whether `index` refers to a valid object in `model`.
"""
MOI.is_valid(model::MOI.ModelLike, index::PhaseIndex)

"""
    InvalidPhaseIndex(index::PhaseIndex)

An error indicating that the phase `index` is invalid.
"""
struct InvalidPhaseIndex <: Exception
    index::PhaseIndex
end