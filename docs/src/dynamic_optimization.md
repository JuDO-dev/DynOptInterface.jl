```@meta
CurrentModule = DynOptInterface
```

# Dynamic Optimization

This section describes the formulation of a generic multi-phase dynamic optimization problem (DOP).
This formulation extends MathOptInterface's [Function-in-Set formulation](@extref Standard-form-problem) for *finite-dimensional* optimization problems.

## Finite-Dimensional Optimization

A finite-dimensional optimization problem is defined as finding the variables ``x`` that
```math
\begin{equation*}
\begin{aligned}
\text{minimize} \quad &f_o(x),\\
\text{subject to} \quad &f_c(x) \in \mathcal{S},
\end{aligned}
\end{equation*}
```
where ``f_o`` is the objective function, ``f_c`` is the constraints function, and ``\mathcal{S}`` is the constraints set.

## Phases

A *phase* is an interval (e.g., a time segment) whose boundaries can be optimization variables.
The ``i``-th phase of a DOP is the interval between ``t_0^{(i)}`` and ``t_f^{(i)}``. 
Moreover, ``t^{(i)}`` is a parameter that takes values in the ``i``-th phase.

| Symbol | Description | Element Type | 
|:-:|:--|:--|
| ``t_0`` | Vector of initial boundaries of phases | [`Initial`](@ref)`{`[`PhaseIndex`](@ref)`}` |
| ``t_f`` | Vector of final boundaries of phases | [`Final`](@ref)`{`[`PhaseIndex`](@ref)`}` |

## Dynamic Variables

A *dynamic variable* is an optimizable function defined on a phase.
The ``j``-th dynamic variable of a DOP, defined on the ``i``-th phase, is denoted as
```math
\begin{equation*}
t^{(i)} \mapsto \boldsymbol y_j(t^{(i)}).
\end{equation*}
```
The first derivative of ``\boldsymbol y_j`` is denoted as ``\dot{\boldsymbol y}_j``.

| Symbol | Description | Element Type | 
|:-:|:--|:--|
| ``\boldsymbol y`` | Vector of dynamic variables | [`DynamicVariableIndex`](@ref) |
| ``\dot{\boldsymbol y}`` | Vector of derivatives of dynamic variables | [`Derivative`](@ref)`{`[`DynamicVariableIndex`](@ref)`}` |

## Objective

The objective function is augmented to include a boundary term and an integrated dynamic term.

| Symbol | Description | Type |
|:-:|:--|:--|
| ``f_o`` | Finite-dimensional objective function | `<:`[`MOI.AbstractScalarFunction`](@extref MathOptInterface.AbstractScalarFunction) |
| ``b_o`` | Boundary objective function | `<:`[`AbstractBoundaryFunction`](@ref) |
| ``d_o^{(i)}`` | The ``i``-th phase dynamic objective function | `<:`[`AbstractDynamicFunction`](@ref) |

## Constraints

The constraints are extended to include *boundary constraints* and *dynamic constraints*.

| Symbol | Description | Element Type |
|:-:|:--|:--|
| ``f_c`` | Finite-dimensional constraint functiosn | `<:`[`MOI.AbstractScalarFunction`](@extref MathOptInterface.AbstractScalarFunction) | 
| ``\mathcal{S}`` | Finite-dimensional constraint sets | `<`[`MOI.AbstractScalarSet`](@extref MathOptInterface.AbstractScalarSet) |
| ``b_c`` | Boundary constraint functions | `<:`[`AbstractBoundaryFunction`](@ref) |
| ``\mathcal{B}`` | Boundary constraint sets| `<`[`MOI.AbstractScalarSet`](@extref MathOptInterface.AbstractScalarSet) |
| ``d_c^{(i)}`` | The ``i``-th phase dynamic constraint functions | `<:`[`AbstractDynamicFunction`](@ref) |
| ``\mathcal{D}^{(i)}`` | The ``i``-th phase dynamic constraint sets | `<`[`MOI.AbstractScalarSet`](@extref MathOptInterface.AbstractScalarSet) |

## DOP Formulation

The dynamic optimization problem is defined as finding the variables ``x``, the phase boundaries ``t_0``, ``t_f``, and the dynamic variables ``\boldsymbol y`` that
```math
\begin{align*}
\begin{array}{rl}
    \text{minimize} \quad &
    f_o(x) + b_o \big( \boldsymbol y(t_0), \boldsymbol y(t_f), t_0, t_f, x \big) +
    \displaystyle{\sum_{i=1}^{n_p} \bigg[
    \int_{t_0^{(i)}}^{t_f^{(i)}} d_o^{(i)} \big( \boldsymbol y^{(i)}(t), t, x \big) \textrm{d}t \bigg],}\\
    %
    \text{subject to} \quad &
    \begin{aligned}
        f_c(x) & \in \mathcal S,\\
        b_c(\boldsymbol y(t_0), \boldsymbol y(t_f), t_0, t_f, x) &\in \mathcal B,\\
        d^{(i)}\big(\dot{\boldsymbol y}^{(i)}(t^{(i)}), \boldsymbol y^{(i)}(t^{(i)}), t^{(i)}, x) & \in \mathcal D^{(i)},
        \quad \forall t^{(i)} \in [t_0^{(i)}, t_f^{(i)}], \quad \forall i \in \{1, 2, ..., n_p\}.
    \end{aligned}
\end{array}
\end{align*}
```