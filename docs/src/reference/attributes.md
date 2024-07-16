```@meta
CurrentModule = DynOptInterface
```

# Attributes

# Variable Attributes

The following table defines which `DynOptInterface` objects are compatible with sub-types of
[`MOI.AbstractVariableAttribute`](@extref MathOptInterface.AbstractVariableAttribute)s.

| Attribute | ``t`` | ``t^0`` | ``t^f`` | ``y(\cdot)`` | ``y(t^0)`` | ``y(t^f)`` |
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| [`MOI.VariableName`](@extref MathOptInterface.VariableName) | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ |
| [`MOI.VariablePrimal`](@extref MathOptInterface.VariablePrimal) | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ |
| [`MOI.VariablePrimalStart`](@extref MathOptInterface.VariablePrimalStart) | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ |

```@docs
MOI.supports
MOI.set
MOI.get
```