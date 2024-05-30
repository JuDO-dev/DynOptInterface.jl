```@meta
CurrentModule = DynOptInterface
```

# Abstractions

The following are sub-types of [`AbstractDynamicFunction`](@ref):

* [`AbstractAlgebraicFunction`](@ref)
    * ``t_i`` [`DomainIndex`](@ref)
    * ``t_i \mapsto y_j(t_i)`` [`DynamicVariableIndex`](@ref)
    * ``t_i \mapsto a(y(t_i), t_i, x)`` [`NonlinearAlgebraicFunction`](@ref)
* [`AbstractDifferentialFunction`](@ref)
    * ``t_i \mapsto \dot{y}_j(t_i)`` [`DynamicVariableDerivative`](@ref)
    * ``t_i \mapsto \dot{y}_j(t_i) - a(y(t_i), t_i, x)`` [`ExplicitDifferentialFunction`](@ref)
    * ``t_i \mapsto r(\dot{y}(t_i), y(t_i), t_i, x)`` [`NonlinearDifferentialFunction`](@ref)
* [`AbstractBoundaryFunction`](@ref)
    * ``t_i^0, t_i^f`` [`DomainInitial`](@ref), [`DomainFinal`](@ref)
    * ``y_j(t_i^0), y_j(t_i^f)`` [`DynamicVariableInitial`](@ref), [`DynamicVariableFinal`](@ref)
    * ``b(y(t^0), y(t^f), t^0, t^f, x)`` [`NonlinearBoundaryFunction`](@ref)
* ``\int_{t_i^0}^{t_i^f} a(y(t_i), t_i, x) \mathrm{d}t_i`` [`IntegralFunction`](@ref)
* ``b(y(t_i^0), y(t_i^f), t_i^0, t_i^f, x) + \int_{t_i^0}^{t_i^f} a(y(t_i), t_i, x) \mathrm{d}t_i`` [`BolzaFunction`](@ref)

```@docs
AbstractDynamicFunction
AbstractAlgebraicFunction
AbstractDifferentialFunction
AbstractBoundaryFunction
```