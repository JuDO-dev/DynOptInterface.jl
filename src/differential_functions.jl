abstract type AbstractDifferentialFunction <: AbstractDynamicFunction end

"""
    DifferentialVariableDerivative <: AbstractDifferentialFunction

``\\dot{y}(\\cdot)``
"""
struct DifferentialVariableDerivative <: AbstractDifferentialFunction
    variable_index::DifferentialVariableIndex
end

"""
    ExplicitDifferentialFunction{AF<:AbstractAlgebraicFunction} <: AbstractDifferentialFunction

``\\dot{y}(\\cdot) - f(y(\\cdot), u(\\cdot), t, x)``
"""
struct ExplicitDifferentialFunction{AF<:AbstractAlgebraicFunction} <: AbstractDifferentialFunction
    derivative::DifferentialVariableDerivative
    f::AF
end

"""
    NonlinearDifferentialFunction <: AbstractDifferentialFunction

``r(\\dot{y}(\\cdot), y(\\cdot), u(\\cdot), t, x)``
Supports:
* [`DifferentialVariableDerivative`](@ref)
* [`NonlinearAlgebraicFunction`](@ref)
"""
struct NonlinearDifferentialFunction <: AbstractDifferentialFunction
    head::Symbol
    args::Vector{Any}
    # Inner constructor to enforce rules
end