```@meta
CurrentModule = DynOptInterface
```

# Phases

```@docs
PhaseIndex
supports_phase
UnsupportedPhase
AddPhaseNotAllowed
add_phase
MOI.is_valid(::MOI.ModelLike, ::PhaseIndex)
InvalidPhaseIndex
```

# Attributes

The [`PhaseIndex`](@ref) object is compatible with the following attributes:
* [`MOI.VariableName`](@extref MathOptInterface.VariableName) with value types `String`
* [`MOI.VariablePrimal`](@extref MathOptInterface.VariablePrimal) with value types `Tuple{<:Real,<:Real}`
* [`MOI.VariablePrimalStart`](@extref MathOptInterface.VariablePrimalStart) with value types `Tuple{<:Real,<:Real}`

```@docs
MOI.supports(::MOI.ModelLike, ::MOI.AbstractVariableAttribute, ::Type{PhaseIndex})
MOI.set(::MOI.ModelLike, ::MOI.AbstractVariableAttribute, ::PhaseIndex, ::Any)
MOI.get(::MOI.ModelLike, ::MOI.AbstractVariableAttribute, ::PhaseIndex)
```