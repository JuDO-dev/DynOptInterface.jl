mutable struct RecordingModel <: MOI.ModelLike
    num_dyn_vars::Int
    num_vars::Int
    constraints::Vector{Any}
    deleted::Vector{Any}
    objective::Any
end
RecordingModel() = RecordingModel(0, 0, Any[], Any[], nothing)

function DOI.add_dynamic_variable(model::RecordingModel, phase::DOI.PhaseIndex)
    model.num_dyn_vars += 1
    return DOI.DynamicVariableIndex(model.num_dyn_vars, phase)
end

function MOI.add_variable(model::RecordingModel)
    model.num_vars += 1
    return MOI.VariableIndex(model.num_vars)
end

function MOI.add_constraint(model::RecordingModel, f::F, s::S) where {F<:MOI.AbstractFunction,S<:MOI.AbstractSet}
    push!(model.constraints, (f, s))
    return MOI.ConstraintIndex{F,S}(length(model.constraints))
end

function MOI.get(model::RecordingModel, ::MOI.ListOfConstraintIndices{F,S}) where {F,S}
    return [MOI.ConstraintIndex{F,S}(i) for (i, (f, s)) in enumerate(model.constraints) if f isa F && s isa S]
end

MOI.get(model::RecordingModel, ::MOI.ConstraintFunction, ci::MOI.ConstraintIndex) = model.constraints[ci.value][1]

function MOI.set(model::RecordingModel, ::MOI.ConstraintFunction, ci::MOI.ConstraintIndex, f)
    model.constraints[ci.value] = (f, model.constraints[ci.value][2])
    return
end

function MOI.set(model::RecordingModel, ::MOI.ObjectiveFunction{F}, f::F) where {F<:MOI.AbstractFunction}
    model.objective = f
    return
end

function MOI.delete(model::RecordingModel, index::Union{MOI.VariableIndex,MOI.ConstraintIndex})
    push!(model.deleted, index)
    return
end

# Return the single dynamic variable of a one-term `LinearDynamicFunction` wrapped in `Initial` or `Final`.
single_var(bou_fun) = only(bou_fun.dyn_fun.terms).dyn_var

@testset "Bridges" begin

    t_1, t_2 = DOI.PhaseIndex(1), DOI.PhaseIndex(2)
    y_1, y_2 = DOI.DynamicVariableIndex(1, t_1), DOI.DynamicVariableIndex(2, t_2)
    lin_1 = DOI.LinearDynamicFunction([DOI.LinearDynamicTerm(1.0, y_1)])
    lin_2 = DOI.LinearDynamicFunction([DOI.LinearDynamicTerm(1.0, y_2)])
    d_1 = DOI.NonlinearDynamicFunction(:^, Any[y_1, 2], t_1)
    d_2 = DOI.NonlinearDynamicFunction(:^, Any[y_2, 2], t_2)
    NDF = DOI.NonlinearDynamicFunction
    EDF = DOI.ExplicitDifferentialFunction{NDF}
    NBF = DOI.NonlinearBoundaryFunction
    LDF = DOI.LinearDynamicFunction{Float64}

    @testset "LagrangeToMayerBridge" begin
        mayer = DOI.Final(lin_1)
        bolza = DOI.Bolza(mayer, DOI.MultiPhaseIntegral([d_1, d_2]))
        @test MOI.Bridges.Objective.supports_objective_function(
            DOI.Bridges.LagrangeToMayerBridge{Float64}, typeof(bolza))
        @test !MOI.Bridges.Objective.supports_objective_function(
            DOI.Bridges.LagrangeToMayerBridge{Float64}, NBF)
        BT = MOI.Bridges.Objective.concrete_bridge_type(DOI.Bridges.LagrangeToMayerBridge{Float64}, typeof(bolza))
        @test BT == DOI.Bridges.LagrangeToMayerBridge{Float64,NDF}
        @test MOI.Bridges.set_objective_function_type(BT) == NBF
        @test MOI.Bridges.added_constraint_types(BT) == [(EDF, MOI.EqualTo{Float64}), (DOI.Initial{LDF}, MOI.EqualTo{Float64})]
        @test isempty(MOI.Bridges.added_constrained_variable_types(BT))

        model = RecordingModel()
        model.num_dyn_vars = 2
        bridge = MOI.Bridges.Objective.bridge_objective(BT, model, bolza)

        @test length(bridge.y_ells) == 2
        @test [y.value for y in bridge.y_ells] == [3, 4]
        @test DOI.phase_index.(bridge.y_ells) == [t_1, t_2]

        odes = [model.constraints[ci.value] for ci in bridge.ode_cons]
        @test [f.dyn_var for (f, s) in odes] == bridge.y_ells
        @test [f.dyn_fun for (f, s) in odes] == [d_1, d_2]
        @test all(s == MOI.EqualTo(0.0) for (f, s) in odes)
        ics = [model.constraints[ci.value] for ci in bridge.ic_cons]
        @test all(f isa DOI.Initial{LDF} for (f, s) in ics)
        @test [single_var(f) for (f, s) in ics] == bridge.y_ells
        @test all(s == MOI.EqualTo(0.0) for (f, s) in ics)

        obj = model.objective
        @test obj isa NBF
        @test obj.head == :+
        @test obj.args[1] === mayer
        @test all(a isa DOI.Final{LDF} for a in obj.args[2:end])
        @test [single_var(a) for a in obj.args[2:end]] == bridge.y_ells

        @test MOI.get(bridge, MOI.NumberOfVariables()) == 0
        @test isempty(MOI.get(bridge, MOI.ListOfVariableIndices()))
        @test MOI.get(bridge, MOI.NumberOfConstraints{EDF,MOI.EqualTo{Float64}}()) == 2
        @test MOI.get(bridge, MOI.ListOfConstraintIndices{EDF,MOI.EqualTo{Float64}}()) == bridge.ode_cons
        @test MOI.get(bridge, MOI.NumberOfConstraints{DOI.Initial{LDF},MOI.EqualTo{Float64}}()) == 2
        @test MOI.get(bridge, MOI.ListOfConstraintIndices{DOI.Initial{LDF},MOI.EqualTo{Float64}}()) == bridge.ic_cons
        @test_throws MOI.GetAttributeNotAllowed MOI.get(model, MOI.ObjectiveFunction{typeof(bolza)}(), bridge)

        MOI.delete(model, bridge)
        @test model.deleted == vcat(bridge.ode_cons, bridge.ic_cons)
    end

    @testset "MultiPhaseToSinglePhaseBridge" begin
        linkage = DOI.Linkage(lin_1, lin_2)
        S = MOI.EqualTo{Float64}
        @test MOI.supports_constraint(DOI.Bridges.MultiPhaseToSinglePhaseBridge{Float64}, typeof(linkage), S)
        BT = MOI.Bridges.Constraint.concrete_bridge_type(
            DOI.Bridges.MultiPhaseToSinglePhaseBridge{Float64}, typeof(linkage), S)
        @test BT == DOI.Bridges.MultiPhaseToSinglePhaseBridge{Float64,LDF}
        @test MOI.Bridges.added_constrained_variable_types(BT) == [(MOI.Reals,)]
        @test MOI.Bridges.added_constraint_types(BT) == [(NBF, S)]

        model = RecordingModel()
        bridge = MOI.Bridges.Constraint.bridge_constraint(BT, model, linkage, MOI.EqualTo(0.0))

        f_final, s_final = model.constraints[bridge.final_con.value]
        f_initial, s_initial = model.constraints[bridge.initial_con.value]
        @test bridge.slack == MOI.VariableIndex(1)
        @test f_final.head == :- && f_initial.head == :-
        @test f_final.args[1] isa DOI.Final && f_final.args[1].dyn_fun === lin_1
        @test f_initial.args[1] isa DOI.Initial && f_initial.args[1].dyn_fun === lin_2
        @test f_final.args[2] == bridge.slack && f_initial.args[2] == bridge.slack
        @test s_final == MOI.EqualTo(0.0) && s_initial == MOI.EqualTo(0.0)

        f = MOI.get(model, MOI.ConstraintFunction(), bridge)
        @test f isa DOI.Linkage
        @test f.dyn_fun_final === lin_1 && f.dyn_fun_initial === lin_2
        @test MOI.get(model, MOI.ConstraintSet(), bridge) == MOI.EqualTo(0.0)

        @test MOI.get(bridge, MOI.NumberOfVariables()) == 1
        @test MOI.get(bridge, MOI.ListOfVariableIndices()) == [bridge.slack]
        @test MOI.get(bridge, MOI.NumberOfConstraints{NBF,S}()) == 2
        @test MOI.get(bridge, MOI.ListOfConstraintIndices{NBF,S}()) == [bridge.final_con, bridge.initial_con]

        MOI.delete(model, bridge)
        @test model.deleted == Any[bridge.final_con, bridge.initial_con, bridge.slack]
    end

    @testset "PhaseNormalizationBridge" begin
        S = MOI.LessThan{Float64}
        @test MOI.supports_constraint(DOI.Bridges.PhaseNormalizationBridge{Float64}, DOI.Final{DOI.PhaseIndex}, S)
        @test !MOI.supports_constraint(
            DOI.Bridges.PhaseNormalizationBridge{Float64}, DOI.Final{DOI.PhaseIndex}, MOI.EqualTo{Float64})
        BT = MOI.Bridges.Constraint.concrete_bridge_type(
            DOI.Bridges.PhaseNormalizationBridge{Float64}, DOI.Final{DOI.PhaseIndex}, S)
        @test BT == DOI.Bridges.PhaseNormalizationBridge{Float64,S}
        @test MOI.Bridges.added_constrained_variable_types(BT) == [(MOI.Reals,)]
        @test MOI.Bridges.added_constraint_types(BT) == [(MOI.VariableIndex, S), (EDF, MOI.EqualTo{Float64})]

        model = RecordingModel()
        ode_1 = MOI.add_constraint(model, DOI.ExplicitDifferentialFunction(y_1, d_1), MOI.EqualTo(0.0))
        ode_2 = MOI.add_constraint(model, DOI.ExplicitDifferentialFunction(y_2, d_2), MOI.EqualTo(0.0))
        bridge = MOI.Bridges.Constraint.bridge_constraint(BT, model, DOI.Final(t_1), MOI.LessThan(2500.0))

        @test bridge.phase == t_1
        @test (bridge.t_0, bridge.t_f) == (MOI.VariableIndex(1), MOI.VariableIndex(2))
        @test model.constraints[bridge.t_f_bound_con.value] == (bridge.t_f, MOI.LessThan(2500.0))

        @test MOI.Bridges.needs_final_touch(bridge)
        MOI.Bridges.final_touch(bridge, model)
        @test bridge.scaled_dif_cons == [ode_1]
        f_1 = model.constraints[ode_1.value][1]
        @test f_1.dyn_var == y_1
        @test f_1.dyn_fun.head == :*
        @test f_1.dyn_fun.args[2] === d_1
        dt = f_1.dyn_fun.args[1]
        @test dt isa MOI.ScalarNonlinearFunction
        @test dt.head == :- && dt.args == Any[bridge.t_f, bridge.t_0]
        @test DOI.phase_index(f_1) == t_1
        @test model.constraints[ode_2.value][1].dyn_fun === d_2

        @test MOI.get(bridge, MOI.NumberOfVariables()) == 2
        @test MOI.get(bridge, MOI.ListOfVariableIndices()) == [bridge.t_0, bridge.t_f]
        @test MOI.get(bridge, MOI.NumberOfConstraints{MOI.VariableIndex,S}()) == 1
        @test MOI.get(bridge, MOI.ListOfConstraintIndices{MOI.VariableIndex,S}()) == [bridge.t_f_bound_con]

        MOI.delete(model, bridge)
        @test model.deleted == Any[bridge.t_f_bound_con, bridge.t_f, bridge.t_0]
    end

    @testset "add_all_bridges" begin
        model = MOI.Bridges.LazyBridgeOptimizer(MOI.Utilities.Model{Float64}())
        DOI.Bridges.add_all_bridges(model, Float64)
        @test MOI.Bridges.has_bridge(model, DOI.Bridges.LagrangeToMayerBridge{Float64})
        @test MOI.Bridges.has_bridge(model, DOI.Bridges.MultiPhaseToSinglePhaseBridge{Float64})
        @test MOI.Bridges.has_bridge(model, DOI.Bridges.PhaseNormalizationBridge{Float64})
    end

end
