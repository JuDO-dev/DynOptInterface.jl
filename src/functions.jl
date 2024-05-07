"""
    ScalarNonlinearDOFunction(head::Sumbol, args::Vector{Any})

A scalar-valued nonlinear DO function `head(args...)`. Each argument must be one of the following:

* A constant value of type `T<:Real`
* An `MOI.VariableIndex`
* An `MOI.ScalarNonlinearFunction`
* A [`DomainIndex`](@ref)
* An [`AlgebraicIndex`](@ref)
* A [`DifferentiableIndex`](@ref)
"""
struct ScalarNonlinearDOFunction
    head::Symbol
    args::Vector{Any}
end