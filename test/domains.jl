@testset "PhaseIndex" begin
    
    t_1 = DOI.PhaseIndex(1)
    @test isbits(t_1)

end

@testset "supports_phase" begin
    
    struct DummyModel <: MOI.ModelLike end
    model = DummyModel()
    @test DOI.supports_phase(model) == false

end

@testset "add_phase" begin
    
    struct DummyModel <: MOI.ModelLike end
    model = DummyModel()
    @test_throws DOI.AddPhaseNotAllowed DOI.add_phase(model)

end