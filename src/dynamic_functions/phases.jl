"""
    PhaseIndex(value::Int64)

A type-safe wrapper for `Int64` for use in referencing phases in a model.

It is a sub-type of [`AbstractDynamicFunction`](@ref). It represents an
independent variable ``t_i`` in a domain ``[t_i^0, t_i^f]``. The `Int64`
index value is stored in the `value` field. To allow for deletion, indices
need not be consecutive.
"""
struct PhaseIndex <: AbstractDynamicFunction
    value::Int64
end

function MOI.Utilities._to_string(
    ::MOI.Utilities._PrintOptions,
    ::MOI.ModelLike,
    index::PhaseIndex,
)
    return string("PhaseIndex(", index.value, ")")
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

That is, that [`supports_phase`](@ref) returns `false`. The `String` error
message is stored in the `message` field.
"""
struct UnsupportedPhase <: MOI.UnsupportedError
    message::String
end

"""
    AddPhaseNotAllowed(message::String)

An error indicating that phases cannot be added to the model in its current
state.

The `String` error message is stored in the `message` field.
"""
struct AddPhaseNotAllowed <: MOI.NotAllowedError
    message::String
end

"""
    add_phase(model::MOI.ModelLike)::PhaseIndex

Add a phase to `model`, returning a [`PhaseIndex`](@ref).

An [`AddPhaseNotAllowed`](@ref) error is thrown if a phase cannot be added
to the `model` in its current state.
"""
add_phase(::MOI.ModelLike) = throw(AddPhaseNotAllowed(""))

MOI.operation_name(::AddPhaseNotAllowed) = "Adding a phase"

"""
    MOI.is_valid(model::MOI.ModelLike, index::PhaseIndex)::Bool

Return a `Bool` indicating whether `index` refers to a valid
[`PhaseIndex`](@ref) in `model`.
"""
MOI.is_valid(model::MOI.ModelLike, index::PhaseIndex) = false

"""
    InvalidPhaseIndex(index::PhaseIndex)

An error indicating that the phase `index` is not valid.
"""
struct InvalidPhaseIndex <: Exception
    index::PhaseIndex
end

## Attributes

"""
    AbstractPhaseAttribute

Abstract super-type for phase attributes.
"""
abstract type AbstractPhaseAttribute end

"""
    MOI.supports(
        model::MOI.ModelLike,
        attr::AbstractPhaseAttribute,
        ::Type{PhaseIndex},
    )

Return a `Bool` indicating whether `model` supports the phase attribute
`attr` for [`PhaseIndex`](@ref)s.
"""
function MOI.supports(
    ::MOI.ModelLike,
    ::AbstractPhaseAttribute,
    ::Type{PhaseIndex},
)
    return false
end

"""
    MOI.set(
        model::MOI.ModelLike,
        attr::AbstractPhaseAttribute,
        index::PhaseIndex,
        value,
    )

Assign `value` to the attribute `attr` of phase `index` in model `model`.
"""
function MOI.set(
    model::MOI.ModelLike,
    attr::AbstractPhaseAttribute,
    index::PhaseIndex,
    ::Any,
)
    if MOI.supports(model, attr, typeof(index))
        throw(ArgumentError(
            "$(typeof(model)) does not currently allow setting the attribute $(attr) to $(index)."
        ))
    else
        throw(ArgumentError(
            "$(typeof(model)) does not support setting attribute $(attr) to a PhaseIndex."
        ))
    end
    return nothing
end

"""
    MOI.get(
        model::MOI.ModelLike,
        attr::AbstractPhaseAttribute,
        index::PhaseIndex,
    )

Return the value of the attribute `attr` set to phase `index` in model `model`.
"""
function MOI.get(
    model::MOI.ModelLike,
    attr::AbstractPhaseAttribute,
    index::PhaseIndex,
)
    throw(ArgumentError(
        "$(typeof(model)) does not support getting the attribute $(attr) for $(typeof(index))."
        ))
    return nothing
end

"""
    PhaseName()

A phase attribute for a `String` identifying a phase.
"""
struct PhaseName <: AbstractPhaseAttribute end