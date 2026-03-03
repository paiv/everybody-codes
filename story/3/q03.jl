#!/usr/bin/env julia

struct Port
    color::String
    shape::String
end


struct NodeMeta
    plug::Port
    left::Port
    right::Port
end


mutable struct Node
    id::Int
    meta::NodeMeta
    left::Union{Nothing,Node}
    right::Union{Nothing,Node}
    data::Union{Nothing,String}
end


Base.show(io::IO, p::Port) = write(io, "$(p.color) $(p.shape)")
Base.parse(::Type{Port}, s) = Port(split(s)...)


function parsepair(text)
    a,b = split(text, '=') .|> strip
    return a=>b
end

function parseentry(text)
    split(text, ',') .|> parsepair |> Dict
end


function parsemeta(d)
    p,l,r = parse.(Port, [d["plug"], d["leftSocket"], d["rightSocket"]])
    NodeMeta(p, l, r)
end


function parsenode(d)
    Node(parse(Int, d["id"]), parsemeta(d),
        nothing, nothing, d["data"])
end


function parsenotes(text)
    split(text, '\n', keepempty=false) .|> (parsenode∘parseentry)
end


function isbonding(a::Port, b::Port)
    a.color == b.color || a.shape == b.shape
end


function isstrong(a::Port, b::Port)
    a.color == b.color && a.shape == b.shape
end


function isweak(a::Port, b::Port)
    (a.color == b.color && a.shape != b.shape) ||
    (a.color != b.color && a.shape == b.shape)
end


function attach!(n::Node, c::Node, bond)
    if isnothing(n.left)
        if bond(n.meta.left, c.meta.plug)
            n.left = c
            return n
        end
    else
        r = attach!(n.left, c, bond)
        !isnothing(r) && return n
    end

    if isnothing(n.right)
        if bond(n.meta.right, c.meta.plug)
            n.right = c
            return n
        end
    else
        r = attach!(n.right, c, bond)
        !isnothing(r) && return n
    end

    nothing
end


function attach3!(n::Node, ctx::Ref{Node})
    c = ctx[]
    if isnothing(n.left)
        if isbonding(n.meta.left, c.meta.plug)
            n.left = c
            return n
        end
    elseif isstrong(n.meta.left, c.meta.plug) && isweak(n.meta.left, n.left.meta.plug)
        t = n.left
        n.left = c
        ctx[] = t
    else
        r = attach3!(n.left, ctx)
        !isnothing(r) && return n
    end

    c = ctx[]
    if isnothing(n.right)
        if isbonding(n.meta.right, c.meta.plug)
            n.right = c
            return n
        end
    elseif isstrong(n.meta.right, c.meta.plug) && isweak(n.meta.right, n.right.meta.plug)
        t = n.right
        n.right = c
        ctx[] = t
    else
        r = attach3!(n.right, ctx)
        !isnothing(r) && return n
    end

    nothing
end


function buildtree(bond, ns)
    root, ts... = ns
    for n in ts
        attach!(root, n, bond)
    end
    return root
end


function buildtree(ns)
    root, ts... = ns
    for n in ts
        c = Ref(n)
        r = nothing
        while isnothing(r)
            r = attach3!(root, c)
        end
    end
    return root
end


function Base.collect(n::Node)
    v = Node[]
    function inorder(p)
        isnothing(p) && return
        inorder(p.left)
        push!(v, p)
        inorder(p.right)
    end
    inorder(n)
    return v
end


function checksum(s)
    stat = [n.id for n in collect(s)]
    sum(prod, enumerate(stat))
end


function solve(f, data)
    ns = parsenotes(data)
    root = f(ns)
    checksum(root)
end


const buildtree1 = x->buildtree(isstrong, x)
const buildtree2 = x->buildtree(isbonding, x)
const buildtree3 = buildtree

part1(data) = solve(buildtree1, data)
part2(data) = solve(buildtree2, data)
part3(data) = solve(buildtree3, data)


function test()
    data = raw"""
    id=1, plug=BLUE HEXAGON, leftSocket=GREEN CIRCLE, rightSocket=BLUE PENTAGON, data=?
    id=2, plug=GREEN CIRCLE, leftSocket=BLUE HEXAGON, rightSocket=BLUE CIRCLE, data=?
    id=3, plug=BLUE PENTAGON, leftSocket=BLUE CIRCLE, rightSocket=BLUE CIRCLE, data=?
    id=4, plug=BLUE CIRCLE, leftSocket=RED HEXAGON, rightSocket=BLUE HEXAGON, data=?
    id=5, plug=RED HEXAGON, leftSocket=GREEN CIRCLE, rightSocket=RED HEXAGON, data=?
    """
    @assert part1(data) == 43


    data = raw"""
    id=1, plug=RED TRIANGLE, leftSocket=RED TRIANGLE, rightSocket=RED TRIANGLE, data=?
    id=2, plug=GREEN TRIANGLE, leftSocket=BLUE CIRCLE, rightSocket=GREEN CIRCLE, data=?
    id=3, plug=BLUE PENTAGON, leftSocket=BLUE CIRCLE, rightSocket=GREEN CIRCLE, data=?
    id=4, plug=RED TRIANGLE, leftSocket=BLUE PENTAGON, rightSocket=GREEN PENTAGON, data=?
    id=5, plug=RED PENTAGON, leftSocket=GREEN CIRCLE, rightSocket=GREEN CIRCLE, data=?
    """
    @assert part2(data) == 50
    @assert part3(data) == 38


    data = raw"""
    id=1, plug=RED TRIANGLE, leftSocket=BLUE TRIANGLE, rightSocket=GREEN TRIANGLE, data=?
    id=2, plug=GREEN TRIANGLE, leftSocket=BLUE CIRCLE, rightSocket=GREEN CIRCLE, data=?
    id=3, plug=BLUE PENTAGON, leftSocket=BLUE CIRCLE, rightSocket=GREEN CIRCLE, data=?
    id=4, plug=RED TRIANGLE, leftSocket=BLUE PENTAGON, rightSocket=GREEN PENTAGON, data=?
    id=5, plug=BLUE TRIANGLE, leftSocket=GREEN CIRCLE, rightSocket=RED CIRCLE, data=?
    id=6, plug=BLUE TRIANGLE, leftSocket=GREEN CIRCLE, rightSocket=RED CIRCLE, data=?
    """
    @assert part3(data) == 60
end


function @main(args)
    test()

    data = readchomp("q03_p1.txt")
    println("part1: ", part1(data))
    data = readchomp("q03_p2.txt")
    println("part2: ", part2(data))
    data = readchomp("q03_p3.txt")
    println("part3: ", part3(data))

    return 0
end
