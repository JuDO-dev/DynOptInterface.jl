## Types

"""
    LinearAlgebraicTerm{T}

```math
t_i \\mapsto c_j y_j(t_i)
```
"""
struct LinearAlgebraicTerm{T}
    coefficient::T
    y_j::DynamicVariableIndex
end

"""
    LinearAlgebraicFunction{T} <: AbstractAlgebraicFunction

```math
t_i \\mapsto c^\\top y(t_i)
```
"""
struct LinearAlgebraicFunction{T} <: AbstractAlgebraicFunction
    terms::Vector{LinearAlgebraicTerm{T}}
end

"""
    SquaredAlgebraicTerm{T}

```math
t_i \\mapsto y_j(t_i) c_{jk} y_k(t_i)
```
"""
struct SquaredAlgebraicTerm{T}
    coefficient::T
    y_j::DynamicVariableIndex
    y_k::DynamicVariableIndex
end

"""
    SquaredAlgebraicFunction{T}

```math
t_i \\mapsto y(t_i)^\\top C y(t_i)
```
"""
struct SquaredAlgebraicFunction{T}
    terms::Vector{SquaredAlgebraicTerm{T}}
end

"""
    NonlinearAlgebraicFunction <: AbstractAlgebraicFunction

```math
t_i \\mapsto f_a(y(t_i), t_i, x)
```
Similar to [`MathOptInterface.ScalarNonlinearFunction`](@ref), an expression
tree is used to represent nonlinear functions.

```julia
struct NonlinearAlgebraicFunction <: AbstractAlgebraicFunction
    head::Symbol
    args::Vector{Any}
    t_i::DomainIndex
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
* A [`DomainIndex`](@ref) ``t_i``
* A [`DynamicVariableIndex`](@ref) ``y_j(t_i)``
* A [`LinearAlgebraicFunction`](@ref) ``c^\\top y(t_i)``
* A [`SquaredAlgebraicFunction`](@ref) ``y(t_i)^\\top C y(t_i)``
* Another [`NonlinearAlgebraicFunction`](@ref)

### `t_i`

As expressions are composed, dynamic functions must have the same [`DomainIndex`](@ref)
`t_i`.
"""
struct NonlinearAlgebraicFunction <: AbstractAlgebraicFunction
    head::Symbol
    args::Vector{Any}
    t_i::DomainIndex

    function NonlinearAlgebraicFunction(head::Symbol, args::AbstractVector, t_i::DomainIndex)
        for arg in args
            if arg isa Real || arg isa MOI.VariableIndex
                continue
            elseif arg isa DomainIndex
                arg.value == t_i.value ? continue : error("Different domains not allowed.")

            elseif arg isa DynamicVariableIndex || arg isa NonlinearAlgebraicFunction
                arg.t_i.value == t_i.value ? continue : error("Different domains not allowed.")

            else
                error("Unsupported object: $arg")
            end
        end
        return new(head, convert(Vector{Any}, args), t_i)
    end
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
    naf::NonlinearAlgebraicFunction,
)
    return _nonlinear_to_string(options, model, naf)
end