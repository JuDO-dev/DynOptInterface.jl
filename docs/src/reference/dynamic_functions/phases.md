```@meta
CurrentModule = DynOptInterface
```

# Phases

```@docs
AbstractDynamicFunction
PhaseIndex
phase_index
NonUniquePhaseError
```

# Phases in Models

```@docs
supports_phases
UnsupportedPhasesError
add_phase
AddPhaseNotAllowedError
MOI.is_valid(::MOI.ModelLike, ::PhaseIndex)
InvalidPhaseError
```

# Phase Attributes

```@docs
AbstractPhaseAttribute
MOI.supports(::MOI.ModelLike, ::AbstractPhaseAttribute)
MOI.set(::MOI.ModelLike, ::AbstractPhaseAttribute, ::PhaseIndex, ::Any)
MOI.get(::MOI.ModelLike, ::AbstractPhaseAttribute, ::PhaseIndex)
PhaseName
PhaseInitialStart
PhaseFinalStart
```