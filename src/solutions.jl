"""
    AbstractDynamicSolution

Supertype for solutions of dynamic functions.

Concrete subtypes must implement the method [`AbstractDynamicSolution(::Real)`](@ref).
"""
abstract type AbstractDynamicSolution end

"""
    (::AbstractDynamicSolution)(τ::Real)

Evaluates a dynamic solution at `τ`.
"""
function (::AbstractDynamicSolution)(::Real)
    return nothing
end