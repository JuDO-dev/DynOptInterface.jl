import MathOptInterface.Utilities._to_string
import MathOptInterface.Utilities._PrintOptions

function _to_string(::_PrintOptions, ::MOI.ModelLike, t_i::DomainIndex)
    return string("t[", t_i.value, "]")
end

function _to_string(::_PrintOptions, ::MOI.ModelLike, y_j::DynamicVariableIndex)
    return string("y[", y_j.value, "]")
end

function _to_string(::_PrintOptions, ::MOI.ModelLike, ẏ_j::DynamicVariableDerivative)
    return string("ẏ[", ẏ_j.variable_index.value, "]")
end

function _to_string(::_PrintOptions, ::MOI.ModelLike, t_i_0::DomainInitial)
    return string("t[", t_i.value, "]_0")
end

function _to_string(::_PrintOptions, ::MOI.ModelLike, t_i_f::DomainFinal)
    return string("t[", t_i.value, "]_f")
end

function _to_string(::_PrintOptions, ::MOI.ModelLike, y_j_0::DynamicVariableInitial)
    return string("y[", y_j.variable_index.value, "]_0")
end

function _to_string(::_PrintOptions, ::MOI.ModelLike, y_j_f::DynamicVariableFinal)
    return string("y[", y_j.variable_index.value, "]_f")
end

const _NONLINEAR_FUNCTION = Union{
    NonlinearAlgebraicFunction,
    NonlinearDifferentialFunction,
    NonlinearBoundaryFunction,
}

function _to_string(options::_PrintOptions, model::MOI.ModelLike, nlf::_NONLINEAR_FUNCTION)
    io, stack, is_open = IOBuffer(), Any[nlf], true
    while !isempty(stack)
        arg = pop!(stack)
        if !is_open && arg != ')'
            print(io, ", ")
        end
        if arg isa _NONLINEAR_FUNCTION
            print(io, arg.head, "(")
            push!(stack, ')')
            for i in length(arg.args):-1:1
                push!(stack, arg.args[i])
            end
        elseif arg isa Char
            print(io, arg)
        else
            print(io, _to_string(options, model, arg))
        end
        is_open = arg isa _NONLINEAR_FUNCTION
    end
    seekstart(io)
    return read(io, String)
end

function _to_string(options::_PrintOptions, model::MOI.ModelLike, edf::ExplicitDifferentialFunction)
    return string(
        _to_string(options, model, edf.derivative),
        " - (",
        _to_string(options, model, edf.algebraic_function),
        ")",
    )
end

function _to_string(options::_PrintOptions, model::MOI.ModelLike, integral::IntegralFunction)
    return string(
        "∫ (",
        _to_string(options, model, integral.integrand),
        ") d",
        _to_string(options, model, integral.domain_index),
    )
end

function _to_string(options::_PrintOptions, model::MOI.ModelLike, bolza::BolzaFunction)
    return string(
        _to_string(options, model, bolza.boundary),
        " + ",
        _to_string(options, model, bolza.integrand),
    )
end