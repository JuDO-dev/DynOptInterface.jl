@testset "Dynamic Variables" begin
    
    t_1 = DOI.PhaseIndex(1)
    y_1 = DOI.DynamicVariableIndex(1, t_1)
    @test y_1.value == 1
    @test DOI.phase_index(y_1) == t_1

    struct DynVarLessModel <: MOI.ModelLike end
    model = DynVarLessModel()

    @test DOI.supports_dynamic_variable(model) == false
    @test_throws DOI.AddDynamicVariableNotAllowed DOI.add_dynamic_variable(model, t_1)
    @test MOI.is_valid(model, y_1) == false
    @test_throws MOI.UnsupportedAttribute MOI.set(model, MOI.VariableName(), y_1, "State")

    struct DynVarModel <: MOI.ModelLike end
    MOI.supports(::DynVarModel, ::MOI.VariableName, ::Type{DOI.DynamicVariableIndex}) = true
    model = DynVarModel()

    @test_throws MOI.SetAttributeNotAllowed MOI.set(model, MOI.VariableName(), y_1, "State")

end