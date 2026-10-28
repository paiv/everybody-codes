#!/usr/bin/env julia
using JuMP
import HiGHS


function parserule(text)
    a,q,b = split(text, r"\b")
    x,y = [parse(Int, i) for i in [a, b]]
    return q=="<" ? (x,y) : (y,x)
end


function parserow(text)
    parserule.(split(text))
end


function parsenotes(text)
    parserow.(split(text, '\n', keepempty=false))
end


function solve(rs, n)
    model = Model(optimizer_with_attributes(HiGHS.Optimizer, MOI.Silent()=>true))
    @variable(model, x[1:n], Int)
    @objective(model, Min, evalpoly(10, x))
    @constraint(model, x .>= 1)
    for (i,j) in rs
        @constraint(model, x[i]+1 <= x[j])
    end
    optimize!(model)
    assert_is_solved_and_feasible(model)
    ix = Int.(value(x))
    indexin(1:n, ix)
end


function partn(data)
    sum(parsenotes(data)) do rules
        n = maximum(t for p in rules for t in p)
        v = solve(rules, n)
        evalpoly(10, v)
    end
end


const part1 = partn
const part2 = partn
const part3 = partn


data = raw"
4<3 2<5 3>1 1>2 1<5 4<1 3>2 4<2 3>5 4<5
4>1 2>1 3>2 1<5 4>5 2<5 3>1 4>3 2<4 5<3
5>1 5>2 4>1 2<4 3>2 3<4 1>2 3>5 1<3 4>5
"
@assert part1(data) == 122157


data = raw"
2<5 3>1 1>2 1<5 4<1 3>2 4<2 3>5 4<5
2>1 3>2 1<5 4>5 2<5 3>1 4>3 2<4 5<3
5>1 5>2 4>1 3>2 3<4 1>2 3>5 1<3 4>5
"
@assert part2(data) == 122157


data = raw"
3>1 1>2 1<5 4<2 3>5
2>1 2<5 3>1 4>3 2<4 5<3
5>1 3<4 1>2 3>5
"
@assert part3(data) == 122157


data = readchomp("q02_p1.txt")
println("part1: ", part1(data))
data = readchomp("q02_p2.txt")
println("part2: ", part2(data))
data = readchomp("q02_p3.txt")
println("part3: ", part3(data))
