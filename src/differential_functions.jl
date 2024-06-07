"""
    DynamicVariableDerivative <: AbstractDifferentialFunction

```math
t_i \\mapsto \\dot{y}_j(t_i)
```
A derivative
"""
struct DynamicVariableDerivative <: AbstractDifferentialFunction
    y_j::DynamicVariableIndex
end

function MOI.Utilities._to_string(::MOI.Utilities._PrintOptions, ::MOI.ModelLike,
    derivative::DynamicVariableDerivative,
)
    return string("ẏ[", derivative.y_j.value, "]")
end

"""
    ExplicitDifferentialFunction{AF<:AbstractAlgebraicFunction} <: AbstractDifferentialFunction

```math
t_i \\mapsto \\dot{y}(t_i) - a(y(t_i), t_i, x)
```
"""
struct ExplicitDifferentialFunction{AF<:AbstractAlgebraicFunction} <: AbstractDifferentialFunction
    derivative::DynamicVariableDerivative
    algebraic_function::AF
end

function MOI.Utilities._to_string(options::MOI.Utilities._PrintOptions, model::MOI.ModelLike,
    edf::ExplicitDifferentialFunction,
)
    return string(
        MOI.Utilities._to_string(options, model, edf.derivative),
        " - (",
        MOI.Utilities._to_string(options, model, edf.algebraic_function),
        ")",
    )
end

"""
    NonlinearDifferentialFunction <: AbstractDifferentialFunction

```math
t_i \\mapsto f_d(\\dot{y}(t_i), y(t_i), t_i, x)
```
Similar to `MOI.ScalarNonlinearFunction`, 

Each node in `args` can be one of the following:
* A constant value of type `T<:Real`
* An `MOI.VariableIndex`
* A [`DomainIndex`](@ref)
* A [`DynamicVariableIndex`](@ref)
* A [`DynamicVariableDerivative`](@ref)
* Another [`NonlinearDifferentialFunction`](@ref)
"""
struct NonlinearDifferentialFunction <: AbstractDifferentialFunction
    head::Symbol
    args::Vector{Any}
    t_i::DomainIndex

    function NonlinearDifferentialFunction(head::Symbol, args::AbstractVector, t_i::DomainIndex)
        for arg in args
            if arg isa Real || arg isa MOI.VariableIndex
                continue
            elseif arg isa DomainIndex
                arg.value == t_i.value ? continue : error("Different domains not allowed.")

            elseif arg isa DynamicVariableIndex || arg isa NonlinearDifferentialFunction
                arg.t_i.value == t_i.value ? continue : error("Different domains not allowed.")

            elseif arg isa DynamicVariableDerivative
                arg.y_j.t_i.value == t_i.value ? continue : error("Different domains not allowed.")

            else
                error("Unsupported object: $arg")
            end
        end
        return new(head, convert(Vector{Any}, args), t_i)
    end
end

function MOI.Utilities._to_string(options::MOI.Utilities._PrintOptions, model::MOI.ModelLike,
    ndf::NonlinearDifferentialFunction,
)
    return _nonlinear_to_string(options, model, ndf)
end