## Linear

"""
    LinearDynamicTerm{T}(coefficient::T, dyn_var::DynamicVariableIndex) where {T}

Represents the term ``c_j y_j``, where ``c_j`` is a coefficient and ``y_j`` is a
[`DynamicVariableIndex`](@ref).

The coefficient is stored in the `coefficient` field and the [`DynamicVariableIndex`](@ref)
is stored in the `dyn_var` field.
"""
struct LinearDynamicTerm{T}
    coefficient::T
    dyn_var::DynamicVariableIndex
end

function MOI.Utilities._to_string(
    options::MOI.Utilities._PrintOptions,
    model::MOI.ModelLike,
    linear_term::LinearDynamicTerm;
    is_first::Bool,
)
    dyn_var_string =
        MOI.Utilities._to_string(options, model, linear_term.dyn_var)
    return MOI.Utilities._to_string(
        options,
        linear_term.coefficient,
        dyn_var_string;
        is_first = is_first,
    )
end

phase_index(linear_term::LinearDynamicTerm) = phase_index(linear_term.dyn_var)

"""
    LinearDynamicFunction{T}(terms::Vector{LinearDynamicTerm{T}}) where {T}

Represents the function ``t_i \\mapsto c^\\top y(t_i)``, which is a sum of
[`LinearDynamicTerm`](@ref)s.

A sub-type of [`AbstractDynamicFunction`](@ref). All dynamic variables must be defined
on the same phase, otherwise a [`MixedPhases`](@ref) error is thrown. The
[`LinearDynamicTerm`](@ref)s are stored in the `terms` field.
"""
struct LinearDynamicFunction{T} <: AbstractDynamicFunction
    terms::Vector{LinearDynamicTerm{T}}

    function LinearDynamicFunction(
        terms::Vector{LinearDynamicTerm{T}},
    ) where {T}
        if !all(term -> phase_index(term) == phase_index(first(terms)), terms)
            throw(MixedPhases(""))
        end
        return new{T}(terms)
    end
end

function MOI.Utilities._to_string(
    options::MOI.Utilities._PrintOptions,
    model::MOI.ModelLike,
    linear::LinearDynamicFunction,
)
    s = ""
    is_first = true
    for term in linear.terms
        s *= MOI.Utilities._to_string(options, model, term; is_first = is_first)
        is_first = false
    end
    return s
end

## Squared

"""
    SquaredDynamicTerm{T}(
        coefficient::T
        dyn_var_a::DynamicVariableIndex
        dyn_var_b::DynamicVariableIndex
    ) where {T}

Represents the term ``c_{ab} y_a y_b``, where ``c_{ab}`` is a coefficient and ``y_a, y_b``
are [`DynamicVariableIndex`](@ref)s.

The coefficient is stored in the `coefficient` field. The dynamic variables are stored in
the `dyn_var_a` and `dyn_var_b` fields and must be defined on the same phase, otherwise
a [`MixedPhases`](@ref) error is thrown.
"""
struct SquaredDynamicTerm{T}
    coefficient::T
    dyn_var_a::DynamicVariableIndex
    dyn_var_b::DynamicVariableIndex

    function SquaredDynamicTerm(
        coefficient::T,
        dyn_var_a::DynamicVariableIndex,
        dyn_var_b::DynamicVariableIndex,
    ) where {T}
        if phase_index(dyn_var_a) != phase_index(dyn_var_b)
            throw(MixedPhases)
        end
        return new{T}(coefficient, dyn_var_a, dyn_var_b)
    end
end

function MOI.Utilities._to_string(
    options::MOI.Utilities._PrintOptions,
    model::MOI.ModelLike,
    squared_term::SquaredDynamicTerm;
    is_first::Bool,
)
    dyn_var_a_string =
        MOI.Utilities._to_string(options, model, squared_term.dyn_var_a)
    dyn_var_b_string =
        MOI.Utilities._to_string(options, model, squared_term.dyn_var_b)
    return MOI.Utilities._to_string(
        options,
        squared_term.coefficient,
        string(dyn_var_a_string, " ", dyn_var_b_string);
        is_first = is_first,
    )
end

function phase_index(squared_term::SquaredDynamicTerm)
    return phase_index(squared_term.dyn_var_a)
end

"""
    SquaredDynamicFunction{T}(terms::Vector{SquaredDynamicTerm{T}}) where {T}

Represents the function ``t_i \\mapsto y(t_i)^\\top C y(t_i)``, which is a sum of
[`SquaredDynamicTerm`](@ref)s.

A sub-type of [`AbstractDynamicFunction`](@ref). All dynamic variables must be defined
on the same phase, otherwise a [`MixedPhases`](@ref) error is thrown. The
[`SquaredDynamicTerm`](@ref)s are stored in the `terms` field.
"""
struct SquaredDynamicFunction{T} <: AbstractDynamicFunction
    terms::Vector{SquaredDynamicTerm{T}}

    function SquaredDynamicFunction(
        terms::Vector{SquaredDynamicTerm{T}},
    ) where {T}
        if !all(term -> phase_index(term) == phase_index(first(terms)), terms)
            throw(MixedPhases(""))
        end
        return new{T}(terms)
    end
end

function MOI.Utilities._to_string(
    options::MOI.Utilities._PrintOptions,
    model::MOI.ModelLike,
    squared::SquaredDynamicFunction,
)
    s = ""
    is_first = true
    for term in squared.terms
        s *= MOI.Utilities._to_string(options, model, term; is_first = is_first)
        is_first = false
    end
    return s
end

## Nonlinear

"""
    NonlinearDynamicFunction(head::Symbol, args::Vector{Any}, phase::PhaseIndex)

Represents a general function ``t_i \\mapsto f_d(\\dot{y}(t_i), y(t_i), t_i, x)``.

A sub-type of [`AbstractDynamicFunction`](@ref). All dynamic variables must be defined
on the same phase, otherwise a [`MixedPhases`](@ref) error is thrown. Similar to
[`MOI.ScalarNonlinearFunction`](@extref MathOptInterface.ScalarNonlinearFunction),
nonlinear dynamic functions are represented by expression trees, using the following
fields:

### `head`

The symbol `head` must be an operator that is supported by the model. The 
model attribute
[`MOI.ListOfSupportedNonlinearOperators`](@extref MathOptInterface.ListOfSupportedNonlinearOperators)
provides a list of supported operators. If the optimizer does not support `head`,
an [`MOI.UnsupportedNonlinearOperator`](@extref MathOptInterface.UnsupportedNonlinearOperator)
error is thrown.

### `args`

The vector `args` contains the arguments to the nonlinear operator. The possible
arguments that may be included are:
* A constant value of type `T<:Real`
* An [`MOI.VariableIndex`](@extref MathOptInterface.VariableIndex) ``x_k``
* An [`MOI.ScalarAffineFunction`](@extref MathOptInterface.ScalarAffineFunction) ``a^\\top x + b``
* An [`MOI.ScalarQuadraticFunction`](@extref MathOptInterface.ScalarQuadraticFunction) ``x^\\top Q x + a^\\top x + b``
* An [`MOI.ScalarNonlinearFunction`](@extref MathOptInterface.ScalarNonlinearFunction) ``f(x)``
* A [`PhaseIndex`](@ref) ``t_i``
* A [`DynamicVariableIndex`](@ref) ``y_j(t_i)``
* A [`LinearDynamicFunction`](@ref) ``c^\\top y(t_i)``
* A [`SquaredDynamicFunction`](@ref) ``y(t_i)^\\top C y(t_i)``
* Another [`NonlinearDynamicFunction`](@ref)s
Additionally, the optimizer must indicate support of argument types through the 
[`supports_objective_argument`](@ref) and [`supports_constraint_argument`](@ref)
functions.
"""
struct NonlinearDynamicFunction <: AbstractDynamicFunction
    head::Symbol
    args::Vector{Any}
    phase::PhaseIndex
end

function _nonlinear_to_string(
    options::MOI.Utilities._PrintOptions,
    model::MOI.ModelLike,
    nlf::NLF,
) where {NLF}
    io, stack, is_open = IOBuffer(), Any[nlf], true
    while !isempty(stack)
        arg = pop!(stack)
        if !is_open && arg != ')'
            print(io, ", ")
        end
        if arg isa NLF
            print(io, arg.head, "(")
            push!(stack, ')')
            for i in length(arg.args):-1:1
                push!(stack, arg.args[i])
            end
        elseif arg isa Char
            print(io, arg)
        else
            print(io, MOI.Utilities._to_string(options, model, arg))
        end
        is_open = arg isa NLF
    end
    seekstart(io)
    return read(io, String)
end

function MOI.Utilities._to_string(
    options::MOI.Utilities._PrintOptions,
    model::MOI.ModelLike,
    f_d::NonlinearDynamicFunction,
)
    return _nonlinear_to_string(options, model, f_d)
end

phase_index(ndf::NonlinearDynamicFunction) = ndf.phase