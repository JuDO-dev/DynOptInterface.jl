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

"""
    DefaultIntervals()
The default intervals for dynamic solutions are the same as the default intervals for the model.
"""
struct GeneralIntervals <: MOI.AbstractOptimizerAttribute end

struct DefaultPoints <: MOI.AbstractOptimizerAttribute end
struct DefaultMethod <: MOI.AbstractOptimizerAttribute end
struct DefaultBounds <: MOI.AbstractOptimizerAttribute end

abstract type AbstractIntervals end
abstract type AbstractPoints    end
abstract type AbstractMethod    end
abstract type AbstractBounds    end

struct FixedIntervals <: AbstractIntervals
    number::Int
    function FixedIntervals(n::Integer)
        n ≥ 1 || throw(DomainError(n, "FixedIntervals: number must be ≥ 1."))
        return new(Int(n))
    end
end

struct FlexibleIntervals <: AbstractIntervals
    number::Int
    flexibility::Float64
    function FlexibleIntervals(n::Integer, flexibility::Real = 0.5)
        n ≥ 2 || throw(DomainError(n, "FlexibleIntervals: number must be ≥ 2."))
        0 ≤ flexibility ≤ 1 || throw(DomainError(flexibility, "FlexibleIntervals: flexibility must be in [0, 1]."))
        return new(Int(n), Float64(flexibility))
    end
end

struct LGRPoints <: AbstractPoints
    number::Int
    function LGRPoints(n::Integer)
        n ≥ 1 || throw(DomainError(n, "LGRPoints: number must be ≥ 1."))
        return new(Int(n))
    end
end

struct LGLPoints <: AbstractPoints
    number::Int
    function LGLPoints(n::Integer)
        n ≥ 1 || throw(DomainError(n, "LGLPoints: number must be ≥ 1."))
        return new(Int(n))
    end
end

struct Collocation <: AbstractMethod end

struct DAIR <: AbstractMethod
    number::Int
    function DAIR(n::Integer)
        n ≥ 1 || throw(DomainError(n, "DAIR: quadrature points must be ≥ 1."))
        return new(Int(n))
    end
end

struct ExactBounds    <: AbstractBounds end
struct BernsteinBounds <: AbstractBounds end

function supports_setting(::MOI.ModelLike, ::MOI.AbstractOptimizerAttribute)
    return false
end
