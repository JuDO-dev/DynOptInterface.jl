"""
    DynamicVariableDerivative(dyn_var::DynamicVariableIndex)

A wrapper for [`DynamicVariableIndex`](@ref) for use in referencing its derivative in
a model.

A sub-type of [`AbstractDynamicFunction`](@ref). Represents the derivative of 
`dyn_var` with respect to its phase, that is, ``t_i \\mapsto \\dot{y}_j(t_i)``. 
"""
struct DynamicVariableDerivative <: AbstractDynamicFunction
    dyn_var::DynamicVariableIndex
end

function MOI.Utilities._to_string(
    ::MOI.Utilities._PrintOptions,
    ::MOI.ModelLike,
    derivative::DynamicVariableDerivative,
)
    return string("ẏ[", derivative.dyn_var.value, "]")
end

function phase_index(derivative::DynamicVariableDerivative)
    return phase_index(derivative.dyn_var)
end

"""
    ExplicitDifferentialFunction{DF}(
        derivative::DynamicVariableDerivative,
        dyn_fun::DF,
    ) where {DF<:AbstractDynamicFunction}

An object representing the function ``t_i \\mapsto \\dot{y}(t_i) - f_d(y(t_i), t_i, x)``.

A sub-type of [`AbstractDynamicFunction`](@ref). The derivative (stored in the `derivative`
field) and the dynamic function (stored in the `dyn_fun` field) must be defined in the same
phase, otherwise a [`MixedPhases`](@ref) error is thrown.
"""
struct ExplicitDifferentialFunction{DF<:AbstractDynamicFunction} <:
       AbstractDynamicFunction
    derivative::DynamicVariableDerivative
    dyn_fun::DF

    function ExplicitDifferentialFunction(
        derivative::DynamicVariableDerivative,
        dyn_fun::DF,
    ) where {DF<:AbstractDynamicFunction}
        if phase_index(derivative) != phase_index(dyn_fun)
            throw(MixedPhases(""))
        end
        return new{DF}(derivative, dyn_fun)
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