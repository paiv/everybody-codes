#!/usr/bin/env julia
using JuMP
import HiGHS


function parserow(text)
    s, x = [reverse(parse.(Int, collect(w)))
        for w in split(chopprefix(text, r"ISO.?-"))]
    w = [d^(i-1) for (i,d) in
        enumerate(Iterators.take(Iterators.cycle(s), length(x)))]
    return (w, x)
end


function parsenotes(text)
    parserow.(split(text, '\n', keepempty=false))
end


applyiso(iso, x) = iso' * x


function solveiso(iso, n, k)
    model = Model(optimizer_with_attributes(HiGHS.Optimizer, MOI.Silent()=>true))
    @variable(model, x[1:n], Int)
    @objective(model, Min, evalpoly(10, x))
    @constraint(model, 0 .<= x .<= 9)
    @constraint(model, applyiso(iso, x) == k)
    optimize!(model)
    assert_is_solved_and_feasible(model)
    round.(Int, value(x))
end


function isvalid(iso, x)
    m = applyiso(iso, x)
    k = solveiso(iso, length(x), m)
    evalpoly(10, x) <= evalpoly(10, k)
end


function solve(f, data)
    sum(applyiso(a,b) for (a,b) in parsenotes(data) if f(a,b))
end


part1(data) = solve(!==, data)
part2(data) = solve(!==, data)
part3(data) = solve(isvalid, data)


data = raw"
ISO-3210 7654
ISO-8742 2468
ISO-1111 1111
"
@assert part1(data) == 1478


data = raw"
ISO-3210 7654
ISO-8742 2468
ISO-1 1111
ISO-13 777
ISO-34 140856
ISO-789 2465112
ISO-2341 945
"
@assert part2(data) == 1161463


data = raw"
ISO2-3 23
ISO2-61 149
ISO2-978 99
ISO2-5887 5923
ISO2-76988 123749
ISO2-435657 929977
ISO2-3949 870737
"
@assert part3(data) == 50987


println("part1: ", part1(readchomp("q03_p1.txt")))
println("part2: ", part2(readchomp("q03_p2.txt")))
println("part3: ", part3(readchomp("q03_p3.txt")))
