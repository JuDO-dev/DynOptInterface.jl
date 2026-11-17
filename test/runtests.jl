import DynOptInterface as DOI
import MathOptInterface as MOI
using Test

@testset "DynOptInterface" begin
    include("phases.jl")
    include("dynamic_variables.jl")
    include("functions.jl")
    include("options.jl")
    include("bridges.jl")
end
