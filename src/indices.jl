"""
    DomainIndex

A type-safe wrapper for `Int64` for use in referencing domains.
"""
struct DomainIndex
    value::Int64
end

"""
    AlgebraicIndex

A type-safe wrapper for `Int64` for use in referencing algebraic variables.
"""
struct AlgebraicIndex
    value::Int64
    domain::DomainIndex
end

"""
    DifferentiableIndex

A type-safe wrapper for `Int64` for use in referencing differentiable variables.
"""
struct DifferentiableIndex
    value::Int64
    domain::DomainIndex
end