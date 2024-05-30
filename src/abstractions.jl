"""
    AbstractDynamicFunction <: MOI.AbstractScalarFunction

Abstract supertype for dynamic functions.
"""
abstract type AbstractDynamicFunction <: MOI.AbstractScalarFunction end

"""
    AbstractAlgebraicFunction <: AbstractDynamicFunction

Abstract supertype for algebraic functions.
"""
abstract type AbstractAlgebraicFunction <: AbstractDynamicFunction end

"""
    AbstractDifferentialFunction <: AbstractDynamicFunction

Abstract supertype for differential functions.
"""
abstract type AbstractDifferentialFunction <: AbstractDynamicFunction end

"""
    AbstractBoundaryFunction <: AbstractDynamicFunction

Abstract supertype for dynamic functions evaluated at the domain boundaries.
"""
abstract type AbstractBoundaryFunction <: AbstractDynamicFunction end