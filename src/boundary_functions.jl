"""
    AbstractBoundaryFunction <: AbstractDynamicFunction

Abstract supertype for dynamic functions evaluated at the domain boundaries.
"""
abstract type AbstractBoundaryFunction <: AbstractDynamicFunction end

"""
    DomainInitial <: AbstractBoundaryFunction

Represents the initial point of a [`DomainIndex`](@ref).
"""
struct DomainInitial <: AbstractBoundaryFunction
    index::DomainIndex
end

"""
    DomainFinal <: AbstractBoundaryFunction

Represents the final point of a [`DomainIndex`](@ref).
"""
struct DomainFinal <: AbstractBoundaryFunction
    index::DomainIndex
end

"""
    DifferentialVariableInitial <: AbstractBoundaryFunction

Represents a [`DifferentialVariableIndex`](@ref) evaluated at the initial point of its [`DomainIndex`](@ref)
"""
struct DifferentialVariableInitial <: AbstractBoundaryFunction
    index::DifferentialVariableIndex
end

"""
    DifferentialVariableFinal <: AbstractBoundaryFunction

Represents a [`DifferentialVariableIndex`](@ref) evaluated at the final point of its [`DomainIndex`](@ref)
"""
struct DifferentialVariableFinal <: AbstractBoundaryFunction
    index::DifferentialVariableIndex
end

"""
    NonlinearBoundaryFunction <: AbstractBoundaryFunction

Represents a general 
Supports:
* [`DifferentialVariableInitial`](@ref)
* [`DifferentialVariableFinal`](@ref)
* [`DomainInitial`](@ref)
* [`DomainFinal`](@ref)
* [`NonlinearBoundaryFunction`](@ref)
* `MOI.ScalarNonlinearFunction`
"""
struct NonlinearBoundaryFunction <: AbstractBoundaryFunction
    head::Symbol
    args::Vector{Any}
    # Inner constructor to enforce rules
end

"""
    NonlinearLinkageFunction

Similar to [`NonlinearBoundaryFunction`](@ref) but with different domains allowed.
"""
struct NonlinearLinkageFunction <: AbstractDynamicFunction
    head::Symbol
    args::Vector{Any}
    # Inner constructor to enforce rules
end