#!/usr/bin/env julia


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


function lt1(rs, x, y)
    for (a,b) in rs
        if x==a && y==b
            return true
        elseif x==b && y==a
            return false
        end
    end
end


function part1(data)
    sum(parsenotes(data)) do rules
        lt = (a,b) -> lt1(rules, a, b)
        v = [1,2,3,4,5]
        sort!(v, lt=lt)
        evalpoly(10, v)
    end
end


function solve(rs, n)
    edge = zeros(Bool, n, n)
    for (i,j) in rs
        edge[i, j] = true
    end
    fringe = findall(!any, eachcol(edge))
    res = Int[]
    while !isempty(fringe)
        p = pop!(fringe)
        push!(res, p)
        for m in findall(edge[p,:])
            edge[p, m] = false
            if !any(edge[:,m])
                push!(fringe, m)
            end
        end
    end
    return res
end


function partn(data)
    sum(parsenotes(data)) do rules
        n = maximum(t for p in rules for t in p)
        v = solve(rules, n)
        evalpoly(10, v)
    end
end


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
