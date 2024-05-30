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
    domain::DomainIndex
    head::Symbol
    args::Vector{Any}

    #=function NonlinearAlgebraicFunction(head::Symbol, args::AbstractVector)

        # Check that all dynamic functions share the same domain index

        return new(head, convert(Vector{Any}, args))
    end=#
end