"""
    IntegralFunction{AF<:AbstractAlgebraicFunction} <: AbstractDynamicFunction

```math
\\int_{t_i^o}^{t_i^f} a(y(t_i), t_i, x) \\mathrm{d}t_i
```
Represents the integral of an [`AbstractAlgebraicFunction`](@ref) over its domain.
"""
struct IntegralFunction{AF<:AbstractAlgebraicFunction} <: AbstractDynamicFunction
    integrand::AF
    t_i::DomainIndex
end

function MOI.Utilities._to_string(options::MOI.Utilities._PrintOptions, model::MOI.ModelLike,
    integral::IntegralFunction,
)
    return string(
        "∫(",
        MOI.Utilities._to_string(options, model, integral.integrand),
        ") d",
        MOI.Utilities._to_string(options, model, integral.t_i),
    )
end

"""
    BolzaFunction{BF<:AbstractBoundaryFunction, AF<:AbstractAlgebraicFunction} <: AbstractDynamicFunction

```math
b(y_0, y_f, t_0, t_f, x) + \\int_{t_i^o}^{t_i^f} a(y(t_i), t_i, x) \\mathrm{d}t_i
```
Represents the sum of an [`AbstractBoundaryFunction`](@ref) with the integral of
an [`AbstractAlgebraicFunction`](@ref). The functions must have the same [`DomainIndex`](@ref).
"""
struct BolzaFunction{BF<:AbstractBoundaryFunction, AF<:AbstractAlgebraicFunction} <: AbstractDynamicFunction
    boundary::BF
    integrand::AF
    # Inner constructor to check same index
end

function MOI.Utilities._to_string(options::MOI.Utilities._PrintOptions, model::MOI.ModelLike,
    bolza::BolzaFunction,
)
    return string(
        MOI.Utilities._to_string(options, model, bolza.boundary),
        " + ",
        MOI.Utilities._to_string(options, model, bolza.integrand),
    )
end