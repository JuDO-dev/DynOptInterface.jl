@testset "Phases" begin
    
    t_1 = DOI.PhaseIndex(1)
    @test t_1.value == 1
    @test DOI.phase_index(t_1) == t_1

    struct PhaselessModel <: MOI.ModelLike end
    model = PhaselessModel()

    @test DOI.supports_phase(model) == false
    @test_throws DOI.AddPhaseNotAllowed DOI.add_phase(model)
    @test MOI.is_valid(model, t_1) == false
    @test_throws MethodError MOI.set(model, MOI.VariableName(), t_1, "Time")

    struct PhaseModel <: MOI.ModelLike end
    MOI.supports(::PhaseModel, ::MOI.VariableName, ::Type{DOI.PhaseIndex}) = true
    model = PhaseModel()

    @test_throws MethodError MOI.set(model, MOI.VariableName(), t_1, "Time")
    
end