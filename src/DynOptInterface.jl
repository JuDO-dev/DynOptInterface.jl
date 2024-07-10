module DynOptInterface

import MathOptInterface as MOI

include("phases.jl")
include("dynamic_variables.jl")
include("nonlinear_support.jl")
include("dynamic_functions.jl")
include("boundary_functions.jl")
include("integral_functions.jl")


end