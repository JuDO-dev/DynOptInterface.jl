@testset "NonlinearAlgebraicFunction" begin
    
    t = DOI.DomainIndex(1)
    
    @test_nowarn DOI.NonlinearAlgebraicFunction(:call, [2.0], t)
    @test_throws ErrorException DOI.NonlinearAlgebraicFunction(:call, [1+2im], t)

    x = MOI.VariableIndex(1)
    @test_nowarn DOI.NonlinearAlgebraicFunction(:call, [x], t)

    t_2 = DOI.DomainIndex(2)
    @test_nowarn DOI.NonlinearAlgebraicFunction(:call, [t], t)
    @test_throws ErrorException DOI.NonlinearAlgebraicFunction(:+, [t, t_2], t)

    y = DOI.DynamicVariableIndex(1, t)
    y_2 = DOI.DynamicVariableIndex(2, t_2)
    @test_nowarn DOI.NonlinearAlgebraicFunction(:call, [y], t)
    @test_throws ErrorException DOI.NonlinearAlgebraicFunction(:call, [y_2], t)

    a = DOI.NonlinearAlgebraicFunction(:call, [y], t)
    @test_nowarn DOI.NonlinearAlgebraicFunction(:call, [a], t)
    @test_throws ErrorException DOI.NonlinearAlgebraicFunction(:call, [a], t_2)

end