"""
    AbstractDynamicFunction

Abstract super-type for dynamic functions.

That is, expressions that may contain:
* ``t_i`` -- a [`PhaseIndex`](@ref)
* ``y_j(\\cdot)`` -- a [`DynamicVariableIndex`](@ref)

Sub-types of [`AbstractDynamicFunction`](@ref) must be defined on a single 
[`PhaseIndex`](@ref).
"""
abstract type AbstractDynamicFunction <: MOI.AbstractScalarFunction end

"""
    phase_index(dyn_fun::AbstractDynamicFunction)::PhaseIndex

Returns the [`PhaseIndex`](@ref) ``t_i`` of a dynamic function `dyn_fun`.
"""
function phase_index(::AbstractDynamicFunction)::PhaseIndex end

"""
    MixedPhases(message::String)

An error raised when trying to create a dynamic function with different
[`PhaseIndex`](@ref)s.

The `String` error message is stored in the `message` field.
"""
struct MixedPhases <: Exception
    message::String
end