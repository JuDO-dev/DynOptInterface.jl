module DynOptInterface

import MathOptInterface as MOI

include("dynamic_variables.jl")
include("algebraic_functions.jl")
include("differential_functions.jl")
include("boundary_functions.jl")
include("integral_functions.jl")


end