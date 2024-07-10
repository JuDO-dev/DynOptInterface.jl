```@meta
CurrentModule = DynOptInterface
```

# Dynamic Variables

## Types

```@docs
DynamicVariableIndex
DynamicVariableDerivative
```

## Errors

```@docs
UnsupportedDynamicVariable
AddDynamicVariableNotAllowed
```

## Functions

```@docs
supports_dynamic_variable
add_dynamic_variable
MOI.supports(::MOI.ModelLike, ::AbstractDynamicVariableAttribute, ::Type{DynamicVariableIndex})
MOI.set(::MOI.ModelLike, ::AbstractDynamicVariableAttribute, ::DynamicVariableIndex, ::Any)
MOI.get(::MOI.ModelLike, ::AbstractDynamicVariableAttribute, ::DynamicVariableIndex)
```

## Attributes

```@docs
AbstractDynamicVariableAttribute
DynamicVariableName
DynamicVariablePrimalStart
DynamicVariablePrimal
```