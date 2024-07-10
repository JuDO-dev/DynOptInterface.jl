"""
    AbstractBoundaryFunction <: MOI.AbstractScalarFunction

Abstract supertype for dynamic functions evaluated at phase boundaries. That is,
expressions that may contain ``t^0``, ``t^f``, ``y(t^0)``, or ``y(t^f)``.
"""
abstract type AbstractBoundaryFunction <: MOI.AbstractScalarFunction end

"""
    Initial{AF<:AbstractDynamicFunction} <: AbstractBoundaryFunction

```math
b^0(y(t_i^0), t_i^0, x)
```
Represents the evaluation of an [`AbstractDynamicFunction`](@ref) at the initial 
point of its phase. Common cases are:
* ``t_i^0`` `Initial{PhaseIndex}`
* ``y_j(t_i^0)`` `Initial{DynamicVariableIndex}`
"""
struct Initial{AF<:AbstractDynamicFunction} <: AbstractBoundaryFunction
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
    Final{AF<:AbstractDynamicFunction} <: AbstractBoundaryFunction

```math
b^f(y(t_i^f), t_i^f, x)
```
Represents the evaluation of an [`AbstractDynamicFunction`](@ref) at the final 
point of its phase. Common cases are:
* ``t_i^f`` `Final{PhaseIndex}`
* ``y_j(t_i^f)`` `Final{DynamicVariableIndex}`
"""
struct Final{AF<:AbstractDynamicFunction} <: AbstractBoundaryFunction
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
    Initial{PhaseIndex},
    Final{PhaseIndex},
    Initial{DynamicVariableIndex},
    Final{DynamicVariableIndex},
}

"""
    struct NonlinearBoundaryFunction <: AbstractBoundaryFunction
        head::Symbol
        args::Vector{Any}
    ...
    end

```math
f_b(y(t^0), y(t^f), t^0, t^f, x)
```
Similar to [`MOI.ScalarNonlinearFunction`](@extref MathOptInterface.ScalarNonlinearFunction), nonlinear dynamic
functions are represented by an expression tree.

### `head`

The symbol `head` must be an operator that is supported by the model. The 
model attribute [`MOI.ListOfSupportedNonlinearOperators`](@extref MathOptInterface.ListOfSupportedNonlinearOperators)
provides a list of supported operators. If the optimizer does not support `head`,
a [`MOI.UnsupportedNonlinearOperator`](@extref MathOptInterface.UnsupportedNonlinearOperator) error is thrown.

### `args`

The vector `args` contains the arguments to the nonlinear operator. The possible
arguments that may be included are:
* A constant value of type `T<:Real`
* A [`MOI.VariableIndex`](@extref MathOptInterface.VariableIndex) ``x_k``
* A [`MOI.ScalarAffineFunction`](@extref MathOptInterface.ScalarAffineFunction) ``a^\\top x + b``
* A [`MOI.ScalarQuadraticFunction`](@extref MathOptInterface.ScalarQuadraticFunction) ``x^\\top Q x + a^\\top x + b``
* A [`MOI.ScalarNonlinearFunction`](@extref MathOptInterface.ScalarNonlinearFunction) ``f(x)``
* A [`Initial`](@ref) of [`PhaseIndex`](@ref) ``t_i^0``
* A [`Final`](@ref) of [`PhaseIndex`](@ref) ``t_i^f``
* A [`Initial`](@ref) of [`DynamicVariableIndex`](@ref) ``y(t_i^0)``
* A [`Final`](@ref) of [`DynamicVariableIndex`](@ref) ``y(t_i^f)``
* Another [`NonlinearBoundaryFunction`](@ref)
Additionally, the optimizer must indicate support of argument types through the 
[`supports_objective_argument`](@ref) and [`supports_constraint_argument`](@ref)
functions.
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