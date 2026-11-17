struct DynVarlessModel <: MOI.ModelLike end

struct DynVarNameModel <: MOI.ModelLike end
MOI.supports(::DynVarNameModel, ::DOI.DynamicVariableName) = true

@testset "Dynamic Variables" begin

    t_1 = DOI.PhaseIndex(1)
    y_1 = DOI.DynamicVariableIndex(1, t_1)
    @test y_1.value == 1
    @test y_1 isa DOI.AbstractDynamicFunction
    @test DOI.phase_index(y_1) == t_1
    @test sprint(show, MIME"text/plain"(), y_1) == "DOI.DynamicVariableIndex(1)"

    model = DynVarlessModel()
    @test DOI.supports_dynamic_variables(model) == false
    @test_throws DOI.AddDynamicVariableNotAllowedError DOI.add_dynamic_variable(model, t_1)
    @test MOI.operation_name(DOI.AddDynamicVariableNotAllowedError("")) == "Adding a dynamic variable"
    @test MOI.is_valid(model, y_1) == false
    @test DOI.InvalidDynamicVariableError(y_1).dyn_var == y_1
    @test DOI.UnsupportedDynamicVariablesError("") isa MOI.UnsupportedError

    for attr in (DOI.DynamicVariableName(), DOI.DynamicVariableStart(), DOI.DynamicVariableSolution())
        @test attr isa DOI.AbstractDynamicVariableAttribute
        @test MOI.supports(model, attr) == false
    end
    @test_throws ArgumentError MOI.set(model, DOI.DynamicVariableName(), y_1, "State")
    @test_throws ArgumentError MOI.get(model, DOI.DynamicVariableName(), y_1)

    model = DynVarNameModel()
    @test MOI.supports(model, DOI.DynamicVariableName()) == true
    @test_throws ArgumentError MOI.set(model, DOI.DynamicVariableName(), y_1, "State")

end
