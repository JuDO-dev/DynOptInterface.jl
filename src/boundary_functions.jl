## Abstraction

"""
    AbstractBoundaryFunction

Abstract super-type for dynamic functions evaluated at phase boundaries.
    
That is, expressions that may contain:
* ``t_i^0`` [`Initial`](@ref){[`PhaseIndex`](@ref)}
* ``t_i^f`` [`Final`](@ref){[`PhaseIndex`](@ref)}
* ``y_j(t^0)`` [`Initial`](@ref){[`DynamicVariableIndex`](@ref)}
* ``y_j(t^f)`` [`Final`](@ref){[`DynamicVariableIndex`](@ref)}
"""
abstract type AbstractBoundaryFunction <: MOI.AbstractScalarFunction end

## Initial & Final

"""
    Initial{DF}(dyn_fun::DF) where {DF<:AbstractDynamicFunction}

Represents the evaluation of an [`AbstractDynamicFunction`](@ref) at the initial 
point of its phase.

It is a sub-type of [`AbstractBoundaryFunction`](@ref). The dynamic function is stored
in the `dyn_fun` field.
"""
struct Initial{DF<:AbstractDynamicFunction} <: AbstractBoundaryFunction
    dyn_fun::DF
end

function MOI.Utilities._to_string(
    options::MOI.Utilities._PrintOptions,
    model::MOI.ModelLike,
    initial::Initial,
)
    return string(
        "Initial(",
        MOI.Utilities._to_string(options, model, initial.dyn_fun),
        ")",
    )
end

"""
    Final{DF}(dyn_fun::DF) where {DF<:AbstractDynamicFunction}

Represents the evaluation of an [`AbstractDynamicFunction`](@ref) at the final 
point of its phase.

It is a sub-type of [`AbstractBoundaryFunction`](@ref). The dynamic function is stored
in the `dyn_fun` field.
"""
struct Final{DF<:AbstractDynamicFunction} <: AbstractBoundaryFunction
    dyn_fun::DF
end

function MOI.Utilities._to_string(
    options::MOI.Utilities._PrintOptions,
    model::MOI.ModelLike,
    final::Final,
)
    return string(
        "Final(",
        MOI.Utilities._to_string(options, model, final.dyn_fun),
        ")",
    )
end

## Linkage

"""
    Linkage{DF}(
        final::Final{DF},
        initial::Initial{DF},
    ) where {DF<:AbstractDynamicFunction}

Represents the expression ``f_f(y(t^f), t^f) - f_0(y(t^0), t^0)``.

It is a sub-type of [`AbstractBoundaryFunction`](@ref). The final function is stored in the
`final` field and the initial function is stored in the `initial` field.
"""
struct Linkage{DF<:AbstractDynamicFunction} <: AbstractBoundaryFunction
    final::Final{DF}
    initial::Initial{DF}
end

function MOI.Utilities._to_string(
    options::MOI.Utilities._PrintOptions,
    model::MOI.ModelLike,
    linkage::Linkage,
)
    return string(
        MOI.Utilities._to_string(options, model, linkage.final),
        " - ",
        MOI.Utilities._to_string(options, model, linkage.initial),
    )
end

## Nonlinear

"""
    NonlinearBoundaryFunction(head::Symbol, args::Vector{Any})

Represents a general function ``f_b(y(t^0), y(t^f), t^0, t^f, x)``.

It is a sub-type of [`AbstractBoundaryFunction`](@ref). Similar to
[`MOI.ScalarNonlinearFunction`](@extref MathOptInterface.ScalarNonlinearFunction),
this function is represented by an expression tree, using the following fields:

### `head`

The symbol `head` must be an operator that is supported by the model. The model attribute
[`MOI.ListOfSupportedNonlinearOperators`](@extref MathOptInterface.ListOfSupportedNonlinearOperators)
provides a list of supported operators. If the optimizer does not support `head`,
an [`MOI.UnsupportedNonlinearOperator`](@extref MathOptInterface.UnsupportedNonlinearOperator)
error is thrown.

### `args`

The vector `args` contains the arguments to the nonlinear operator. The possible arguments that
may be included are:
* A constant value of type `T<:Real`
* An [`MOI.VariableIndex`](@extref MathOptInterface.VariableIndex) ``x_k``
* An [`MOI.ScalarAffineFunction`](@extref MathOptInterface.ScalarAffineFunction) ``a^\\top x + b``
* An [`MOI.ScalarQuadraticFunction`](@extref MathOptInterface.ScalarQuadraticFunction) ``x^\\top Q x + a^\\top x + b``
* An [`MOI.ScalarNonlinearFunction`](@extref MathOptInterface.ScalarNonlinearFunction) ``f(x)``
* An [`Initial`](@ref){[`PhaseIndex`](@ref)} ``t_i^0``
* A [`Final`](@ref){[`PhaseIndex`](@ref)} ``t_i^f``
* An [`Initial`](@ref){[`DynamicVariableIndex`](@ref)} ``y_j(t_i^0)``
* A [`Final`](@ref){[`DynamicVariableIndex`](@ref)} ``y_j(t_i^f)``
* Another [`NonlinearBoundaryFunction`](@ref)
Additionally, the optimizer must indicate support of argument types through the 
[`supports_objective_argument`](@ref) and [`supports_constraint_argument`](@ref)
functions. Otherwise [`UnsupportedObjectiveArgument`](@ref) and
[`UnsupportedConstraintArgument`](@ref) errors are thrown.
"""
struct NonlinearBoundaryFunction <: AbstractBoundaryFunction
    head::Symbol
    args::Vector{Any}
end

function MOI.Utilities._to_string(
    options::MOI.Utilities._PrintOptions,
    model::MOI.ModelLike,
    nbf::NonlinearBoundaryFunction,
)
    return _nonlinear_to_string(options, model, nbf)
end

## Integrals

"""
    Integral{DF}(dyn_fun::AbstractDynamicFunction) where {DF<:AbstractDynamicFunction}

Represents the integral ``\\int_{t_i^o}^{t_i^f} f_d(\\dot{y}(t_i), y(t_i), t_i, x) \\mathrm{d}t_i``.

It is a sub-type of [`AbstractBoundaryFunction`](@ref). The integrand is stored in the `dyn_fun` field.
"""
struct Integral{DF<:AbstractDynamicFunction} <: AbstractBoundaryFunction
    dyn_fun::DF
end

function MOI.Utilities._to_string(
    options::MOI.Utilities._PrintOptions,
    model::MOI.ModelLike,
    integral::Integral,
)
    return string(
        "∫(",
        MOI.Utilities._to_string(options, model, integral.dyn_fun),
        ")d(",
        MOI.Utilities._to_string(options, model, phase_index(integral)),
        ")",
    )
end

phase_index(integral::Integral) = phase_index(integral.dyn_fun)

"""
    Bolza{BF,DF}(
        bou_fun::BF,
        integral::Integral{DF},
    ) where {BF<:AbstractBoundaryFunction,DF<:AbstractDynamicFunction}

```math
f_b(y_0, y_f, t_0, t_f, x) + \\int_{t_i^o}^{t_i^f} f_d(\\dot{y}(t_i), y(t_i), t_i, x) \\mathrm{d}t_i
```
Represents the sum of an [`AbstractBoundaryFunction`](@ref) with the integral of
an [`AbstractDynamicFunction`](@ref).

It is a sub-type of [`AbstractBoundaryFunction`](@ref). The boundary function is stored in the `bou_fun`
field and the integral is stored in the `integral` field.
"""
struct Bolza{BF<:AbstractBoundaryFunction,DF<:AbstractDynamicFunction} <:
       AbstractBoundaryFunction
    bou_fun::BF
    integral::Integral{DF}
end

function MOI.Utilities._to_string(
    options::MOI.Utilities._PrintOptions,
    model::MOI.ModelLike,
    bolza::Bolza,
)
    return string(
        MOI.Utilities._to_string(options, model, bolza.bou_fun),
        " + ",
        MOI.Utilities._to_string(options, model, bolza.integral),
    )
end