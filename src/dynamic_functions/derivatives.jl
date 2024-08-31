"""
    Derivative{DF}(dyn_fun::DF) where DF<:AbstractDynamicFunction

A wrapper for an [`AbstractDynamicFunction`](@ref) for use in referencing its derivative
in a model.

It is a sub-type of [`AbstractDynamicFunction`](@ref). It represents the derivative of 
`dyn_fun` with respect to its phase.
"""
struct Derivative{DF<:AbstractDynamicFunction} <: AbstractDynamicFunction
    dyn_fun::DF
end

function MOI.Utilities._to_string(
    ::MOI.Utilities._PrintOptions,
    ::MOI.ModelLike,
    derivative::Derivative,
)
    return string("Derivative(", derivative.dyn_fun, ")")
end

function phase_index(derivative::Derivative)
    return phase_index(derivative.dyn_fun)
end

"""
    ExplicitDifferentialFunction{D,F}(
        derivative::Derivative{D},
        dyn_fun::F,
    ) where {D<:AbstractDynamicFunction,F<:AbstractDynamicFunction}

An object representing the function ``t_i \\mapsto \\dot{y}(t_i) - f_d(y(t_i), t_i, x)``.

It is a sub-type of [`AbstractDynamicFunction`](@ref). The derivative (stored in the `derivative`
field) and the dynamic function (stored in the `dyn_fun` field) must be defined in the same
phase, otherwise a [`MixedPhases`](@ref) error is thrown.
"""
struct ExplicitDifferentialFunction{D<:AbstractDynamicFunction,F<:AbstractDynamicFunction} <:
       AbstractDynamicFunction
    derivative::Derivative{D}
    dyn_fun::F

    function ExplicitDifferentialFunction(
        derivative::Derivative{D},
        dyn_fun::F,
    ) where {D<:AbstractDynamicFunction, F<:AbstractDynamicFunction}
        if phase_index(derivative) != phase_index(dyn_fun)
            throw(MixedPhases(""))
        end
        return new{D,F}(derivative, dyn_fun)
    end
end

function MOI.Utilities._to_string(
    options::MOI.Utilities._PrintOptions,
    model::MOI.ModelLike,
    edf::ExplicitDifferentialFunction,
)
    return string(
        MOI.Utilities._to_string(options, model, edf.derivative),
        " - (",
        MOI.Utilities._to_string(options, model, edf.dyn_fun),
        ")",
    )
end

phase_index(edf::ExplicitDifferentialFunction) = phase_index(edf.derivative)