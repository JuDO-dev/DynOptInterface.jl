"""
    Initial{AF<:AbstractAlgebraicFunction} <: AbstractBoundaryFunction

```math
a(y(t_i^0), t_i^0, x)
```
Represents the evaluation of an [`AbstractAlgebraicFunction`](@ref) at the initial 
point of its domain. Common cases are:
* ``t_i^0`` `Initial{DomainIndex}`
* ``y_j(t_i^0)`` `Initial{DynamicVariableIndex}`
"""
struct Initial{AF<:AbstractAlgebraicFunction} <: AbstractBoundaryFunction
    evaluand::AF
end

function MOI.Utilities._to_string(options::MOI.Utilities._PrintOptions, model::MOI.ModelLike,
    initial::Initial,
)
    return string(
        "Initial(", 
        MOI.Utilities._to_string(options, model, initial.evaluand),
        ")",
    )
end

"""
    Final{AF<:AbstractAlgebraicFunction} <: AbstractBoundaryFunction

```math
a(y(t_i^f), t_i^f, x)
```
Represents the evaluation of an [`AbstractAlgebraicFunction`](@ref) at the final 
point of its domain. Common cases are:
* ``t_i^f`` `Final{DomainIndex}`
* ``y_j(t_i^f)`` `Final{DynamicVariableIndex}`
"""
struct Final{AF<:AbstractAlgebraicFunction} <: AbstractBoundaryFunction
    evaluand::AF
end

function MOI.Utilities._to_string(options::MOI.Utilities._PrintOptions, model::MOI.ModelLike,
    final::Final,
)
    return string(
        "Final(",
        MOI.Utilities._to_string(options, model, final.evaluand),
        ")",
    )
end

const _NONLINEAR_BOUNDARY_TYPES = Union{
    Real,
    MOI.VariableIndex,
    Initial{DomainIndex},
    Final{DomainIndex},
    Initial{DynamicVariableIndex},
    Final{DynamicVariableIndex},
}

"""
    NonlinearBoundaryFunction <: AbstractBoundaryFunction
    
```math
f_b(y(t^0), y(t^f), t^0, t^f, x)
```
Similar to [`MathOptInterface.ScalarNonlinearFunction`](@ref), an expression
tree is used to represent nonlinear functions.

```julia
struct NonlinearAlgebraicFunction <: AbstractAlgebraicFunction
    head::Symbol
    args::Vector{Any}
...
end
```

### `head`

The symbol `head` must be an operator that is supported by the model. The 
model attribute [`MathOptInterface.ListOfSupportedNonlinearOperators`](@extref)
provides a list of supported operators. If the optimizer does not support `head`,
a [`MathOptInterface.UnsupportedNonlinearOperator`](@extref) error is thrown.

### `args`

The vector `args` contains the arguments to the nonlinear operator. Each element in
`args` can be one of the following:
* A constant value of type `T<:Real`
* A [`MathOptInterface.VariableIndex`](@extref) ``x_k``
* A [`MathOptInterface.ScalarAffineFunction`](@extref) ``a^\\top x + b``
* A [`MathOptInterface.ScalarQuadraticFunction`](@extref) ``x^\\top Q x + a^\\top x + b``
* A [`MathOptInterface.ScalarNonlinearFunction`](@extref) ``f(x)``
* A [`Initial`](@ref) of [`DomainIndex`](@ref) ``t_i^0``
* A [`Final`](@ref) of [`DomainIndex`](@ref) ``t_i^f``
* A [`Initial`](@ref) of [`DynamicVariableIndex`](@ref) ``y(t_i^0)``
* A [`Final`](@ref) of [`DynamicVariableIndex`](@ref) ``y(t_i^f)``
* Another [`NonlinearBoundaryFunction`](@ref)
"""
struct NonlinearBoundaryFunction <: AbstractBoundaryFunction
    head::Symbol
    args::Vector{Any}

    function NonlinearBoundaryFunction(head::Symbol, args::AbstractVector)
        for arg in args
            if !(arg isa _NONLINEAR_BOUNDARY_TYPES)
                error("Unsupported object: $arg")
            end
        end
        return new(head, convert(Vector{Any}, args), t_i)
    end
end

function MOI.Utilities._to_string(options::MOI.Utilities._PrintOptions, model::MOI.ModelLike,
    nbf::NonlinearBoundaryFunction,
)
    return _nonlinear_to_string(options, model, nbf)
end