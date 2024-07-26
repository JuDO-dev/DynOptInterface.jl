module DynOptInterface

import MathOptInterface as MOI

include("dynamic_functions/abstraction.jl")
include("dynamic_functions/phases.jl")
include("dynamic_functions/dynamic_variables.jl")
include("dynamic_functions/expressions.jl")
include("dynamic_functions/derivatives.jl")

include("boundary_functions.jl")

include("nonlinear_support.jl")

include("solutions.jl")

end