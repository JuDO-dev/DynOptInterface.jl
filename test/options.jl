struct LinearSolution <: DOI.AbstractDynamicSolution
    slope::Float64
end
(s::LinearSolution)(τ::Real) = s.slope * τ

struct UnevaluatedSolution <: DOI.AbstractDynamicSolution end

@testset "Argument Support and Discretization Options" begin

    model = PhaselessModel()
    @test DOI.supports_objective_argument(
        model, DOI.NonlinearBoundaryFunction, DOI.Final{DOI.DynamicVariableIndex}) == false
    @test DOI.supports_constraint_argument(
        model, DOI.NonlinearBoundaryFunction, MOI.EqualTo{Float64}, DOI.Final{DOI.DynamicVariableIndex}) == false
    @test DOI.UnsupportedObjectiveArgument{DOI.NonlinearBoundaryFunction,DOI.Final}("") isa MOI.UnsupportedError
    @test DOI.UnsupportedConstraintArgument{DOI.NonlinearBoundaryFunction,MOI.EqualTo{Float64},DOI.Final}("") isa
          MOI.UnsupportedError

    @test LinearSolution(2.0)(1.5) == 3.0
    @test UnevaluatedSolution()(0.5) === nothing

    @test DOI.FixedIntervals(20).number == 20
    @test_throws DomainError DOI.FixedIntervals(0)
    flexible = DOI.FlexibleIntervals(4)
    @test (flexible.number, flexible.flexibility) == (4, 0.5)
    @test DOI.FlexibleIntervals(4, 1).flexibility == 1.0
    @test_throws DomainError DOI.FlexibleIntervals(1)
    @test_throws DomainError DOI.FlexibleIntervals(4, 1.5)
    @test DOI.LGRPoints(5).number == 5
    @test_throws DomainError DOI.LGRPoints(0)
    @test DOI.LGLPoints(3).number == 3
    @test_throws DomainError DOI.LGLPoints(0)
    @test DOI.DAIR(2).number == 2
    @test_throws DomainError DOI.DAIR(0)
    @test DOI.Collocation() isa DOI.AbstractMethod
    @test DOI.ExactBounds() isa DOI.AbstractBounds
    @test DOI.BernsteinBounds() isa DOI.AbstractBounds

end
