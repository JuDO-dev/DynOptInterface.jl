function Base.show(
    io::IO,
    mime::MIME"text/plain", 
    nl_fun::Union{NonlinearDynamicFunction,NonlinearBoundaryFunction},
)
    output = String(nl_fun.head) * "("
    
    io_buffer = IOBuffer()
    show(io_buffer, mime, nl_fun.args[1])
    output *= String(take!(io_buffer))

    for arg in nl_fun.args[2:end]
        output *= ", "
        io_buffer = IOBuffer()
        show(io_buffer, mime, arg)
        output *= String(take!(io_buffer))
    end
    
    output *= ")"
    return print(io, output)
end

"""
    supports_objective_argument(
        model::MOI.ModelLike,
        F::Type{<:MOI.AbstractScalarFunction},
        A::Type{<:MOI.AbstractScalarFunction},
    )::Bool

Indicate whether `model` supports objective functions of type `F` containing one or more
arguments of type `A`.
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

The `String` error message is stored in the `message` field.
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

Indicate whether `model` supports `F`-in-`S` constraints, where the function contains one or
more arguments of type `A`.
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

The `String` error message is stored in the `message` field.
"""
struct UnsupportedConstraintArgument{F,S,A} <: MOI.UnsupportedError
    message::String
end