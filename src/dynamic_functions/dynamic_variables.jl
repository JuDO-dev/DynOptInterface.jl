"""
    DynamicVariableIndex(value::Int64, phase::PhaseIndex)

Represent the dynamic variable ``\\boldsymbol{y}_j(\\cdot)`` in an expression.

It is a subtype of [`AbstractDynamicFunction`](@ref).
To allow for deletion, indices need not be consecutive.
"""
struct DynamicVariableIndex <: AbstractDynamicFunction
    value::Int64
    phase::PhaseIndex
end

function Base.show(io::IO, ::MIME"text/plain", dyn_var::DynamicVariableIndex)
    return print(io, "DOI.DynamicVariableIndex($(dyn_var.value))")
end

phase_index(dyn_var::DynamicVariableIndex) = dyn_var.phase

## Dynamic Variables in Models

"""
    supports_dynamic_variables(model::MOI.ModelLike)::Bool

Indicate whether `model` supports dynamic variables.
"""
supports_dynamic_variables(::MOI.ModelLike) = false

"""
    UnsupportedDynamicVariablesError(message::String)

The model does not support dynamic variables.

That is, [`supports_dynamic_variables`](@ref) returns `false`.
"""
struct UnsupportedDynamicVariablesError <: MOI.UnsupportedError
    message::String
end

"""
    add_dynamic_variable(model::MOI.ModelLike, phase::PhaseIndex)::DynamicVariableIndex

Add a dynamic variable to `model`, returning a [`DynamicVariableIndex`](@ref).

An [`AddDynamicVariableNotAllowedError`](@ref) is thrown if a dynamic variable cannot be
added to `model` in its current state.
"""
function add_dynamic_variable(::MOI.ModelLike, ::PhaseIndex)
    return throw(AddDynamicVariableNotAllowedError(""))
end

"""
    AddDynamicVariableNotAllowedError(message::String)

Dynamic variables cannot be added to the model in its current state.
"""
struct AddDynamicVariableNotAllowedError <: MOI.NotAllowedError
    message::String
end

MOI.operation_name(::AddDynamicVariableNotAllowedError) = "Adding a dynamic variable"

"""
    MOI.is_valid(model::MOI.ModelLike, dyn_var::DynamicVariableIndex)::Bool

Indicate whether `dyn_var` refers to a valid [`DynamicVariableIndex`](@ref) in `model`.
"""
MOI.is_valid(::MOI.ModelLike, ::DynamicVariableIndex) = false

"""
    InvalidDynamicVariableError(dyn_var::DynamicVariableIndex)

The dynamic variable `dyn_var` is not valid in the model.
"""
struct InvalidDynamicVariableError <: Exception
    dyn_var::DynamicVariableIndex
end

## Dynamic Variable Attributes

"""
    AbstractDynamicVariableAttribute

Supertype for dynamic variable attributes.
"""
abstract type AbstractDynamicVariableAttribute end

"""
    MOI.supports(
        model::MOI.ModelLike,
        attr::AbstractDynamicVariableAttribute,
    )::Bool

Indicate whether `model` supports the dynamic variable attribute `attr`.
"""
function MOI.supports(::MOI.ModelLike, ::AbstractDynamicVariableAttribute)
    return false
end

"""
    MOI.set(
        model::MOI.ModelLike,
        attr::AbstractDynamicVariableAttribute,
        dyn_var::DynamicVariableIndex,
        value::Any,
    )

Assign `value` to the attribute `attr` of dynamic variable `dyn_var` in model `model`.
"""
function MOI.set(
    model::MOI.ModelLike,
    attr::AbstractDynamicVariableAttribute,
    ::DynamicVariableIndex,
    value::Any,
)
    if MOI.supports(model, attr)
        throw(ArgumentError(
            "$(typeof(model)) does not currently allow setting the attribute $(attr) to $(value)."
        ))
    else
        throw(ArgumentError(
            "$(typeof(model)) does not support attribute $(attr)."
        ))
    end
    return nothing
end

"""
    MOI.get(
        model::MOI.ModelLike,
        attr::AbstractDynamicVariableAttribute,
        dyn_var::DynamicVariableIndex,
    )

Return the value of the attribute `attr` set to dynamic variable `dyn_var` in model `model`.

If the attribute `attr` is not supported by `model` then an error should be thrown.
If the attribute is supported but has not been set, `nothing` is returned.
"""
function MOI.get(
    model::MOI.ModelLike,
    attr::AbstractDynamicVariableAttribute,
    dyn_var::DynamicVariableIndex,
)
    throw(ArgumentError(
        "$(typeof(model)) does not support getting the attribute $(attr) for $(typeof(dyn_var))."
        ))
    return nothing
end

"""
    DynamicVariableName

A dynamic variable attribute for a `String` identifying a dynamic variable.
"""
struct DynamicVariableName <: AbstractDynamicVariableAttribute end

"""
    DynamicVariableInitialStart

A dynamic variable attribute for the start value of the dynamic variable at the initial
phase boundary.
"""
struct DynamicVariableInitialStart <: AbstractDynamicVariableAttribute end

"""
    DynamicVariableFinalStart

A dynamic variable attribute for the start value of the dynamic variable at the final phase
boundary.
"""
struct DynamicVariableFinalStart <: AbstractDynamicVariableAttribute end