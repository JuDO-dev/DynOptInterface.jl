@testset "NonlinearDynamicFunction" begin
    
    t = DOI.PhaseIndex(1)
    
    @test_nowarn DOI.NonlinearDynamicFunction(:call, [2.0], t)
    @test_throws ErrorException DOI.NonlinearDynamicFunction(:call, [1+2im], t)

    x = MOI.VariableIndex(1)
    @test_nowarn DOI.NonlinearDynamicFunction(:call, [x], t)

    t_2 = DOI.PhaseIndex(2)
    @test_nowarn DOI.NonlinearDynamicFunction(:call, [t], t)
    @test_throws ErrorException DOI.NonlinearDynamicFunction(:+, [t, t_2], t)

    y = DOI.DynamicVariableIndex(1, t)
    y_2 = DOI.DynamicVariableIndex(2, t_2)
    @test_nowarn DOI.NonlinearDynamicFunction(:call, [y], t)
    @test_throws ErrorException DOI.NonlinearDynamicFunction(:call, [y_2], t)

    a = DOI.NonlinearDynamicFunction(:call, [y], t)
    @test_nowarn DOI.NonlinearDynamicFunction(:call, [a], t)
    @test_throws ErrorException DOI.NonlinearDynamicFunction(:call, [a], t_2)

end