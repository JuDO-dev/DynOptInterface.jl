abstract type AbstractDynamicVariableAttribute end

struct PhasePrimal <: AbstractDynamicVariableAttribute end

function MOI.get_fallback(
    model::MOI.ModelLike,
    attr::PhasePrimal,
    ::PhaseIndex,
)
    return throw(
        MOI.GetAttributeNotAllowed(
            attr,
            "$(typeof(model)) does not support getting the attribute $(attr)"
        )
    )
end

struct DynamicVariablePrimal <: AbstractDynamicVariableAttribute end

function MOI.get_fallback(
    model::MOI.ModelLike, 
    attr::DynamicVariablePrimal,
    ::DynamicVariableIndex,
    ::Real
)
    return throw(
        MOI.GetAttributeNotAllowed(
            attr,
            "$(typeof(model)) does not support getting the attribute $(attr)"))
end


struct DifferentialVariablePrimal <: AbstractDynamicVariableAttribute end

function MOI.get_fallback()

end