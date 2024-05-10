"""
    IntegralFunction{F<:AbstractAlgebraicFunction} <: AbstractDynamicFunction

``\\int_{t_o}^{t_f} \\ell(y(t), u(t), t, x) \\mathrm{d}t``
Represents the integral of an [`AbstractAlgebraicFunction`](@ref) over its domain.
"""
struct IntegralFunction{AF<:AbstractAlgebraicFunction} <: AbstractDynamicFunction
    integrand::AF
end

"""
    BolzaFunction{BF<:AbstractBoundaryFunction,AF<:AbstractAlgebraicFunction} <: AbstractDynamicFunction

``b(y_0, y_f, t_0, t_f, x) + \\int_{t_0}^{t_f} \\ell(y(t), u(t), t, x) \\mathrm{d}t``
Represents the sum of an [`AbstractBoundaryFunction`](@ref) with the integral of
an [`AbstractAlgebraicFunction`](@ref). The functions must have the same [`DomainIndex`](@ref).
"""
struct BolzaFunction{BF<:AbstractBoundaryFunction,AF<:AbstractAlgebraicFunction} <: AbstractDynamicFunction
    boundary::BF
    integrand::AF
    # Inner constructor to check same index
end

# Multi-Phase solvers may support: Vector{NonlinearBolzaFunction}