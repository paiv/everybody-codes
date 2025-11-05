#!/usr/bin/env julia


function knapsack(coins::Vector{Int}, memo::Dict{Int,Int}, goal::Int)
    goal == 0 && return 0
    get!(memo, goal) do
        r = typemax(Int)
        for w in coins
            if goal >= w
                r = min(r, 1 + knapsack(coins, memo, goal - w))
            end
        end
        return r
    end
end


function knapsack(dots::Vector{Int}, x::Int)
    m = fill(typemax(Int), x+1)
    m[1] = 0
    @inbounds for w in dots
        for i in w:x
            t = m[i+1-w]
            m[i+1] = min(m[i+1], m[i+1-w] + 1)
        end
    end
    m[x+1]
end


function solve(dots, data)
    s = parse.(Int, split(data))
    dots = sort(dots)
    [knapsack(dots, i) for i in s] |> sum
end


part1(data) = solve([1, 3, 5, 10], data)
part2(data) = solve([1, 3, 5, 10, 15, 16, 20, 24, 25, 30], data)


function beetles3(dots::Vector{Int}, memo::Dict{Int,Int}, s::Int)
    n = typemax(Int)
    for i in 0:100
        x = i + s ÷ 2 - 50
        abs(s-2x) > 100 && continue
        a = knapsack(dots, memo, x)
        b = knapsack(dots, memo, s-x)
        n = min(n, a+b)
    end
    return n
end


function part3(data)
    s = parse.(Int, split(data))
    dots = [1, 3, 5, 10, 15, 16, 20, 24, 25, 30, 37, 38, 49, 50, 74, 75, 100, 101]
    dots = sort(dots, rev=true)
    d = Dict{Int,Int}()
    beetles3.([dots], [d], s) |> sum
end


data = raw"
2
4
7
16
"
@assert part1(data) == 10


data = raw"
33
41
55
99
"
@assert part2(data) == 10


data = raw"
156488
352486
546212
"
@assert part3(data) == 10449


data = readchomp("q09_p1.txt")
println("part1: ", part1(data))
data = readchomp("q09_p2.txt")
println("part2: ", part2(data))
data = readchomp("q09_p3.txt")
println("part3: ", part3(data))
