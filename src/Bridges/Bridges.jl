module Bridges

import MathOptInterface as MOI
import DynOptInterface as DOI

include("lagrange_to_mayer.jl")
include("multi_to_single.jl")
include("phase_normalization.jl")

"""
    add_all_bridges(model, ::Type{T}) where {T}

Add all DOP bridges defined in this module to `model` for coefficient type `T`.

Solvers that wrap their inner optimizer with `MOI.Bridges.full_bridge_optimizer`
and implement `MOI.get(::Optimizer, ::MOI.Bridges.ListOfNonstandardBridges{T})`
to return these bridge types will have DOP reformulations applied automatically
along the shortest path in the bridge graph.
"""
function add_all_bridges(model, ::Type{T}) where {T}
    MOI.Bridges.add_bridge(model, LagrangeToMayerBridge{T})
    MOI.Bridges.add_bridge(model, MultiPhaseToSinglePhaseBridge{T})
    MOI.Bridges.add_bridge(model, PhaseNormalizationBridge{T})
    return
end

end
