"""
    AbstractDynamicFunction <: MOI.AbstractScalarFunction

Abstract supertype for dynamic functions.
"""
abstract type AbstractDynamicFunction <: MOI.AbstractScalarFunction end

"""
    AbstractAlgebraicFunction <: AbstractDynamicFunction

Abstract supertype for algebraic functions. That is, expressions that may contain
``y(t)`` or ``t``, but not ``\\dot{y}(t)``.
"""
abstract type AbstractAlgebraicFunction <: AbstractDynamicFunction end

"""
    AbstractDifferentialFunction <: AbstractDynamicFunction

Abstract supertype for differential functions. That is, expressions that may contain
``\\dot{y}(t)``, ``y(t)``, or ``t``.
"""
abstract type AbstractDifferentialFunction <: AbstractDynamicFunction end

"""
    AbstractBoundaryFunction <: AbstractDynamicFunction

Abstract supertype for functions evaluated at domain boundaries. That is,
expressions that may contain ``y(t^0)``, ``y(t^f)``, ``t^0``, or ``t^f``.
"""
abstract type AbstractBoundaryFunction <: AbstractDynamicFunction end

"""
    AbstractDomainAttribute

Abstract supertype for attribute objects that can be used to set or get attributes
(properties) of domains in the model.
"""
abstract type AbstractDomainAttribute end

"""
    AbstractDynamicVariableAttribute

Abstract supertype for attributs objects that can be used to set or get attributes
(properties) of dynamic variables in the model.
"""
abstract type AbstractDynamicVariableAttribute end

const DynamicAttribute = Union{
    AbstractDomainAttribute,
    AbstractDynamicVariableAttribute,
}

function MOI.get(model::MOI.ModelLike, attr::DynamicAttribute, args...)
    return throw(
        MOI.GetAttributeNotAllowed(
            attr,
            "$(typeof(model)) does not support getting the attribute $(attr).",
        )
    )
end