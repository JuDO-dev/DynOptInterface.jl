"""
    IntegralFunction{DF<:AbstractDynamicFunction} <: MOI.AbstractScalarFunction

```math
\\int_{t_i^o}^{t_i^f} d(\\dot{y}(t_i), y(t_i), t_i, x) \\mathrm{d}t_i
```
Represents the integral of an [`AbstractDynamicFunction`](@ref) over its phase.
"""
struct IntegralFunction{DF<:AbstractDynamicFunction} <: MOI.AbstractScalarFunction
    integrand::DF
    t_i::PhaseIndex
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
    BolzaFunction{BF<:AbstractBoundaryFunction, AF<:AbstractDynamicFunction} <: MOI.AbstractScalarFunction

```math
b(y_0, y_f, t_0, t_f, x) + \\int_{t_i^o}^{t_i^f} d(\\dot{y}(t_i), y(t_i), t_i, x) \\mathrm{d}t_i
```
Represents the sum of an [`AbstractBoundaryFunction`](@ref) with the integral of
an [`AbstractDynamicFunction`](@ref). The functions must have the same [`PhaseIndex`](@ref).
"""
struct BolzaFunction{BF<:AbstractBoundaryFunction, AF<:AbstractDynamicFunction} <: MOI.AbstractScalarFunction
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