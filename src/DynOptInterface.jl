module DynOptInterface

import MathOptInterface as MOI

abstract type AbstractDomain end

include("domains.jl")

end