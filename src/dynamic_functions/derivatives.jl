"""
    Derivative{DF}(dyn_fun::DF) where DF<:AbstractDynamicFunction

Represent the derivative of a dynamic function with respect to its phase.

It is a subtype of [`AbstractDynamicFunction`](@ref).
"""
struct Derivative{DF<:AbstractDynamicFunction} <: AbstractDynamicFunction
    dyn_fun::DF
end

function Base.show(io::IO, mime::MIME"text/plain", derivative::Derivative)
    io_buffer = IOBuffer()
    show(io_buffer, mime, derivative.dyn_fun)
    output = String(take!(io_buffer))
    return print(io, "DOI.Derivative($(output))")
end

phase_index(derivative::Derivative) = phase_index(derivative.dyn_fun)

"""
    ExplicitDifferentialFunction{DF}(
        dyn_var::DynamicVariableIndex,
        dyn_fun::DF,
    ) where DF<:AbstractDynamicFunction

Represent the expression
``\\dot{\\boldsymbol{y}}_j(t^{(i)}) - d(\\boldsymbol{y}(t^{(i)}), t^{(i)}, x)``.

It is a subtype of [`AbstractDynamicFunction`](@ref).
Both terms must be defined in the same phase, otherwise a [`NonUniquePhaseError`](@ref) is
thrown.
"""
struct ExplicitDifferentialFunction{DF<:AbstractDynamicFunction} <: AbstractDynamicFunction
    dyn_var::DynamicVariableIndex
    dyn_fun::DF

    function ExplicitDifferentialFunction(
        dyn_var::DynamicVariableIndex,
        dyn_fun::DF,
    ) where {DF<:AbstractDynamicFunction}
        if phase_index(dyn_var) != phase_index(dyn_fun)
            throw(NonUniquePhaseError(""))
        end
        return new{DF}(dyn_var, dyn_fun)
    end
end

function Base.show(io::IO, mime::MIME"text/plain", edf::ExplicitDifferentialFunction)
    io_buffer = IOBuffer()
    show(io_buffer, mime, Derivative(edf.dyn_var))
    output = String(take!(io_buffer))

    show(io_buffer, mime, edf.dyn_fun)
    output *= " - (" * String(take!(io_buffer)) * ")"

    return print(io, output)
end

phase_index(edf::ExplicitDifferentialFunction) = phase_index(edf.dyn_var)