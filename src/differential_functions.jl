"""
    DynamicVariableDerivative <: AbstractDifferentialFunction

```math
t_i \\mapsto \\dot{y}_j(t_i)
```
A derivative
"""
struct DynamicVariableDerivative <: AbstractDifferentialFunction
    variable_index::DynamicVariableIndex
end

"""
    ExplicitDifferentialFunction{AF<:AbstractAlgebraicFunction} <: AbstractDifferentialFunction

```math
t_i \\mapsto \\dot{y}(t_i) - a(y(t_i), t_i, x)
```
"""
struct ExplicitDifferentialFunction{AF<:AbstractAlgebraicFunction} <: AbstractDifferentialFunction
    derivative::DynamicVariableDerivative
    algebraic_function::AF
end

"""
    NonlinearDifferentialFunction <: AbstractDifferentialFunction

```math
t_i \\mapsto r(\\dot{y}(t_i), y(t_i), t_i, x)
```
Similar to `MOI.ScalarNonlinearFunction`, 

Each node in `args` can be one of the following:
* A constant value of type `T<:Real`
* An `MOI.VariableIndex`
* A [`DomainIndex`](@ref)
* A [`DynamicVariableIndex`](@ref)
* A [`DynamicVariableDerivative`](@ref)
* Another [`NonlinearDifferentialFunction`](@ref)
"""
struct NonlinearDifferentialFunction <: AbstractDifferentialFunction
    domain::DomainIndex
    head::Symbol
    args::Vector{Any}
    # Inner constructor to enforce rules
end