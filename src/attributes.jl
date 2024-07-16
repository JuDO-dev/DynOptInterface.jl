## MOI.supports

"""
    MOI.supports(
        model::MOI.ModelLike,
        attr::MOI.AbstractVariableAttribute,
        ::Type{PhaseIndex},
    )::Bool

Return a `Bool` indicating whether `model` supports the attribute `attr` for
[`PhaseIndex`](@ref)s ``t``.

```julia
    MOI.supports(
        model::MOI.ModelLike,
        attr::MOI.AbstractVariableAttribute,
        ::Type{Initial{PhaseIndex}},
    )::Bool
```

Return a `Bool` indicating whether `model` supports the attribute `attr` for
[`Initial`](@ref){[`PhaseIndex`](@ref)}s ``t^0``.

```julia
    MOI.supports(
        model::MOI.ModelLike,
        attr::MOI.AbstractVariableAttribute,
        ::Type{Final{PhaseIndex}},
    )::Bool
```

Return a `Bool` indicating whether `model` supports the attribute `attr` for
[`Final`](@ref){[`PhaseIndex`](@ref)}s ``t^f``.    

```julia
    MOI.supports(
        model::MOI.ModelLike,
        attr::MOI.AbstractVariableAttribute,
        ::Type{DynamicVariableIndex},
    )::Bool
```

Return a `Bool` indicating whether `model` supports the attribute `attr` for
[`DynamicVariableIndex`](@ref)s ``y(\\cdot)``.

```julia
    MOI.supports(
        model::MOI.ModelLike,
        attr::MOI.AbstractVariableAttribute,
        ::Type{Initial{DynamicVariableIndex}},
    )::Bool
```

Return a `Bool` indicating whether `model` supports the attribute `attr` for
[`Initial`](@ref){[`DynamicVariableIndex`](@ref)}s ``y(t^0)``.

```julia
    MOI.supports(
        model::MOI.ModelLike,
        attr::MOI.AbstractVariableAttribute,
        ::Type{Final{DynamicVariableIndex}},
    )::Bool
```

Return a `Bool` indicating whether `model` supports the attribute `attr` for
[`Final`](@ref){[`DynamicVariableIndex`](@ref)}s ``y(t^f)``.
"""
function MOI.supports(
    ::MOI.ModelLike,
    ::MOI.AbstractVariableAttribute,
    ::Union{
        Type{PhaseIndex},
        Type{DynamicVariableIndex},
        Type{Initial{PhaseIndex}},
        Type{Final{PhaseIndex}},
        Type{Initial{DynamicVariableIndex}},
        Type{Final{DynamicVariableIndex}},
    },
)
    return false
end

## MOI.set

"""
    MOI.set(
        model::MOI.ModelLike,
        attr::MOI.AbstractVariableAttribute,
        t_i::PhaseIndex,
        value,
    )

Assign `value` to the attribute `attr` of phase `t_i` in model `model`.

```julia
MOI.set(
    model::MOI.ModelLike,
    attr::MOI.AbstractVariableAttribute,
    y_j::DynamicVariableIndex,
    value,
)
```

Assign `value` to the attribute `attr` of dynamic variable `y_j` in model `model`.

```julia
MOI.set(
    model::MOI.ModelLike,
    attr::MOI.AbstractVariableAttribute,
    t_i_0::Initial{PhaseIndex},
    value,
)
```

Assign `value` to the attribute `attr` of initial phase `t_i_0` in model `model`.

```julia
MOI.set(
    model::MOI.ModelLike,
    attr::MOI.AbstractVariableAttribute,
    t_i_f::Final{PhaseIndex},
    value,
)
```

Assign `value` to the attribute `attr` of final phase `t_i_f` in model `model`.

```julia
MOI.set(
    model::MOI.ModelLike,
    attr::MOI.AbstractVariableAttribute,
    y_j_0::Initial{DynamicVariableIndex},
    value,
)
```

Assign `value` to the attribute `attr` of initial phase `y_j_0` in model `model`.

```julia
MOI.set(
    model::MOI.ModelLike,
    attr::MOI.AbstractVariableAttribute,
    y_j_f::Final{DynamicVariableIndex},
    value,
)
```

Assign `value` to the attribute `attr` of final phase `y_j_f` in model `model`.

For all of the above methods, an [`MOI.UnsupportedAttribute`](@extref MathOptInterface.UnsupportedAttribute)
error is thrown if `model` does not support the attribute `attr`, and a
[`MOI.SetAttributeNotAllowed`](@extref MathOptInterface.SetAttributeNotAllowed) error is thrown if it supports
the attribute `attr` but it cannot be set.
"""
function MOI.set(
    model::MOI.ModelLike,
    attr::MOI.AbstractVariableAttribute,
    object::Union{
        Type{PhaseIndex},
        Type{DynamicVariableIndex},
        Type{Initial{PhaseIndex}},
        Type{Final{PhaseIndex}},
        Type{Initial{DynamicVariableIndex}},
        Type{Final{DynamicVariableIndex}},
    };
    error_if_supported = MOI.SetAttributeNotAllowed(attr),
)
    if MOI.supports(model, attr, typeof(object))
        throw(error_if_supported)
    else
        throw(MOI.UnsupportedAttribute(attr))
    end
end

## MOI.get

"""
    MOI.get(
        model::MOI.ModelLike,
        attr::MOI.AbstractVariableAttribute,
        t_i::PhaseIndex,
    )

Return the value of the attribute `attr` set to phase `t_i` in model `model`.

```julia 
MOI.get(
    model::MOI.ModelLike,
    attr::MOI.AbstractVariableAttribute,
    y_j::DynamicVariableIndex,
)
```

Return the value of the attribute `attr` set to dynamic variable `y_j` in model `model`.

```julia 
MOI.get(
    model::MOI.ModelLike,
    attr::MOI.AbstractVariableAttribute,
    t_i_0::Initial{PhaseIndex},
)
```

Return the value of the attribute `attr` set to the initial phase `t_i_0` in model `model`.

```julia 
MOI.get(
    model::MOI.ModelLike,
    attr::MOI.AbstractVariableAttribute,
    t_i_f::Final{PhaseIndex},
)
```

Return the value of the attribute `attr` set to the final phase `t_i_f` in model `model`.

```julia 
MOI.get(
    model::MOI.ModelLike,
    attr::MOI.AbstractVariableAttribute,
    y_j_0::Initial{DynamicVariableIndex},
)
```

Return the value of the attribute `attr` set to the initial dynamic variable `y_j_0` in model `model`.

```julia 
MOI.get(
    model::MOI.ModelLike,
    attr::MOI.AbstractVariableAttribute,
    y_j_f::Final{DynamicVariableIndex},
)
```

Return the value of the attribute `attr` set to the final dynamic variable `y_j_f` in model `model`.

For all of the above methods, if the attribute `attr` is not supported by `model` then
an error should be thrown. If the attribute is supported but has not been set, `nothing` is returned.
"""
function MOI.get(
    model::MOI.ModelLike,
    attr::MOI.AbstractVariableAttribute,
    object::Union{
        Type{PhaseIndex},
        Type{DynamicVariableIndex},
        Type{Initial{PhaseIndex}},
        Type{Final{PhaseIndex}},
        Type{Initial{DynamicVariableIndex}},
        Type{Final{DynamicVariableIndex}},
    },
)
    return throw(
        MOI.GetAttributeNotAllowed(
            attr,
            "$(typeof(model)) does not support getting the attribute $(attr) for $(typeof(object)).",
        ),
    )
end