"""
    AbstractDynamicFunction

Supertype for scalar-valued dynamic functions.

That is, expressions that contain a phase parameter ``t^{(i)}``.
Each dynamic function must be defined on one (and only one) phase.
"""
abstract type AbstractDynamicFunction <: MOI.AbstractScalarFunction end

"""
    PhaseIndex(value::Int64)

Represent the phase parameter ``t^{(i)}`` in an expression.

It is a subtype of [`AbstractDynamicFunction`](@ref).
To allow for deletion, index values need not be consecutive.
"""
struct PhaseIndex <: AbstractDynamicFunction
    value::Int64
end

function Base.show(io::IO, ::MIME"text/plain", phase::PhaseIndex)
    return print(io, "DOI.PhaseIndex($(phase.value))")
end

"""
    phase_index(dyn_fun::AbstractDynamicFunction)::PhaseIndex

Return the [`PhaseIndex`](@ref) ``t^{(i)}`` of a dynamic function `dyn_fun`.
"""
function phase_index(::AbstractDynamicFunction)::PhaseIndex end

phase_index(t_i::PhaseIndex) = t_i

"""
    NonUniquePhaseError(message::String)

A dynamic function was not defined on one (and only one) phase.
"""
struct NonUniquePhaseError <: Exception
    message::String
end

## Phases in Models

"""
    supports_phases(model::MOI.ModelLike)::Bool

Indicate whether `model` supports phases.
"""
supports_phases(::MOI.ModelLike)::Bool = false

"""
    UnsupportedPhasesError(message::String)

The model does not support phases, that is, [`supports_phases`](@ref) returns `false`.
"""
struct UnsupportedPhasesError <: MOI.UnsupportedError
    message::String
end

"""
    add_phase(model::MOI.ModelLike)::PhaseIndex

Add a phase to `model`, returning a [`PhaseIndex`](@ref).

An [`AddPhaseNotAllowedError`](@ref) is thrown if a phase cannot be added
to the `model` in its current state.
"""
add_phase(::MOI.ModelLike) = throw(AddPhaseNotAllowedError(""))

"""
    AddPhaseNotAllowedError(message::String)

Phases cannot be added to the model in its current state.
"""
struct AddPhaseNotAllowedError <: MOI.NotAllowedError
    message::String
end

MOI.operation_name(::AddPhaseNotAllowedError) = "Adding a phase"

"""
    MOI.is_valid(model::MOI.ModelLike, phase::PhaseIndex)::Bool

Indicate whether `phase` refers to a valid [`PhaseIndex`](@ref) in `model`.
"""
MOI.is_valid(::MOI.ModelLike, ::PhaseIndex) = false

"""
    InvalidPhaseError(phase::PhaseIndex)

The phase `phase` is not valid in the model.
"""
struct InvalidPhaseError <: Exception
    phase::PhaseIndex
end

## Phase Attributes

"""
    AbstractPhaseAttribute

Supertype for phase attributes.
"""
abstract type AbstractPhaseAttribute end

"""
    MOI.supports(
        model::MOI.ModelLike,
        attr::AbstractPhaseAttribute,
    )::Bool

Indicate whether `model` supports the phase attribute `attr`.
"""
function MOI.supports(::MOI.ModelLike, ::AbstractPhaseAttribute)
    return false
end

"""
    MOI.set(
        model::MOI.ModelLike,
        attr::AbstractPhaseAttribute,
        phase::PhaseIndex,
        value::Any,
    )

Assign `value` to the attribute `attr` of phase `phase` in model `model`.
"""
function MOI.set(
    model::MOI.ModelLike,
    attr::AbstractPhaseAttribute,
    ::PhaseIndex,
    value::Any,
)
    if MOI.supports(model, attr)
        throw(ArgumentError(
            "$(typeof(model)) does not currently allow setting the attribute $(attr) to $(value)."
        ))
    else
        throw(ArgumentError(
            "$(typeof(model)) does not support attribute $(attr)."
        ))
    end
    return nothing
end

"""
    MOI.get(
        model::MOI.ModelLike,
        attr::AbstractPhaseAttribute,
        phase::PhaseIndex,
    )

Return the value of the attribute `attr` set to phase `phase` in `model`.

If the attribute `attr` is not supported by `model` then an error should be thrown.
If the attribute is supported but has not been set, `nothing` is returned.
"""
function MOI.get(model::MOI.ModelLike, attr::AbstractPhaseAttribute, phase::PhaseIndex)
    throw(ArgumentError(
        "$(typeof(model)) does not support getting the attribute $(attr) for $(typeof(phase))."
        ))
    return nothing
end

"""
    PhaseName

A phase attribute for a `String` identifying a phase.
"""
struct PhaseName <: AbstractPhaseAttribute end

"""
    PhaseInitialStart

A phase attribute for the start value of the initial phase boundary.
"""
struct PhaseInitialStart <: AbstractPhaseAttribute end

"""
    PhaseFinalStart

A phase attribute for the start value of the final phase boundary.
"""
struct PhaseFinalStart <: AbstractPhaseAttribute end
#=
"""
    PhaseInitialSolution

A phase attribute for the solution of the initial phase boundary.
"""
struct PhaseInitialSolution <: AbstractPhaseAttribute end

"""
    PhaseFinalSolution

A phase attribute for the solution of the final phase boundary.
"""
struct PhaseFinalSolution <: AbstractPhaseAttribute end=#