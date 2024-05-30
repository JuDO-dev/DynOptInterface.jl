"""
    DomainInitial <: AbstractBoundaryFunction

```math
t_i^0
```
Represents the initial point of a [`DomainIndex`](@ref).
"""
struct DomainInitial <: AbstractBoundaryFunction
    index::DomainIndex
end

"""
    DomainFinal <: AbstractBoundaryFunction

```math
t_i^f
```
Represents the final point of a [`DomainIndex`](@ref).
"""
struct DomainFinal <: AbstractBoundaryFunction
    index::DomainIndex
end

"""
    DynamicVariableInitial <: AbstractBoundaryFunction

```math
y_j(t_i^0)
```    
Represents a [`DynamicVariableIndex`](@ref) evaluated at the initial point of its [`DomainIndex`](@ref)
"""
struct DynamicVariableInitial <: AbstractBoundaryFunction
    variable_index::DynamicVariableIndex
end

"""
    DynamicVariableFinal <: AbstractBoundaryFunction

```math
y_j(t_i^f)
```
Represents a [`DynamicVariableIndex`](@ref) evaluated at the final point of its [`DomainIndex`](@ref)
"""
struct DynamicVariableFinal <: AbstractBoundaryFunction
    variable_index::DynamicVariableIndex
end

"""
    NonlinearBoundaryFunction <: AbstractBoundaryFunction
    
```math
b(y_j(t^0), y_j(t^f), t^0, t^f, x)
```
Similar to [`MathOptInterface.ScalarNonlinearFunction`](@extref), 

Each node in `args` can be one of the following:
* A constant value of type `T<:Real`
* A [`MathOptInterface.VariableIndex`](@extref)
* A [`DomainInitial`](@ref)
* A [`DomainFinal`](@ref)
* A [`DynamicVariableInitial`](@ref)
* A [`DynamicVariableFinal`](@ref)
* Another [`NonlinearBoundaryFunction`](@ref)
"""
struct NonlinearBoundaryFunction <: AbstractBoundaryFunction
    head::Symbol
    args::Vector{Any}
    # Inner constructor to enforce rules
end