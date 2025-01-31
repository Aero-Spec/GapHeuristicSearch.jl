using Test
using GapHeuristicSearch
using POMDPs
using POMDPTools

# Define simple test POMDP type
struct SimplePOMDP <: POMDP{Int, Int, Int} end

POMDPs.states(::SimplePOMDP) = [1, 2]
POMDPs.actions(::SimplePOMDP) = [1, 2]
POMDPs.observations(::SimplePOMDP) = [1, 2]
POMDPs.initialstate(::SimplePOMDP) = Deterministic(1)
POMDPs.discount(::SimplePOMDP) = 0.9
POMDPs.transition(::SimplePOMDP, s, a) = Deterministic(s)
POMDPs.observation(::SimplePOMDP, a, sp) = Deterministic(a)
POMDPs.reward(::SimplePOMDP, s, a, sp) = 1.0

# Simple updater for deterministic belief handling
struct SimpleUpdater <: Updater end
POMDPs.initialize_belief(::SimpleUpdater, state) = state
POMDPs.update(::SimpleUpdater, b, a, o) = b

@testset "GapHeuristicSearch.jl Basic Tests" begin
    solver = GapHeuristicSearchSolver(
        SimpleUpdater();
        π = nothing,
        Rmax = 10.0,
        uhi_func = (pomdp, b) -> 10.0,
        ulo_func = (pomdp, b) -> 0.0,
        delta = 0.01,
        k_max = 10,
        d_max = 5,
        nsamps = 10,
        max_steps = 10
    )

    @test isa(solver, GapHeuristicSearchSolver)
    @test solver.Rmax == 10.0
    @test solver.delta == 0.01
    @test solver.d_max == 5

    pomdp = SimplePOMDP()
    planner = solve(solver, pomdp)
    @test isa(planner, GapHeuristicSearchPlanner)

    B, A, O = get_type(planner)
    @test B == Deterministic{Int}
    @test A == Int
    @test O == Int

    b = Deterministic(1)
    a = action(planner, b)
    @test isa(a, Int)
end
