"""
    LinearDynamicTerm{T}

```math
t_i \\mapsto c_j y_j(t_i)
```
"""
struct LinearDynamicTerm{T}
    coefficient::T
    y_j::DynamicVariableIndex
end

"""
    LinearDynamicFunction{T} <: AbstractDynamicFunction

```math
t_i \\mapsto c^\\top y(t_i)
```
"""
struct LinearDynamicFunction{T} <: AbstractDynamicFunction
    terms::Vector{LinearDynamicTerm{T}}
end

"""
    SquaredDynamicTerm{T}

```math
t_i \\mapsto y_j(t_i) c_{jk} y_k(t_i)
```
"""
struct SquaredDynamicTerm{T}
    coefficient::T
    y_j::DynamicVariableIndex
    y_k::DynamicVariableIndex
end

"""
    SquaredDynamicFunction{T} <: AbstractDynamicFunction

```math
t_i \\mapsto y(t_i)^\\top C y(t_i)
```
"""
struct SquaredDynamicFunction{T} <: AbstractDynamicFunction
    terms::Vector{SquaredDynamicTerm{T}}
end

"""
    struct NonlinearDynamicFunction <: AbstractDynamicFunction
        head::Symbol
        args::Vector{Any}
    ...
    end

```math
t_i \\mapsto f_d(\\dot{y}(t_i), y(t_i), t_i, x)
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
* A [`PhaseIndex`](@ref) ``t_i``
* A [`DynamicVariableIndex`](@ref) ``y_j(t_i)``
* A [`LinearDynamicFunction`](@ref) ``c^\\top y(t_i)``
* A [`SquaredDynamicFunction`](@ref) ``y(t_i)^\\top C y(t_i)``
* Another [`NonlinearDynamicFunction`](@ref)
Additionally, the optimizer must indicate support of argument types through the 
[`supports_objective_argument`](@ref) and [`supports_constraint_argument`](@ref)
functions.
"""
struct NonlinearDynamicFunction <: AbstractDynamicFunction
    head::Symbol
    args::Vector{Any}

    #=function NonlinearDynamicFunction(head::Symbol, args::AbstractVector)
        for arg in args
            if arg isa Real || arg isa MOI.VariableIndex
                continue
            elseif arg isa PhaseIndex
                arg.value == t_i.value ? continue : error("Different phases not allowed.")

            elseif arg isa DynamicVariableIndex || arg isa NonlinearDynamicFunction
                arg.t_i.value == t_i.value ? continue : error("Different phases not allowed.")

            else
                error("Unsupported object: $arg")
            end
        end
        return new(head, convert(Vector{Any}, args), t_i)
    end=#
end

function _nonlinear_to_string(options::MOI.Utilities._PrintOptions, model::MOI.ModelLike,
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

function MOI.Utilities._to_string(options::MOI.Utilities._PrintOptions, model::MOI.ModelLike,
    naf::NonlinearDynamicFunction,
)
    return _nonlinear_to_string(options, model, naf)
end

"""
    ExplicitDifferentialFunction{AF<:AbstractDynamicFunction} <: AbstractDynamicFunction

```math
t_i \\mapsto \\dot{y}(t_i) - a(y(t_i), t_i, x)
```
"""
struct ExplicitDifferentialFunction{AF<:AbstractDynamicFunction} <: AbstractDynamicFunction
    derivative::DynamicVariableDerivative
    Dynamic_function::AF
end

function MOI.Utilities._to_string(options::MOI.Utilities._PrintOptions, model::MOI.ModelLike,
    edf::ExplicitDifferentialFunction,
)
    return string(
        MOI.Utilities._to_string(options, model, edf.derivative),
        " - (",
        MOI.Utilities._to_string(options, model, edf.Dynamic_function),
        ")",
    )
end