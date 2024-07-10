## Errors

"""
    UnsupportedObjectiveArgument{F,A} <: MOI.UnsupportedError

An error indicating that 
"""
struct UnsupportedObjectiveArgument{F,A} <: MOI.UnsupportedError
    message::String
end

"""
    UnsupportedConstraintArgument{F,S,A} <: MOI.UnsupportedError

An error indicating that
"""
struct UnsupportedConstraintArgument{F,S,A} <: MOI.UnsupportedError
    message::String
end

## Functions

"""
    supports_objective_argument(
        model::MOI.ModelLike,
        F::Type{<:MOI.AbstractScalarFunction},
        A::Type{<:MOI.AbstractScalarFunction},
    )

Return a `Bool` indicating whether `model` supports objective functions of type `F`
containing one or more arguments of type `A`.
"""
function supports_objective_argument(
    ::MOI.ModelLike,
    ::Type{<:MOI.AbstractScalarFunction},
    ::Type{<:MOI.AbstractScalarFunction},
)
    return false
end

"""
    supports_constraint_argument(
        model::MOI.ModelLike,
        F::Type{<:MOI.AbstractScalarFunction},
        S::Type{<:MOI.AbstractScalarSet},
        A::Type{<:MOI.AbstractScalarFunction},
    )

Return a `Bool` indicating whether `model` supports `F`-in-`S` constraints, where
the function contains one or more arguments of type `A`.
"""
function supports_constraint_argument(
    ::MOI.ModelLike,
    ::Type{<:MOI.AbstractScalarFunction},
    ::Type{<:MOI.AbstractScalarSet},
    ::Type{<:MOI.AbstractScalarFunction},
)
    return false
end