struct PhaselessModel <: MOI.ModelLike end

struct PhaseNameModel <: MOI.ModelLike end
MOI.supports(::PhaseNameModel, ::DOI.PhaseName) = true

@testset "Phases" begin

    t_1 = DOI.PhaseIndex(1)
    @test t_1.value == 1
    @test t_1 isa DOI.AbstractDynamicFunction
    @test DOI.phase_index(t_1) == t_1
    @test sprint(show, MIME"text/plain"(), t_1) == "DOI.PhaseIndex(1)"

    model = PhaselessModel()
    @test DOI.supports_phases(model) == false
    @test_throws DOI.AddPhaseNotAllowedError DOI.add_phase(model)
    @test MOI.operation_name(DOI.AddPhaseNotAllowedError("")) == "Adding a phase"
    @test MOI.is_valid(model, t_1) == false
    @test DOI.InvalidPhaseError(t_1).phase == t_1
    @test DOI.UnsupportedPhasesError("") isa MOI.UnsupportedError

    for attr in (DOI.PhaseName(), DOI.PhaseInitialStart(), DOI.PhaseFinalStart(),
                 DOI.PhaseInitialSolution(), DOI.PhaseFinalSolution())
        @test attr isa DOI.AbstractPhaseAttribute
        @test MOI.supports(model, attr) == false
    end
    @test_throws ArgumentError MOI.set(model, DOI.PhaseName(), t_1, "Time")
    @test_throws ArgumentError MOI.get(model, DOI.PhaseName(), t_1)

    model = PhaseNameModel()
    @test MOI.supports(model, DOI.PhaseName()) == true
    @test_throws ArgumentError MOI.set(model, DOI.PhaseName(), t_1, "Time")

end
