"""
    supports_objective_argument(
        model::MOI.ModelLike,
        F::Type{<:MOI.AbstractScalarFunction},
        A::Type{<:MOI.AbstractScalarFunction},
    )::Bool

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
    UnsupportedObjectiveArgument{F,A}(message::String)

An error indicating that [`supports_objective_argument`](@ref) returns `false`.

The message `String` is stored in the `message` field.
"""
struct UnsupportedObjectiveArgument{F,A} <: MOI.UnsupportedError
    message::String
end

"""
    supports_constraint_argument(
        model::MOI.ModelLike,
        F::Type{<:MOI.AbstractScalarFunction},
        S::Type{<:MOI.AbstractScalarSet},
        A::Type{<:MOI.AbstractScalarFunction},
    )::Bool

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

"""
    UnsupportedConstraintArgument{F,S,A}(message::String)

An error indicating that [`supports_constraint_argument`](@ref) returns `false`.

The message `String` is stored in the `message` field.
"""
struct UnsupportedConstraintArgument{F,S,A} <: MOI.UnsupportedError
    message::String
end