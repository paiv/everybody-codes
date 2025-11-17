#!/usr/bin/env julia

mutable struct Node{T}
    data::T
    parent::Union{Node{T},Nothing}
    left::Union{Node{T},Nothing}
    right::Union{Node{T},Nothing}
    function Node{T}(data, parent=nothing, left=nothing, right=nothing) where T
        new{T}(data, parent, left, right)
    end
end

Node(data) = Node{typeof(data)}(data)


function Base.push!(node::Node, child)
    if child.data < node.data
        if isnothing(node.left)
            node.left = child
            child.parent = node
        else
            push!(node.left, child)
        end
    else
        if isnothing(node.right)
            node.right = child
            child.parent = node
        else
            push!(node.right, child)
        end
    end
end


_node(id, value, label) = Node((value, id, label))
_node(id, data) = _node(id, data...)


function Base.show(io::IO, node::Node)
    function inner(node, level)
        isnothing(node) && return ""
        s = node.data
        w = "  " ^ level
        l = inner(node.left, level+1)
        r = inner(node.right, level+1)
        "$w$s\n$l$r"  
    end
    write(io, inner(node, 0))
end


function _nodeid(node)
    isnothing(node) && return
    _,i,_ = node.data
    return i
end


function _slice(root::Node)
    res = String[]
    function inner(node, level)
        isnothing(node) && return
        _,_,s = node.data
        if level > length(res)
            push!(res, "")
        end
        res[level] *= s
        inner(node.left, level+1)
        inner(node.right, level+1)
    end
    inner(root, 1)
    return res
end


function _findid(node::Union{Node,Nothing}, id::Int)
    isnothing(node) && return []
    _nodeid(node) == id && return [node]
    a = _findid(node.left, id)
    b = _findid(node.right, id)
    [a; b]
end


function _replace!(node::Node, child::Node, newchild::Node)
    if node.left === child
        node.left = newchild
        newchild.parent = node
    elseif node.right === child
        node.right = newchild
        newchild.parent = node
    end
    nothing
end


function _swaptree!(a::Node, b::Node)
    @assert a !== b
    if a.parent === b.parent
        p = a.parent
        p.left, p.right = p.right, p.left
    else
        p = b.parent
        _replace!(a.parent, a, b)
        _replace!(p, b, a)
    end
end


function solve(swap, data)
    root = _node(0, -1, "")
    for line in split(data, '\n', keepempty=false)
        if startswith(line, "ADD")
            i, = [parse(Int, m[1]) for m in eachmatch(r"id=(\d+)",line)]
            l,r = [(parse(Int,m[1]), String(m[2])) for m in eachmatch(r"\[(\d+),(.)\]", line)]
            if i == 1
                root.left = _node(i, l)
                root.right = _node(i, r)
                root.left.parent = root.right.parent = root
            else
                push!(root.left, _node(i, l))
                push!(root.right, _node(i, r))
            end
        elseif startswith(line, "SWAP")
            i, = [parse(Int, m[1]) for m in eachmatch(r"(\d+)",line)]
            l, r = _findid(root, i)
            swap(l, r)
        end
    end
    s = argmax(length, _slice(root.left))
    t = argmax(length, _slice(root.right))
    s * t
end


part1(data) = solve(nothing, data)
part3(data) = solve(_swaptree!, data)

function part2(data)
    solve(data) do l, r
        l.data, r.data = r.data, l.data
    end
end


data = raw"
ADD id=1 left=[10,A] right=[30,H]
ADD id=2 left=[15,D] right=[25,I]
ADD id=3 left=[12,F] right=[31,J]
ADD id=4 left=[5,B] right=[27,L]
ADD id=5 left=[3,C] right=[28,M]
ADD id=6 left=[20,G] right=[32,K]
ADD id=7 left=[4,E] right=[21,N]
"
@assert part1(data) == "CFGNLK"


data = raw"
ADD id=1 left=[160,E] right=[175,S]
ADD id=2 left=[140,W] right=[224,D]
ADD id=3 left=[122,U] right=[203,F]
ADD id=4 left=[204,N] right=[114,G]
ADD id=5 left=[136,V] right=[256,H]
ADD id=6 left=[147,G] right=[192,O]
ADD id=7 left=[232,I] right=[154,K]
ADD id=8 left=[118,E] right=[125,Y]
ADD id=9 left=[102,A] right=[210,D]
ADD id=10 left=[183,Q] right=[254,E]
ADD id=11 left=[146,E] right=[148,C]
ADD id=12 left=[173,Y] right=[299,S]
ADD id=13 left=[190,B] right=[277,B]
ADD id=14 left=[124,T] right=[142,N]
ADD id=15 left=[153,R] right=[133,M]
ADD id=16 left=[252,D] right=[276,M]
ADD id=17 left=[258,I] right=[245,P]
ADD id=18 left=[117,O] right=[283,!]
ADD id=19 left=[212,O] right=[127,R]
ADD id=20 left=[278,A] right=[169,C]
"
@assert part1(data) == "EVERYBODYCODES"


data = raw"
ADD id=1 left=[10,A] right=[30,H]
ADD id=2 left=[15,D] right=[25,I]
ADD id=3 left=[12,F] right=[31,J]
ADD id=4 left=[5,B] right=[27,L]
ADD id=5 left=[3,C] right=[28,M]
SWAP 1
SWAP 5
ADD id=6 left=[20,G] right=[32,K]
ADD id=7 left=[4,E] right=[21,N]
"
@assert part2(data) == "MGFLNK"


data = raw"
ADD id=1 left=[10,A] right=[30,H]
ADD id=2 left=[15,D] right=[25,I]
ADD id=3 left=[12,F] right=[31,J]
ADD id=4 left=[5,B] right=[27,L]
ADD id=5 left=[3,C] right=[28,M]
SWAP 1
SWAP 5
ADD id=6 left=[20,G] right=[32,K]
ADD id=7 left=[4,E] right=[21,N]
SWAP 2
"
@assert part3(data) == "DJMGL"


data = raw"
ADD id=1 left=[10,A] right=[30,H]
ADD id=2 left=[15,D] right=[25,I]
ADD id=3 left=[12,F] right=[31,J]
ADD id=4 left=[5,B] right=[27,L]
ADD id=5 left=[3,C] right=[28,M]
SWAP 1
SWAP 5
ADD id=6 left=[20,G] right=[32,K]
ADD id=7 left=[4,E] right=[21,N]
SWAP 2
SWAP 5
"
@assert part3(data) == "DJCGL"


data = readchomp("q02_p1.txt")
println("part1: ", part1(data))
data = readchomp("q02_p2.txt")
println("part2: ", part2(data))
data = readchomp("q02_p3.txt")
println("part3: ", part3(data))
