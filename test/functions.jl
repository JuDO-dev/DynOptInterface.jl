# Return the text/plain representation of `x`.
show_str(x) = sprint(show, MIME"text/plain"(), x)

@testset "Dynamic and Boundary Functions" begin

    t_1, t_2 = DOI.PhaseIndex(1), DOI.PhaseIndex(2)
    y_1, y_2 = DOI.DynamicVariableIndex(1, t_1), DOI.DynamicVariableIndex(2, t_1)
    z_1 = DOI.DynamicVariableIndex(3, t_2)

    @testset "Linear and quadratic" begin
        lin = DOI.LinearDynamicFunction([DOI.LinearDynamicTerm(2.0, y_1), DOI.LinearDynamicTerm(3.0, y_2)])
        @test lin isa DOI.AbstractDynamicFunction
        @test DOI.phase_index(lin) == t_1
        @test show_str(lin) == "2.0 DOI.DynamicVariableIndex(1) + 3.0 DOI.DynamicVariableIndex(2)"
        @test_throws DOI.NonUniquePhaseError DOI.LinearDynamicFunction(
            [DOI.LinearDynamicTerm(1.0, y_1), DOI.LinearDynamicTerm(1.0, z_1)])

        quad = DOI.PureQuadraticDynamicFunction(
            [DOI.PureQuadraticDynamicTerm(1.0, y_1, y_2), DOI.PureQuadraticDynamicTerm(4.0, y_2, y_2)])
        @test DOI.phase_index(quad) == t_1
        @test show_str(quad) == "1.0 DOI.DynamicVariableIndex(1) DOI.DynamicVariableIndex(2) + " *
                                "4.0 DOI.DynamicVariableIndex(2) DOI.DynamicVariableIndex(2)"
        @test_throws DOI.NonUniquePhaseError DOI.PureQuadraticDynamicTerm(1.0, y_1, z_1)
        z_2 = DOI.DynamicVariableIndex(4, t_2)
        @test_throws DOI.NonUniquePhaseError DOI.PureQuadraticDynamicFunction(
            [DOI.PureQuadraticDynamicTerm(1.0, y_1, y_2), DOI.PureQuadraticDynamicTerm(1.0, z_1, z_2)])
    end

    @testset "Nonlinear and differential" begin
        nl = DOI.NonlinearDynamicFunction(:sin, Any[y_1], t_1)
        @test DOI.phase_index(nl) == t_1
        @test show_str(nl) == "sin(DOI.DynamicVariableIndex(1))"
        @test show_str(DOI.NonlinearDynamicFunction(:*, Any[2.0, z_1], t_2)) == "*(2.0, DOI.DynamicVariableIndex(3))"

        der = DOI.Derivative(y_1)
        @test DOI.phase_index(der) == t_1
        @test show_str(der) == "DOI.Derivative(DOI.DynamicVariableIndex(1))"

        edf = DOI.ExplicitDifferentialFunction(y_1, nl)
        @test DOI.phase_index(edf) == t_1
        @test show_str(edf) == "DOI.Derivative(DOI.DynamicVariableIndex(1)) - (sin(DOI.DynamicVariableIndex(1)))"
        @test_throws DOI.NonUniquePhaseError DOI.ExplicitDifferentialFunction(z_1, nl)
    end

    @testset "Boundary functions" begin
        nl = DOI.NonlinearDynamicFunction(:sin, Any[y_1], t_1)
        nl_2 = DOI.NonlinearDynamicFunction(:*, Any[2.0, z_1], t_2)
        lin = DOI.LinearDynamicFunction([DOI.LinearDynamicTerm(2.0, y_1), DOI.LinearDynamicTerm(3.0, y_2)])

        initial = DOI.Initial(lin)
        final = DOI.Final(y_1)
        linkage = DOI.Linkage(y_1, z_1)
        integral = DOI.Integral(nl)
        multi = DOI.MultiPhaseIntegral([nl, nl_2])
        bolza = DOI.Bolza(final, integral)
        nbf = DOI.NonlinearBoundaryFunction(:+, Any[DOI.Initial(y_1), final])
        for f in (initial, final, linkage, integral, multi, bolza, nbf)
            @test f isa DOI.AbstractBoundaryFunction
            @test !(f isa DOI.AbstractDynamicFunction)
        end

        @test show_str(initial) == "DOI.Initial(2.0 DOI.DynamicVariableIndex(1) + 3.0 DOI.DynamicVariableIndex(2))"
        @test show_str(final) == "DOI.Final(DOI.DynamicVariableIndex(1))"
        @test show_str(linkage) == "(DOI.Final(DOI.DynamicVariableIndex(1)) - DOI.Initial(DOI.DynamicVariableIndex(3)))"
        @test show_str(integral) == "∫(sin(DOI.DynamicVariableIndex(1)))"
        @test show_str(multi) == "(∫(sin(DOI.DynamicVariableIndex(1))) + ∫(*(2.0, DOI.DynamicVariableIndex(3))))"
        @test show_str(bolza) == "(DOI.Final(DOI.DynamicVariableIndex(1)) + ∫(sin(DOI.DynamicVariableIndex(1))))"
        @test show_str(nbf) == "+(DOI.Initial(DOI.DynamicVariableIndex(1)), DOI.Final(DOI.DynamicVariableIndex(1)))"

        @test DOI.Final(t_1).dyn_fun == t_1
        @test DOI.Bolza(final, multi).integral.dyn_funs == [nl, nl_2]
    end

end
