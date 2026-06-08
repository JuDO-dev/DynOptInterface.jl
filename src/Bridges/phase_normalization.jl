"""
    PhaseNormalizationBridge{T}

Bridges a `Final{PhaseIndex}`-in-`S` constraint where `S` is any set other than
`EqualTo` (i.e., the final phase boundary is a free optimization variable) to a
normalized phase on `[0, 1]`.

Concretely, `t_0^(i)` and `t_f^(i)` are promoted to `MOI.VariableIndex` entries
in `x`, constrained to the bounds given by the original set `S` on the final time
and by any existing `Initial{PhaseIndex}` constraint on the initial time.  Then,
via `final_touch`, every `ExplicitDifferentialFunction` constraint on the same
phase is scaled by `(t_f - t_0)`, implementing

    τ^(i) := (t^(i) - t_0^(i)) / (t_f^(i) - t_0^(i)),   τ^(i) ∈ [0, 1].

## Source node

`PhaseNormalizationBridge` supports:

 * `DOI.Final{DOI.PhaseIndex}`-in-`S` where `S <: MOI.AbstractScalarSet`
   and `S` is not `MOI.EqualTo{T}` (variable final boundary)

## Target nodes

`PhaseNormalizationBridge` creates:

 * Two `MOI.VariableIndex` in `MOI.Reals`: `t_0` and `t_f`
 * `MOI.VariableIndex`-in-`S`: bound constraint on `t_f` from the original set
 * Via `final_touch`: wraps each `ExplicitDifferentialFunction` constraint on the
   phase with a `(t_f - t_0)` scaling factor, i.e.
       ẏ_j - d(ẏ, y, τ, x) = 0  →  ẏ_j - (t_f - t_0)·d(ẏ, y, τ, x) = 0
"""
struct PhaseNormalizationBridge{T, S<:MOI.AbstractScalarSet} <:
        MOI.Bridges.Constraint.AbstractBridge
    phase::DOI.PhaseIndex
    t_0::MOI.VariableIndex
    t_f::MOI.VariableIndex
    t_f_bound_con::MOI.ConstraintIndex{MOI.VariableIndex, S}
    # Constraint indices of the ExplicitDifferentialFunction constraints that
    # were modified by final_touch, stored so they can be deleted cleanly.
    scaled_dif_cons::Vector{MOI.ConstraintIndex}
end

function MOI.supports_constraint(
    ::Type{<:PhaseNormalizationBridge},
    ::Type{DOI.Final{DOI.PhaseIndex}},
    ::Type{S},
) where {S<:MOI.AbstractScalarSet}
    return !(S <: MOI.EqualTo)
end

function MOI.Bridges.added_constrained_variable_types(
    ::Type{<:PhaseNormalizationBridge},
)
    return Tuple{Type}[(MOI.Reals,)]
end

function MOI.Bridges.added_constraint_types(
    ::Type{PhaseNormalizationBridge{T, S}},
) where {T, S}
    return Tuple{Type, Type}[
        (MOI.VariableIndex, S),
        (DOI.ExplicitDifferentialFunction{DOI.NonlinearDynamicFunction}, MOI.EqualTo{T}),
    ]
end

function MOI.Bridges.Constraint.concrete_bridge_type(
    ::Type{<:PhaseNormalizationBridge{T}},
    ::Type{DOI.Final{DOI.PhaseIndex}},
    ::Type{S},
) where {T, S}
    return PhaseNormalizationBridge{T, S}
end

function MOI.Bridges.Constraint.bridge_constraint(
    ::Type{PhaseNormalizationBridge{T, S}},
    model::MOI.ModelLike,
    final_fun::DOI.Final{DOI.PhaseIndex},
    set::S,
) where {T, S}
    phase = final_fun.dyn_fun

    # Promote t_0 and t_f to optimization variables.
    t_0 = MOI.add_variable(model)
    t_f = MOI.add_variable(model)

    # Transfer the bound on the final time to t_f.
    t_f_bound_con = MOI.add_constraint(model, t_f, set)

    return PhaseNormalizationBridge{T, S}(phase, t_0, t_f, t_f_bound_con, MOI.ConstraintIndex[])
end

# --- final_touch: scale all ExplicitDifferentialFunction constraints on this phase ---

MOI.Bridges.needs_final_touch(::PhaseNormalizationBridge) = true

function MOI.Bridges.final_touch(
    bridge::PhaseNormalizationBridge{T},
    model::MOI.ModelLike,
) where {T}
    NDF = DOI.NonlinearDynamicFunction
    EDF = DOI.ExplicitDifferentialFunction{NDF}

    empty!(bridge.scaled_dif_cons)

    for ci in MOI.get(model, MOI.ListOfConstraintIndices{EDF, MOI.EqualTo{T}}())
        f = MOI.get(model, MOI.ConstraintFunction(), ci)

        # Only scale constraints belonging to this phase.
        DOI.phase_index(f) == bridge.phase || continue

        # Replace d_o(ẏ, y, τ, x) with (t_f - t_0) · d_o(ẏ, y, τ, x).
        dt = MOI.ScalarNonlinearFunction(
            :-, Any[bridge.t_f, bridge.t_0],
        )
        scaled_rhs = DOI.NonlinearDynamicFunction(
            :*, Any[dt, f.dyn_fun], bridge.phase,
        )
        new_f = DOI.ExplicitDifferentialFunction(f.dyn_var, scaled_rhs)
        MOI.set(model, MOI.ConstraintFunction(), ci, new_f)
        push!(bridge.scaled_dif_cons, ci)
    end
    return
end

# --- Bookkeeping (MOI.AbstractBridge interface) ---

MOI.get(::PhaseNormalizationBridge, ::MOI.NumberOfVariables)::Int64 = 2

function MOI.get(b::PhaseNormalizationBridge, ::MOI.ListOfVariableIndices)
    return [b.t_0, b.t_f]
end

function MOI.get(
    ::PhaseNormalizationBridge{T, S},
    ::MOI.NumberOfConstraints{MOI.VariableIndex, S},
)::Int64 where {T, S}
    return 1
end

function MOI.get(
    b::PhaseNormalizationBridge{T, S},
    ::MOI.ListOfConstraintIndices{MOI.VariableIndex, S},
) where {T, S}
    return [b.t_f_bound_con]
end

function MOI.delete(model::MOI.ModelLike, bridge::PhaseNormalizationBridge)
    MOI.delete(model, bridge.t_f_bound_con)
    MOI.delete(model, bridge.t_f)
    MOI.delete(model, bridge.t_0)
    return
end
