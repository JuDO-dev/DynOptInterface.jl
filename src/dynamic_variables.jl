abstract type AbstractDynamicFunction <: MOI.AbstractScalarFunction end

abstract type AbstractAlgebraicFunction <: AbstractDynamicFunction end

"""
    DomainIndex <: AbstractDynamicFunction

A type-safe wrapper for `Int64` for use in referencing domains.
"""
struct DomainIndex <: AbstractAlgebraicFunction
    value::Int64
end

"""
    AlgebraicVariableIndex <: AbstractDynamicFunction

A type-safe wrapper for `Int64` for use in referencing algebraic variables.
"""
struct AlgebraicVariableIndex <: AbstractAlgebraicFunction
    value::Int64
end

"""
    DifferentialVariableIndex <: AbstractDynamicFunction

A type-safe wrapper for `Int64` for use in referencing differential variables.
"""
struct DifferentialVariableIndex <: AbstractAlgebraicFunction
    value::Int64
end