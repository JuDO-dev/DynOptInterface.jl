```@meta
CurrentModule = DynOptInterface.Bridges
```

# Bridges

DynOptInterface bridges are automatic reformulation rules that convert DOP
formulations unsupported by a solver into equivalent ones that are supported.
They follow the same design as
[MathOptInterface bridges](https://jump.dev/MathOptInterface.jl/stable/submodules/Bridges/reference/),
subtyping either `MOI.Bridges.Objective.AbstractBridge` or
`MOI.Bridges.Constraint.AbstractBridge`.

Bridges are registered on a `MOI.Bridges.LazyBridgeOptimizer` and fire
automatically: before each solve, MOI computes the shortest reformulation path
through the registered bridges and applies only those needed for the attached
solver. A bridge does nothing if the solver already supports the target
formulation natively.

```@docs
add_all_bridges
```

## Objective Bridges

Objective bridges reformulate the objective function into a form the solver
can accept, while preserving equivalence of the optimal solution.

### Lagrange to Mayer

The Lagrange-to-Mayer bridge converts a [`Bolza`](@ref DynOptInterface.Bolza)
objective — a Mayer terminal cost plus a
[`MultiPhaseIntegral`](@ref DynOptInterface.MultiPhaseIntegral) running cost —
into a pure Mayer objective.

For each phase integral ``\int_{t_0}^{t_f} \ell(y,t)\,\mathrm{d}t``, the
bridge introduces an augmented state variable ``y_\ell`` governed by

```math
\dot{y}_\ell(t) = \ell(y(t), t), \qquad y_\ell(t_0) = 0.
```

By the fundamental theorem of calculus, ``y_\ell(t_f)`` equals the running
integral, so the original objective is recovered as the terminal cost
``\phi(y(t_f)) + y_\ell(t_f)``. The solver therefore receives a pure Mayer
problem expressed entirely in terms of
[`NonlinearBoundaryFunction`](@ref DynOptInterface.NonlinearBoundaryFunction).

```@docs
LagrangeToMayerBridge
```

## Constraint Bridges

Constraint bridges reformulate individual constraints into equivalent forms
that the solver supports.

### Multi-Phase to Single-Phase

Multi-phase problems require continuity between phases: the final state of one
phase must equal the initial state of the next. This is expressed compactly by
a [`Linkage`](@ref DynOptInterface.Linkage) constraint, but some solvers only
accept individual [`Initial`](@ref DynOptInterface.Initial) and
[`Final`](@ref DynOptInterface.Final) boundary constraints.

The multi-phase-to-single-phase bridge splits each `Linkage` constraint into
two separate boundary constraints sharing a scalar slack variable ``s``:

```math
\mathrm{Final}(y_f) = s, \qquad \mathrm{Initial}(y_0) = s.
```

```@docs
MultiPhaseToSinglePhaseBridge
```

### Phase Normalization

When the final time ``t_f`` is a free optimization variable (i.e., the
[`Final{PhaseIndex}`](@ref DynOptInterface.Final) constraint is not an
equality), the phase normalization bridge maps the problem onto a fixed
normalized domain ``\tau \in [0,1]`` via

```math
\tau^{(i)} = \frac{t^{(i)} - t_0^{(i)}}{t_f^{(i)} - t_0^{(i)}}.
```

The bridge promotes ``t_0`` and ``t_f`` to `MOI.VariableIndex` entries and
rescales every
[`ExplicitDifferentialFunction`](@ref DynOptInterface.ExplicitDifferentialFunction)
constraint on the phase by ``(t_f - t_0)``:

```math
\dot{y}_j - d(y,\tau,x) = 0
\;\longrightarrow\;
\dot{y}_j - (t_f - t_0)\,d(y,\tau,x) = 0.
```

This rescaling is applied lazily via `MOI.Bridges.final_touch`, which fires
immediately before `MOI.optimize!`, ensuring all differential constraints
added after bridge registration are captured.

```@docs
PhaseNormalizationBridge
```
