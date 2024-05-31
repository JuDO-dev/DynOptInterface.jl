"""
    NonlinearAlgebraicFunction <: AbstractAlgebraicFunction

```math
t_i \\mapsto a(y(t_i), t_i, x)
```
Similar to [`MathOptInterface.ScalarNonlinearFunction`](@ref), 

Each node in `args` can be one of the following:
* A constant value of type `T<:Real`
* A [`MathOptInterface.VariableIndex`](@extref)
* A [`DomainIndex`](@ref)
* A [`DynamicVariableIndex`](@ref)
* Another [`NonlinearAlgebraicFunction`](@ref)
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