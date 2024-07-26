"""
    AbstractDynamicSolution

Abstract super-type for dynamic solutions.
"""
abstract type AbstractDynamicSolution end

"""
    (::AbstractDynamicSolution)(t::Real)

Evaluates a dynamic solution at `t`.
"""
(::AbstractDynamicSolution)(::Real) = nothing