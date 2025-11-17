#!/usr/bin/env julia


function part1(data)
    s = strip(data)
    n = length(s)
    p = 1
    ans = 0
    for x in Iterators.cycle("RGB")
        p > n && break
        ans += 1
        while p < n && s[p] == x
            p += 1
        end
        p += 1
    end
    return ans
end


function part2(data, N=100)
    v = repeat(collect(strip(data)), N)
    ans = 0
    for x in Iterators.cycle("RGB")
        isempty(v) && break
        ans += 1
        if v[1] == x && iseven(length(v))
            popat!(v, length(v) ÷ 2 + 1)
        end
        popfirst!(v)
    end
    return ans
end


mutable struct Node
    data::Char
    left::Union{Node,Nothing}
    right::Union{Node,Nothing}
    Node(data) = new(data, nothing, nothing)
end

nodedata(node::Node) = node.data
nodedata(node::Nothing) = nothing


function Base.push!(node::Nothing, child::Node)
    child.left = nothing
    child
end


function Base.push!(node::Node, child::Node)
    node.right = child
    child.left = node
    child
end


function Base.pop!(node::Node)
    l, r = node.left, node.right
    l.right = r
    r.left = l
    return r
end


mutable struct Circle
    size::Int
    top::Union{Node,Nothing}
    mid::Union{Node,Nothing}
    Circle() = new(0, nothing, nothing)
end

Base.length(s::Circle) = s.size
Base.isempty(s::Circle) = s.size == 0


function Circle(itr)
    s = Circle()
    s.top = Node('?')
    s.mid = s.top
    p = s.top
    for c in itr
        s.size += 1
        p = push!(p, Node(c))
        if isodd(s.size)
            s.mid = s.mid.right
        end
    end
    s.mid = s.mid.right
    s.top = s.top.right
    p.right = s.top
    s.top.left = p
    return s
end


circletop(s::Circle) = nodedata(s.top)
circlemid(s::Circle) = nodedata(s.mid)

function poptop!(s::Circle)
    isnothing(s.top) && return
    s.top = pop!(s.top)
    s.size -= 1
    if isodd(s.size)
        s.mid = s.mid.right
    end
    nothing
end


function popmid!(s::Circle)
    isnothing(s.mid) && return
    s.mid = pop!(s.mid)
    s.size -= 1
    nothing
end


function part3(data, N=100000)
    v = collect(strip(data))
    s = Circle(Iterators.cycle(v, N))
    ans = 0
    for x in Iterators.cycle("RGB")
        isempty(s) && break
        ans += 1
        if circletop(s) == x && iseven(length(s))
            popmid!(s)
        end
        poptop!(s)
    end
    return ans
end


@assert part1("GRBGGGBBBRRRRRRRR") == 7

data = "BBRGGRRGBBRGGBRGBBRRBRRRBGGRRRBGBGG"
@assert part2(data, 10) == 304
@assert part2(data, 50) == 1464
@assert part2(data) == 2955


data = readchomp("q02_p1.txt")
println("part1: ", part1(data))
data = readchomp("q02_p2.txt")
println("part2: ", part2(data))
data = readchomp("q02_p3.txt")
println("part3: ", part3(data))
