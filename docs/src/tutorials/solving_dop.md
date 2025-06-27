```@meta
CurrentModule = DynOptInterface
```

```julia
import MathOptInterface as MOI
import DynOptInterface as DOI
using Interesso
using Plots

# Problem Constants
const g = 9.81
const l = 0.5
const m_1 = 1.0
const m_2 = 0.3
const t_0 = 0.0
const t_f = 2.0
const u_max = 20.0
const r_max = 2.0
const NDF = DOI.NonlinearDynamicFunction

# Warm-starts
struct LinearInterpolant <: DOI.AbstractDynamicSolution
    y_a::Float64
    y_b::Float64
end
(li::LinearInterpolant)(t::Real) = li.y_a + (t - t_0) * (li.y_b - li.y_a) / (t_f - t_0)

# Problem Solver

function cart_pole(model::Interesso.Optimizer)

    @assert MOI.is_empty(model)

    ## Time as a phase
    t = DOI.add_phase(model)
    MOI.add_constraint(model, DOI.Initial(t), MOI.EqualTo(0.0))
    MOI.add_constraint(model, DOI.Final(t), MOI.EqualTo(2.0))

    ## Input Dynamic Variable
    u = DOI.add_dynamic_variable(model, t)

    ## State Dynamic Variables
    r = DOI.add_dynamic_variable(model, t)
    θ = DOI.add_dynamic_variable(model, t)
    v = DOI.add_dynamic_variable(model, t)
    ω = DOI.add_dynamic_variable(model, t)

    ## Inequality constraint
    MOI.add_constraint(model, u, MOI.Interval(-u_max, u_max))
    MOI.add_constraint(model, r, MOI.Interval(0.0, r_max))

    ## Boundary Conditions
    MOI.add_constraint(model, DOI.Initial(r), MOI.EqualTo(0.0))
    MOI.add_constraint(model, DOI.Initial(θ), MOI.EqualTo(0.0))
    MOI.add_constraint(model, DOI.Initial(v), MOI.EqualTo(0.0))
    MOI.add_constraint(model, DOI.Initial(ω), MOI.EqualTo(0.0))


    MOI.add_constraint(model, DOI.Final(r), MOI.EqualTo(1.0))
    MOI.add_constraint(model, DOI.Final(θ), MOI.EqualTo(1.0 * pi))
    MOI.add_constraint(model, DOI.Final(v), MOI.EqualTo(0.0))
    MOI.add_constraint(model, DOI.Final(ω), MOI.EqualTo(0.0))

    # Starts
    MOI.set(model, DOI.DynamicVariableStart(), r, LinearInterpolant(0.0, 1.0))
    MOI.set(model, DOI.DynamicVariableStart(), θ, LinearInterpolant(0.0, 1.0 * pi))

    ## Differential Equations
    sinθ = NDF(:sin, [θ], t)
    cosθ = NDF(:cos, [θ], t)

    num_v = NDF(:+, [
        NDF(:*, [l*m_2, sinθ, NDF(:^, [ω, 2], t)], t),
        u,
        NDF(:*, [m_2 * g, cosθ, sinθ], t)
    ], t)
    den_v = NDF(:+, [
        m_1,
        NDF(:*, [m_2, NDF(:^, [sinθ, 2], t)], t),
    ], t)

    num_ω = NDF(:+, [
        NDF(:*, [-1.0 * l * m_2, cosθ, sinθ, NDF(:^, [ω, 2], t)], t),
        NDF(:*, [-1.0, u, cosθ], t),
        NDF(:*, [-1.0 * (m_1 + m_2) * g, sinθ], t),
    ], t)
    den_ω = NDF(:+, [
        l * m_1,
        NDF(:*, [l * m_2, NDF(:^, [sinθ, 2], t)], t),
    ], t)

    MOI.add_constraint(
        model,
        DOI.ExplicitDifferentialFunction(
            r,
            NDF(:+, Any[v], t),            
        ),
        MOI.EqualTo(0.0),
    )
    MOI.add_constraint(
        model,
        DOI.ExplicitDifferentialFunction(
            v,
            NDF(:/, Any[num_v, den_v], t),            
        ),
        MOI.EqualTo(0.0),
    )
    MOI.add_constraint(
        model,
        DOI.ExplicitDifferentialFunction(
            θ,
            NDF(:+, Any[ω], t),            
        ),
        MOI.EqualTo(0.0),
    )
    MOI.add_constraint(
        model,
        DOI.ExplicitDifferentialFunction(
            ω,
            NDF(:/, Any[num_ω, den_ω], t),            
        ),
        MOI.EqualTo(0.0),
    )

    ## Objective Function
    MOI.set(model, MOI.ObjectiveSense(), MOI.MIN_SENSE)
    obj_fun = DOI.Bolza(
        DOI.NonlinearBoundaryFunction(:+, [0.0]),
        DOI.MultiPhaseIntegral([NDF(:^, [u, 2], t)]))#
    MOI.set(model, MOI.ObjectiveFunction{typeof(obj_fun)}(), obj_fun)

    MOI.optimize!(model)

    ## Retrieve solutions
    u_sol = MOI.get(model, DOI.DynamicVariableSolution(), u)
    r_sol = MOI.get(model, DOI.DynamicVariableSolution(), r)
    v_sol = MOI.get(model, DOI.DynamicVariableSolution(), v)

    return u_sol, r_sol, v_sol
end

model = Interesso.Optimizer(
    default_intervals=FlexibleIntervals(4, 0.5),
    default_points=LGRPoints(8),
)
u_sol, r_sol, v_sol = cart_pole(model)

plot(tau -> r_sol(tau), xlims=(t_0, t_f))
```