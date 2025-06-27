## Abstraction

"""
    AbstractBoundaryFunction

Supertype for dynamic functions evaluated at initial and/or final phase boundaries.
    
That is, expressions that contain ``t_0`` and/or ``t_f``, respectively.
"""
abstract type AbstractBoundaryFunction <: MOI.AbstractScalarFunction end

## Initial & Final

"""
    Initial{DF}(dyn_fun::DF) where {DF<:AbstractDynamicFunction}

Represent the evaluation of an [`AbstractDynamicFunction`](@ref) at the initial boundary of
its phase.

It is a subtype of [`AbstractBoundaryFunction`](@ref).
"""
struct Initial{DF<:AbstractDynamicFunction} <: AbstractBoundaryFunction
    dyn_fun::DF
end

function Base.show(io::IO, mime::MIME"text/plain", initial::Initial)

    output = "DOI.Initial("
    io_buffer = IOBuffer()
    show(io_buffer, mime, initial.dyn_fun)
    output *= String(take!(io_buffer)) * ")"
    return print(io, output)
end

"""
    Final{DF}(dyn_fun::DF) where {DF<:AbstractDynamicFunction}

Represent the evaluation of an [`AbstractDynamicFunction`](@ref) at the final boundary of 
its phase.

It is a subtype of [`AbstractBoundaryFunction`](@ref).
"""
struct Final{DF<:AbstractDynamicFunction} <: AbstractBoundaryFunction
    dyn_fun::DF
end

function Base.show(io::IO, mime::MIME"text/plain", final::Final)

    output = "DOI.Final("
    io_buffer = IOBuffer()
    show(io_buffer, mime, final.dyn_fun)
    output *= String(take!(io_buffer)) * ")"
    return print(io, output)
end

## Linkage

"""
    Linkage{DF}(dyn_fun_final::DF, dyn_fun_initial::DF) where {DF<:AbstractDynamicFunction}

Represent the expression
``b_f(\\boldsymbol{y}(t_f), t_f) - b_0(\\boldsymbol{y}(t_0), t_0)``.

It is a subtype of [`AbstractBoundaryFunction`](@ref).
"""
struct Linkage{DF<:AbstractDynamicFunction} <: AbstractBoundaryFunction
    dyn_fun_final::DF
    dyn_fun_initial::DF
end

function Base.show(io::IO, mime::MIME"text/plain", linkage::Linkage)

    output = "(DOI.Final("
    io_buffer = IOBuffer()
    show(io_buffer, mime, linkage.dyn_fun_final)
    output *= String(take!(io_buffer)) * ") - DOI.Initial("
    show(io_buffer, mime, linkage.dyn_fun_initial)
    output *= String(take!(io_buffer)) * "))"
    return print(io, output)
end

## Nonlinear

"""
    NonlinearBoundaryFunction(head::Symbol, args::Vector{Any})

Represents a general boundary function
``b(\\boldsymbol{y}(t_0), \\boldsymbol{y}(t_f), t_0, t_f, x)``.

It is a subtype of [`AbstractBoundaryFunction`](@ref).

Similar to
[`MOI.ScalarNonlinearFunction`](@extref MathOptInterface.ScalarNonlinearFunction), this
function is represented by an expression tree, using the following fields:

### `head`

The symbol `head` must be an operator that is supported by the model. The model attribute
[`MOI.ListOfSupportedNonlinearOperators`](@extref MathOptInterface.ListOfSupportedNonlinearOperators)
provides a list of supported operators. If the optimizer does not support `head`, an
[`MOI.UnsupportedNonlinearOperator`](@extref MathOptInterface.UnsupportedNonlinearOperator)
error is thrown.

### `args`

The vector `args` contains the arguments to the nonlinear operator. The arguments must be
subtypes of:
* `Real`
* [`MOI.AbstractScalarFunction`](@extref MathOptInterface.AbstractScalarFunction)
* [`AbstractBoundaryFunction`](@ref)`, including other [`NonlinearBoundaryFunction`](@ref)s

Additionally, the optimizer must indicate support of argument types through the 
[`supports_objective_argument`](@ref) and [`supports_constraint_argument`](@ref) functions.
Otherwise [`UnsupportedObjectiveArgument`](@ref) and [`UnsupportedConstraintArgument`](@ref)
errors are thrown.
"""
struct NonlinearBoundaryFunction <: AbstractBoundaryFunction
    head::Symbol
    args::Vector{Any}
end

## Integrals

"""
    Integral{DF}(dyn_fun::DF) where {DF<:AbstractDynamicFunction}

Represent the expression
``\\int_{t_0^{(i)}}^{t_f^{(i)}} d(\\dot{\\boldsymbol{y}}(t^{(i)}), \\boldsymbol{y}(t^{(i)}), t^{(i)}, x) \\mathrm{d}t^{(i)}``.

It is a sub-type of [`AbstractBoundaryFunction`](@ref).
"""
struct Integral{DF<:AbstractDynamicFunction} <: AbstractBoundaryFunction
    dyn_fun::DF
end

function Base.show(io::IO, mime::MIME"text/plain", integral::Integral)

    output = "∫("
    io_buffer = IOBuffer()
    show(io_buffer, mime, integral.dyn_fun)
    output *= String(take!(io_buffer)) * ")"
    return print(io, output)
end

"""
    MultiPhaseIntegral{DF}(dyn_funs::Vector{DF}) where {DF<:AbstractDynamicFunction}

Represent the sum of integrals
``\\sum_i \\big[ \\int_{t_0^{(i)}}^{t_f^{(i)}} d(\\dot{\\boldsymbol{y}}(t^{(i)}), \\boldsymbol{y}(t^{(i)}), t^{(i)}, x) \\mathrm{d}t^{(i)} \\big]``.

It is a subtype of [`AbstractBoundaryFunction`](@ref).
"""
struct MultiPhaseIntegral{DF<:AbstractDynamicFunction} <: AbstractBoundaryFunction
    dyn_funs::Vector{DF}
end

function Base.show(io::IO, mime::MIME"text/plain", multi_phase_integral::MultiPhaseIntegral)

    output = "(∫("
    io_buffer = IOBuffer()
    show(io_buffer, mime, multi_phase_integral.dyn_funs[1])
    output *= String(take!(io_buffer)) * ")"
    for dyn_fun in multi_phase_integral.dyn_funs[2:end]
        output *= " + ∫("
        show(io_buffer, mime, dyn_fun)
        output *= String(take!(io_buffer)) * ")"
    end
    output *= ")"
    return print(io, output)
end

"""
    Bolza{BF,IF}(
        bou_fun::BF,
        integral::IF,
    ) where {BF<:AbstractBoundaryFunction,IF<:Union{Integral,MultiPhaseIntegral}}

Represent
`` b(\\boldsymbol{y}(t_0), \\boldsymbol{y}(t_f), t_0, t_f, x) + \\sum_i \\big[ \\int_{t_0^{(i)}}^{t_f^{(i)}} d(\\dot{\\boldsymbol{y}}(t^{(i)}), \\boldsymbol{y}(t^{(i)}), t^{(i)}, x) \\mathrm{d}t^{(i)} \\big]``

That is, the sum of an [`AbstractBoundaryFunction`](@ref) with either an [`Integral`](@ref) or a
[`MultiPhaseIntegral`](@ref). It is a subtype of [`AbstractBoundaryFunction`](@ref).
"""
struct Bolza{BF<:AbstractBoundaryFunction,IF<:Union{Integral,MultiPhaseIntegral}} <: AbstractBoundaryFunction
    bou_fun::BF
    integral::IF
end

function Base.show(io::IO, mime::MIME"text/plain", bolza::Bolza)

    output = "("
    io_buffer = IOBuffer()
    show(io_buffer, mime, bolza.bou_fun)
    output *= String(take!(io_buffer)) * " + "
    show(io_buffer, mime, bolza.integral)
    output *= String(take!(io_buffer)) * ")"
    return print(io, output)
end