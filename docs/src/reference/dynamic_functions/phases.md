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

# Phase Attributes

```@docs
AbstractPhaseAttribute
MOI.supports(::MOI.ModelLike, ::AbstractPhaseAttribute, ::Type{PhaseIndex})
MOI.set(::MOI.ModelLike, ::AbstractPhaseAttribute, ::PhaseIndex, ::Any)
MOI.get(::MOI.ModelLike, ::AbstractPhaseAttribute, ::PhaseIndex)
PhaseName
```