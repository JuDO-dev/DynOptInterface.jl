```@meta
CurrentModule = DynOptInterface
```

# Dynamic Variables

```@docs
DynamicVariableIndex
supports_dynamic_variable
UnsupportedDynamicVariable
AddDynamicVariableNotAllowed
add_dynamic_variable
MOI.is_valid(::MOI.ModelLike, ::DynamicVariableIndex)
InvalidDynamicVariableIndex
```

# Attributes

The [`DynamicVariableIndex`](@ref) object is compatible with the following attributes:
* [`MOI.VariableName`](@extref MathOptInterface.VariableName) with value types `String`
* [`MOI.VariablePrimal`](@extref MathOptInterface.VariablePrimal) with value types [`AbstractDynamicSolution`](@ref)
* [`MOI.VariablePrimalStart`](@extref MathOptInterface.VariablePrimalStart) with value types [`AbstractDynamicSolution`](@ref)

```@docs
MOI.supports(::MOI.ModelLike, ::MOI.AbstractVariableAttribute, ::Type{DynamicVariableIndex})
MOI.set(::MOI.ModelLike, ::MOI.AbstractVariableAttribute, ::DynamicVariableIndex, ::Any)
MOI.get(::MOI.ModelLike, ::MOI.AbstractVariableAttribute, ::DynamicVariableIndex)
```