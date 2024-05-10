"""
    NonlinearAlgebraicFunction <: AbstractAlgebraicFunction

```math
f(y(\\cdot), u(\\cdot), t, x)
```
Supports:
* [`DifferentialVariableIndex`](@ref)
* [`AlgebraicVariableIndex`](@ref)
* [`DomainIndex`](@ref)
* [`NonlinearAlgebraicFunction`](@ref)
* `MOI.ScalarNonlinearFunction`
"""
struct NonlinearAlgebraicFunction <: AbstractAlgebraicFunction
    head::Symbol
    args::Vector{Any}
end