@testset "DomainIndex" begin
    
    t_1 = DOI.DomainIndex(1)
    @test isbits(t_1)

end

@testset "supports_domain" begin
    
    struct DummyModel <: MOI.ModelLike end
    model = DummyModel()
    @test DOI.supports_domain(model) == false

end

@testset "add_domain" begin
    
    struct DummyModel <: MOI.ModelLike end
    model = DummyModel()
    @test_throws DOI.AddDomainNotAllowed DOI.add_domain(model)

end