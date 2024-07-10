@testset "DynamicVariableIndex" begin
    
    t_1 = DOI.PhaseIndex(1)
    y_1 = DOI.DynamicVariableIndex(1, t_1)
    @test isbits(y_1)

end

@testset "supports_dynamic_variable" begin
    
    struct DummyModel <: MOI.ModelLike end
    model = DummyModel()
    @test DOI.supports_dynamic_variable(model) == false

end

@testset "add_dynamic_variable" begin
    
    struct DummyModel <: MOI.ModelLike end
    model = DummyModel()
    @test_throws DOI.AddDynamicVariableNotAllowed DOI.add_dynamic_variable(model)

end