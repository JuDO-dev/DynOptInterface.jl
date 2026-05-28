"""
    MultiPhaseToSinglePhaseBridge{T, DF<:DOI.AbstractDynamicFunction}

Bridges a `Linkage{DF}`-in-`EqualTo{T}` constraint, which encodes inter-phase
continuity as `Final(y_f) - Initial(y_0) = 0`, into two separate boundary
constraints sharing a scalar slack variable `s`:

    Final(y_f)   = s
    Initial(y_0) = s

This allows solvers that support `Initial`/`Final` boundary constraints but
not the compact `Linkage` representation to handle multi-phase continuity.

## Source node

`MultiPhaseToSinglePhaseBridge` supports:

 * `DOI.Linkage{DF}`-in-`MOI.EqualTo{T}`

## Target nodes

`MultiPhaseToSinglePhaseBridge` creates:

 * One `MOI.VariableIndex` in `MOI.Reals` (scalar slack `s`)
 * `DOI.NonlinearBoundaryFunction`-in-`MOI.EqualTo{T}`:  Final(y_f) - s = 0
 * `DOI.NonlinearBoundaryFunction`-in-`MOI.EqualTo{T}`:  Initial(y_0) - s = 0
"""
struct MultiPhaseToSinglePhaseBridge{T, DF<:DOI.AbstractDynamicFunction} <:
        MOI.Bridges.Constraint.AbstractBridge
    slack::MOI.VariableIndex
    final_con::MOI.ConstraintIndex{DOI.NonlinearBoundaryFunction, MOI.EqualTo{T}}
    initial_con::MOI.ConstraintIndex{DOI.NonlinearBoundaryFunction, MOI.EqualTo{T}}
end

function MOI.supports_constraint(
    ::Type{<:MultiPhaseToSinglePhaseBridge},
    ::Type{DOI.Linkage{DF}},
    ::Type{MOI.EqualTo{T}},
) where {T<:Real, DF<:DOI.AbstractDynamicFunction}
    return true
end

function MOI.Bridges.added_constrained_variable_types(
    ::Type{<:MultiPhaseToSinglePhaseBridge},
)
    return Tuple{Type}[(MOI.Reals,)]
end

function MOI.Bridges.added_constraint_types(
    ::Type{<:MultiPhaseToSinglePhaseBridge{T}},
) where {T}
    return Tuple{Type, Type}[
        (DOI.NonlinearBoundaryFunction, MOI.EqualTo{T}),
    ]
end

function MOI.Bridges.Constraint.concrete_bridge_type(
    ::Type{<:MultiPhaseToSinglePhaseBridge{T}},
    ::Type{DOI.Linkage{DF}},
    ::Type{MOI.EqualTo{T}},
) where {T, DF}
    return MultiPhaseToSinglePhaseBridge{T, DF}
end

function MOI.Bridges.Constraint.bridge_constraint(
    ::Type{MultiPhaseToSinglePhaseBridge{T, DF}},
    model::MOI.ModelLike,
    linkage::DOI.Linkage{DF},
    ::MOI.EqualTo{T},
) where {T, DF}
    # Introduce scalar slack s representing the shared boundary value.
    slack = MOI.add_variable(model)

    # Final(y_f) - s = 0
    final_con = MOI.add_constraint(
        model,
        DOI.NonlinearBoundaryFunction(:-, Any[DOI.Final(linkage.dyn_fun_final), slack]),
        MOI.EqualTo(zero(T)),
    )

    # Initial(y_0) - s = 0
    initial_con = MOI.add_constraint(
        model,
        DOI.NonlinearBoundaryFunction(:-, Any[DOI.Initial(linkage.dyn_fun_initial), slack]),
        MOI.EqualTo(zero(T)),
    )

    return MultiPhaseToSinglePhaseBridge{T, DF}(slack, final_con, initial_con)
end

# --- Bookkeeping (MOI.AbstractBridge interface) ---

MOI.get(::MultiPhaseToSinglePhaseBridge, ::MOI.NumberOfVariables)::Int64 = 1

function MOI.get(b::MultiPhaseToSinglePhaseBridge, ::MOI.ListOfVariableIndices)
    return [b.slack]
end

function MOI.get(
    ::MultiPhaseToSinglePhaseBridge{T},
    ::MOI.NumberOfConstraints{DOI.NonlinearBoundaryFunction, MOI.EqualTo{T}},
)::Int64 where {T}
    return 2
end

function MOI.get(
    b::MultiPhaseToSinglePhaseBridge{T},
    ::MOI.ListOfConstraintIndices{DOI.NonlinearBoundaryFunction, MOI.EqualTo{T}},
) where {T}
    return [b.final_con, b.initial_con]
end

function MOI.delete(model::MOI.ModelLike, bridge::MultiPhaseToSinglePhaseBridge)
    MOI.delete(model, bridge.final_con)
    MOI.delete(model, bridge.initial_con)
    MOI.delete(model, bridge.slack)
    return
end

function MOI.get(
    model::MOI.ModelLike,
    ::MOI.ConstraintFunction,
    bridge::MultiPhaseToSinglePhaseBridge{T, DF},
) where {T, DF}
    # Reconstruct the original Linkage from the two split constraints.
    f_fun = MOI.get(model, MOI.ConstraintFunction(), bridge.final_con)
    i_fun = MOI.get(model, MOI.ConstraintFunction(), bridge.initial_con)
    # f_fun = Final(y_f) - slack,  i_fun = Initial(y_0) - slack
    final_bf   = f_fun.args[1]  # DOI.Final(dyn_fun_final)
    initial_bf = i_fun.args[1]  # DOI.Initial(dyn_fun_initial)
    return DOI.Linkage(final_bf.dyn_fun, initial_bf.dyn_fun)
end

function MOI.get(
    ::MOI.ModelLike,
    ::MOI.ConstraintSet,
    ::MultiPhaseToSinglePhaseBridge{T},
) where {T}
    return MOI.EqualTo(zero(T))
end
