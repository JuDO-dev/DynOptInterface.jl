## Linear

"""
    LinearDynamicTerm{T}(coefficient::T, dyn_var::DynamicVariableIndex) where {T}

Represent the term ``c_j \\boldsymbol{y}_j(\\cdot)``, where ``c_j`` is a coefficient of type
`T`.
"""
struct LinearDynamicTerm{T}
    coefficient::T
    dyn_var::DynamicVariableIndex
end

"""
    LinearDynamicFunction{T}(terms::Vector{LinearDynamicTerm{T}}) where {T}

Represent the expression ``c^\\top \\boldsymbol{y}(\\cdot)``, that is, a sum of
[`LinearDynamicTerm`](@ref)s.

It is a subtype of [`AbstractDynamicFunction`](@ref).
All dynamic variables must be defined on the same phase, otherwise a
[`NonUniquePhaseError`](@ref) error is thrown.
"""
struct LinearDynamicFunction{T} <: AbstractDynamicFunction
    terms::Vector{LinearDynamicTerm{T}}

    function LinearDynamicFunction(
        terms::Vector{LinearDynamicTerm{T}},
    ) where {T}
        if !all(term -> phase_index(term.dyn_var) == phase_index(terms[1].dyn_var), terms)
            throw(NonUniquePhaseError(""))
        end
        return new{T}(terms)
    end
end

function Base.show(io::IO, mime::MIME"text/plain", linear_dyn_fun::LinearDynamicFunction)
    
    output = String(linear_dyn_fun.terms[1].coefficient) * " "
    io_buffer = IOBuffer()
    show(io_buffer, mime, linear_dyn_fun.terms[1].dyn_var)
    output *= String(take!(io_buffer))

    for term in linear_dyn_fun.terms[2:end]
        output *= " + " * String(term.coefficient) * " "
        show(io_buffer, mime, term.dyn_var)
        output *= String(take!(io_buffer))
    end

    return print(io, output)
end

function phase_index(linear_dyn_fun::LinearDynamicFunction) 
    return phase_index(linear_dyn_fun.terms[1].dyn_var)
end

## Pure Quadratic

"""
    PureQuadraticDynamicTerm{T}(
        coefficient::T
        dyn_var_1::DynamicVariableIndex
        dyn_var_2::DynamicVariableIndex
    ) where {T}

Represent the term ``c_{jk} \\boldsymbol{y}_j(\\cdot) \\boldsymbol{y}_k(\\cdot)``, where
``c_{jk}`` is a coefficient of type `T`.
"""
struct PureQuadraticDynamicTerm{T}
    coefficient::T
    dyn_var_1::DynamicVariableIndex
    dyn_var_2::DynamicVariableIndex

    function PureQuadraticDynamicTerm(
        coefficient::T,
        dyn_var_1::DynamicVariableIndex,
        dyn_var_2::DynamicVariableIndex,
    ) where {T}
        if phase_index(dyn_var_1) != phase_index(dyn_var_2)
            throw(NonUniquePhaseError(""))
        end
        return new{T}(coefficient, dyn_var_1, dyn_var_2)
    end
end

"""
    PureQuadraticDynamicFunction{T}(terms::Vector{PureQuadraticDynamicTerm{T}}) where {T}

Represent the expression ``\\boldsymbol{y}(\\cdot)^\\top C \\boldsymbol{y}(\\cdot)``, that
is, a sum of [`PureQuadraticDynamicTerm`](@ref)s.

It is a subtype of [`AbstractDynamicFunction`](@ref).
All dynamic variables must be defined on the same phase, otherwise a
[`NonUniquePhaseError`](@ref) error is thrown.
"""
struct PureQuadraticDynamicFunction{T} <: AbstractDynamicFunction
    terms::Vector{PureQuadraticDynamicTerm{T}}

    function PureQuadraticDynamicFunction(
        terms::Vector{PureQuadraticDynamicTerm{T}},
    ) where {T}
        if !all(term -> phase_index(term.dyn_var_1) == phase_index(terms[1].dyn_var_1), terms)
            throw(NonUniquePhaseError(""))
        end
        return new{T}(terms)
    end
end

function Base.show(io::IO, mime::MIME"text/plain", quad_dyn_fun::PureQuadraticDynamicFunction)

    output = String(quad_dyn_fun.terms[1].coefficient) * " "
    io_buffer = IOBuffer()
    show(io_buffer, mime, quad_dyn_fun.terms[1].dyn_var_1)
    output *= String(take!(io_buffer)) * " "
    show(io_buffer, mime, quad_dyn_fun.terms[1].dyn_var_2)
    output *= String(take!(io_buffer))

    for term in quad_dyn_fun.terms[2:end]
        output *= " + " * String(term.coefficient) * " "
        show(io_buffer, mime, term.dyn_var_1)
        output *= String(take!(io_buffer)) * " "
        show(io_buffer, mime, term.dyn_var_2)
        output *= String(take!(io_buffer))
    end

    return print(io, output)
end

## Nonlinear

"""
    NonlinearDynamicFunction(head::Symbol, args::Vector{Any}, phase::PhaseIndex)

Represent a general dynamic function
``d(\\dot{\\boldsymbol{y}}(t^{(i)}), \\boldsymbol{y}(t^{(i)}), t^{(i)}, x)``.

It is a subtype of [`AbstractDynamicFunction`](@ref).
All dynamic variables must be defined on the same phase, otherwise a
[`NonUniquePhaseError`](@ref) error is thrown. 

Similar to
[`MOI.ScalarNonlinearFunction`](@extref MathOptInterface.ScalarNonlinearFunction),
this function is represented by an expression tree, using the following fields:

### `head`

The symbol `head` must be an operator that is supported by the model. The 
model attribute
[`MOI.ListOfSupportedNonlinearOperators`](@extref MathOptInterface.ListOfSupportedNonlinearOperators)
provides a list of supported operators. If the optimizer does not support `head`,
an [`MOI.UnsupportedNonlinearOperator`](@extref MathOptInterface.UnsupportedNonlinearOperator)
error is thrown.

### `args`

The vector `args` contains the arguments to the nonlinear operator. The arguments must be
subtypes of:
* `Real`
* [`MOI.AbstractScalarFunction`](@extref MathOptInterface.AbstractScalarFunction)
* [`AbstractDynamicFunction`](@ref), including other [`NonlinearDynamicFunction`](@ref)s

Additionally, the optimizer must indicate support of argument types through the 
[`supports_objective_argument`](@ref) and [`supports_constraint_argument`](@ref)
functions. Otherwise [`UnsupportedObjectiveArgument`](@ref) and
[`UnsupportedConstraintArgument`](@ref) errors are thrown. 
"""
struct NonlinearDynamicFunction <: AbstractDynamicFunction
    head::Symbol
    args::Vector{Any}
    phase::PhaseIndex
end

phase_index(ndf::NonlinearDynamicFunction) = ndf.phase