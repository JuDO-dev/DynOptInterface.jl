## Types

"""
    AbstractDynamicFunction <: MOI.AbstractScalarFunction

Abstract supertype for dynamic functions. That is, expressions that may contain
``t``, ``y(t)``, or ``\\dot{y}(t)``.
"""
abstract type AbstractDynamicFunction <: MOI.AbstractScalarFunction end

"""
    struct PhaseIndex <: AbstractDynamicFunction
        value::Int64
    end

```math
t_i \\in [t_i^0, t_i^f]
```
A type-safe wrapper for `Int64` for use in referencing phases.
"""
struct PhaseIndex <: AbstractDynamicFunction
    value::Int64
end

function MOI.Utilities._to_string(::MOI.Utilities._PrintOptions, ::MOI.ModelLike,
    t_i::PhaseIndex
)
    return string("t[", t_i.value, "]")
end

"""
    AbstractPhaseAttribute

Abstract supertype for attribute objects that can be used to set or get attributes
(properties) of phases in the model.
"""
abstract type AbstractPhaseAttribute end

## Errors

"""
    UnsupportedPhase <: MOI.UnsupportedError

An error indicating that phases are not supported by the model, that is, 
that [`supports_phase`](@ref) returns `false`.
"""
struct UnsupportedPhase <: MOI.UnsupportedError
    message::String
end

"""
    AddPhaseNotAllowed <: MOI.NotAllowedError

An error indicating that phases cannot be added to the model in its
current state.
"""
struct AddPhaseNotAllowed <: MOI.NotAllowedError
    message::String
end

MOI.operation_name(::AddPhaseNotAllowed) = "Adding a phase"

# Functions

"""
    supports_phase(model::MOI.ModelLike)::Bool

Returns a `Bool` indicating whether `model` supports phases.
"""
supports_phase(::MOI.ModelLike) = false

"""
    add_phase(model::MOI.ModelLike)

Add a phase to `model`, returning a [`PhaseIndex`](@ref). An
[`AddPhaseNotAllowed`](@ref) error is thrown if a phase cannot be added
to the `model` in its current state.
"""
add_phase(::MOI.ModelLike) = throw(AddPhaseNotAllowed(""))

"""
    MOI.supports(
        model::MOI.ModelLike,
        attr::AbstractPhaseAttribute,
        ::Type{PhaseIndex},
    )::Bool

Returns a `Bool` indicating whether `model` supports the phase attribute `attr`.
"""
MOI.supports(::MOI.ModelLike, ::AbstractPhaseAttribute, ::Type{PhaseIndex}) = false

"""
    MOI.set(
        model::MOI.ModelLike,
        attr::AbstractPhaseAttribute,
        t_i::PhaseIndex,
        value,
    )

Assigns `value` to the attribute `attr` of phase `t_i` in model `model`. An
[`MOI.UnsupportedAttribute`](@extref MathOptInterface.UnsupportedAttribute) error
is thrown if `model` does not support the attribute `attr`, and a
[`MOI.SetAttributeNotAllowed`](@extref MathOptInterface.SetAttributeNotAllowed)
error is thrown if it supports the attribute `attr` but it cannot be set.
"""
function MOI.set(model::MOI.ModelLike, attr::AbstractPhaseAttribute, ::PhaseIndex, value)
    if MOI.supports(model, attr)
        return throw(
            MOI.SetAttributeNotAllowed(
                attr,
                "$(model) does not support setting the "))
    else
        return throw(
            MOI.UnsupportedAttribute(
                attr,
                "$(typeof(model)) does not support the phase attribute $(attr).",
            )
        )
    end
end

"""
    MOI.get(model::MOI.ModelLike, attr::AbstractPhaseAttribute, t_i::PhaseIndex)

If the attribute `attr` is set for the phase `t_i`, return its value; return `nothing`
otherwise. If the attribute `attr` is not supported by `model`, an error is thrown.
"""
function MOI.get(model::MOI.ModelLike, attr::AbstractPhaseAttribute, ::PhaseIndex)
    return throw(
        MOI.GetAttributeNotAllowed(
            attr,
            "$(typeof(model)) does not support getting the attribute $(attr).",
        )
    )
end

## Attributes

"""
    PhaseName <: AbstractPhaseAttribute

A phase attribute for a `String` identifying a [`PhaseIndex`](@ref).
If not set, it has a default value of `""`.
"""
struct PhaseName <: AbstractPhaseAttribute end

MOI.attribute_value_type(::PhaseName) = String

"""
    PhaseInitialPrimalStart <: AbstractPhaseAttribute

A phase attribute for setting a starting value for ``t_i^0``, which may
help warm-start the optimizer. It is either a number or a `nothing` (unset).
"""
struct PhaseInitialPrimalStart <: AbstractPhaseAttribute end

"""
    PhaseFinalPrimalStart <: AbstractPhaseAttribute

A phase attribute for setting a starting value for ``t_i^f``, which may
help warm-start the optimizer. It is either a number or a `nothing` (unset).
"""
struct PhaseFinalPrimalStart <: AbstractPhaseAttribute end

"""
    PhaseInitialPrimal <: AbstractPhaseAttribute

A phase attribute for setting or getting ``t_i^0``. It should have the
same behaviour as the [`MOI.VariablePrimal`](@extref MathOptInterface.VariablePrimal) attribute.
"""
struct PhaseInitialPrimal <: AbstractPhaseAttribute
    result_index::Int
    PhaseInitialPrimal(result_index::Int=1) = new(result_index)
end

"""
    PhaseFinalPrimal <: AbstractPhaseAttribute

A phase attribute for setting or getting ``t_i^f``. It should have the
same behaviour as the [`MOI.VariablePrimal`](@extref MathOptInterface.VariablePrimal) attribute.
"""
struct PhaseFinalPrimal <: AbstractPhaseAttribute
    result_index::Int
    PhaseFinalPrimal(result_index::Int=1) = new(result_index)
end