```@meta
CurrentModule = DynOptInterface
```

# Phases

## Types

```@docs
AbstractDynamicFunction
PhaseIndex
```

## Errors

```@docs
UnsupportedPhase
AddPhaseNotAllowed
```

## Functions

```@docs
supports_phase
add_phase
MOI.supports(::MOI.ModelLike, ::AbstractPhaseAttribute, ::Type{PhaseIndex})
MOI.set(::MOI.ModelLike, ::AbstractPhaseAttribute, ::PhaseIndex, ::Any)
MOI.get(::MOI.ModelLike, ::AbstractPhaseAttribute, ::PhaseIndex)
```

## Attributes

```@docs
AbstractPhaseAttribute
PhaseName
PhaseInitialPrimalStart
PhaseFinalPrimalStart
PhaseInitialPrimal
PhaseFinalPrimal
```