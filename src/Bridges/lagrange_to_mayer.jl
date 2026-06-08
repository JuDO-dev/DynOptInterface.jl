"""
    LagrangeToMayerBridge{T, NDF<:DOI.AbstractDynamicFunction}

Bridges a `Bolza` objective with a `MultiPhaseIntegral` Lagrange term to a pure
Mayer form by introducing one augmented dynamic variable `y_ℓ` per phase.

## Source node

`LagrangeToMayerBridge` supports:

 * `DOI.Bolza{BF, DOI.MultiPhaseIntegral{NDF}}`-in-`ObjectiveFunction`

## Target nodes

`LagrangeToMayerBridge` creates per phase:

 * One `DOI.DynamicVariableIndex` `y_ℓ` on the same phase as the Lagrange integrand
 * One `DOI.ExplicitDifferentialFunction{NDF}`-in-`MOI.EqualTo{T}`: ẏ_ℓ = d_o
 * One `DOI.Initial{DOI.LinearDynamicFunction{T}}`-in-`MOI.EqualTo{T}`: y_ℓ(t₀) = 0
 * `DOI.NonlinearBoundaryFunction`-in-`ObjectiveFunction` (Mayer-only)
"""
struct LagrangeToMayerBridge{T, NDF<:DOI.AbstractDynamicFunction} <:
        MOI.Bridges.Objective.AbstractBridge
    y_ells::Vector{DOI.DynamicVariableIndex}
    ode_cons::Vector{MOI.ConstraintIndex{DOI.ExplicitDifferentialFunction{NDF}, MOI.EqualTo{T}}}
    ic_cons::Vector{MOI.ConstraintIndex{DOI.Initial{DOI.LinearDynamicFunction{T}}, MOI.EqualTo{T}}}
end

function MOI.Bridges.Objective.supports_objective_function(
    ::Type{<:LagrangeToMayerBridge},
    ::Type{<:DOI.Bolza{<:DOI.AbstractBoundaryFunction, <:DOI.MultiPhaseIntegral}},
)
    return true
end

function MOI.Bridges.set_objective_function_type(
    ::Type{<:LagrangeToMayerBridge},
)
    return DOI.NonlinearBoundaryFunction
end

# DynamicVariableIndex is not MOI.VariableIndex; no standard MOI variables are added.
function MOI.Bridges.added_constrained_variable_types(
    ::Type{<:LagrangeToMayerBridge},
)
    return Tuple{Type}[]
end

function MOI.Bridges.added_constraint_types(
    ::Type{LagrangeToMayerBridge{T, NDF}},
) where {T, NDF}
    return Tuple{Type, Type}[
        (DOI.ExplicitDifferentialFunction{NDF},            MOI.EqualTo{T}),
        (DOI.Initial{DOI.LinearDynamicFunction{T}},        MOI.EqualTo{T}),
    ]
end

function MOI.Bridges.Objective.concrete_bridge_type(
    ::Type{<:LagrangeToMayerBridge{T}},
    ::Type{<:DOI.Bolza{<:DOI.AbstractBoundaryFunction, DOI.MultiPhaseIntegral{NDF}}},
) where {T, NDF}
    return LagrangeToMayerBridge{T, NDF}
end

function MOI.Bridges.Objective.bridge_objective(
    ::Type{LagrangeToMayerBridge{T, NDF}},
    model::MOI.ModelLike,
    bolza::DOI.Bolza{<:DOI.AbstractBoundaryFunction, DOI.MultiPhaseIntegral{NDF}},
) where {T, NDF}
    y_ells   = DOI.DynamicVariableIndex[]
    ode_cons = MOI.ConstraintIndex{DOI.ExplicitDifferentialFunction{NDF}, MOI.EqualTo{T}}[]
    ic_cons  = MOI.ConstraintIndex{DOI.Initial{DOI.LinearDynamicFunction{T}}, MOI.EqualTo{T}}[]

    for d_o in bolza.integral.dyn_funs
        phase = DOI.phase_index(d_o)

        # Add augmented accumulator state y_ℓ on the same phase as d_o.
        y_ell = DOI.add_dynamic_variable(model, phase)
        push!(y_ells, y_ell)

        # ẏ_ℓ(t) = d_o(ẏ(t), y(t), t, x)  encoded as  ẏ_ℓ - d_o = 0
        push!(ode_cons, MOI.add_constraint(
            model,
            DOI.ExplicitDifferentialFunction(y_ell, d_o),
            MOI.EqualTo(zero(T)),
        ))

        # y_ℓ(t₀) = 0
        y_ell_lf = DOI.LinearDynamicFunction([DOI.LinearDynamicTerm(one(T), y_ell)])
        push!(ic_cons, MOI.add_constraint(
            model,
            DOI.Initial(y_ell_lf),
            MOI.EqualTo(zero(T)),
        ))
    end

    # New objective: φ(y(t₀), y(tf), t₀, tf, x) + Final(y_ℓ^(1)) + ... + Final(y_ℓ^(np))
    # y_ℓ(tf) equals the Lagrange integral by the fundamental theorem of calculus.
    final_terms = Any[bolza.bou_fun]
    for y_ell in y_ells
        y_ell_lf = DOI.LinearDynamicFunction([DOI.LinearDynamicTerm(one(T), y_ell)])
        push!(final_terms, DOI.Final(y_ell_lf))
    end
    new_obj = DOI.NonlinearBoundaryFunction(:+, final_terms)
    MOI.set(model, MOI.ObjectiveFunction{typeof(new_obj)}(), new_obj)

    return LagrangeToMayerBridge{T, NDF}(y_ells, ode_cons, ic_cons)
end

# --- Bookkeeping (MOI.AbstractBridge interface) ---

MOI.get(::LagrangeToMayerBridge, ::MOI.NumberOfVariables)::Int64 = 0
MOI.get(::LagrangeToMayerBridge, ::MOI.ListOfVariableIndices) = MOI.VariableIndex[]

function MOI.get(
    b::LagrangeToMayerBridge{T, NDF},
    ::MOI.NumberOfConstraints{DOI.ExplicitDifferentialFunction{NDF}, MOI.EqualTo{T}},
)::Int64 where {T, NDF}
    return length(b.ode_cons)
end

function MOI.get(
    b::LagrangeToMayerBridge{T, NDF},
    ::MOI.ListOfConstraintIndices{DOI.ExplicitDifferentialFunction{NDF}, MOI.EqualTo{T}},
) where {T, NDF}
    return copy(b.ode_cons)
end

function MOI.get(
    b::LagrangeToMayerBridge{T},
    ::MOI.NumberOfConstraints{DOI.Initial{DOI.LinearDynamicFunction{T}}, MOI.EqualTo{T}},
)::Int64 where {T}
    return length(b.ic_cons)
end

function MOI.get(
    b::LagrangeToMayerBridge{T},
    ::MOI.ListOfConstraintIndices{DOI.Initial{DOI.LinearDynamicFunction{T}}, MOI.EqualTo{T}},
) where {T}
    return copy(b.ic_cons)
end

function MOI.delete(model::MOI.ModelLike, bridge::LagrangeToMayerBridge)
    for ci in bridge.ode_cons
        MOI.delete(model, ci)
    end
    for ci in bridge.ic_cons
        MOI.delete(model, ci)
    end
    return
end

# Reconstruction of the original Bolza from Mayer form is not supported.
function MOI.get(
    ::MOI.ModelLike,
    ::MOI.ObjectiveFunction{<:DOI.Bolza},
    ::LagrangeToMayerBridge,
)
    return throw(MOI.GetAttributeNotAllowed(
        MOI.ObjectiveFunction{DOI.Bolza}(),
        "LagrangeToMayerBridge does not support retrieving the original Bolza objective.",
    ))
end
