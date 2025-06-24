```@meta
CurrentModule = DynOptInterface
```

# Dynamic Variables

```@docs
DynamicVariableIndex
```

## Dynamic Variables in Models

```@docs
supports_dynamic_variables
UnsupportedDynamicVariablesError
add_dynamic_variable
AddDynamicVariableNotAllowedError
MOI.is_valid(::MOI.ModelLike, ::DynamicVariableIndex)
InvalidDynamicVariableError
```

## Dynamic Variable Attributes

```@docs
AbstractDynamicVariableAttribute
MOI.supports(::MOI.ModelLike, ::AbstractDynamicVariableAttribute)
MOI.set(::MOI.ModelLike, ::AbstractDynamicVariableAttribute, ::DynamicVariableIndex, ::Any)
MOI.get(::MOI.ModelLike, ::AbstractDynamicVariableAttribute, ::DynamicVariableIndex)
DynamicVariableName
DynamicVariableStart
DynamicVariableSolution
```