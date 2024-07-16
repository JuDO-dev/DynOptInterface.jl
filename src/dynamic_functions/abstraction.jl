"""
    AbstractDynamicFunction

Abstract supertype for dynamic functions.

That is, expressions that may be or contain:
* ``t`` [`PhaseIndex`](@ref)s
* ``y(t)`` [`DynamicVariableIndex`](@ref)s
* ``\\dot{y}(t)`` [`DynamicVariableDerivative`](@ref)s
Sub-types of [`AbstractDynamicFunction`](@ref) must not have different
[`PhaseIndex`](@ref)s.
"""
abstract type AbstractDynamicFunction <: MOI.AbstractScalarFunction end

"""
    phase_index(fun::AbstractDynamicFunction)::PhaseIndex

Returns the [`PhaseIndex`](@ref) ``t_i`` of the dynamic function `fun`.
"""
function phase_index(::AbstractDynamicFunction)::PhaseIndex end

"""
    MixedPhases(message::String)

An error raised when trying to create a dynamic function with different
[`PhaseIndex`](@ref)s.

The message `String` is stored in the `message` field.
"""
struct MixedPhases <: Exception
    message::String
end