"""
    AbstractDynamicSolution

Supertype for solutions of dynamic functions.

Concrete subtypes must implement [`(::AbstractDynamicSolution)(t::Real)`](@ref).
"""
abstract type AbstractDynamicSolution end

"""
    (::AbstractDynamicSolution)(τ::Real)

Evaluates a dynamic solution at `τ`.
"""
(::AbstractDynamicSolution)(::Real) = nothing