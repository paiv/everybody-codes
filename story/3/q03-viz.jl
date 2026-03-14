#!/usr/bin/env julia

include("q03.jl")


const _ArrowHead = Dict(
    "TRIANGLE"=>"empty",
    "STAR"=>"crow",
    "DIAMOND"=>"odiamond",
    "HEXAGON"=>"dot",
    "PENTAGON"=>"box",
    "OCTAGON"=>"diamond",
    "SQUARE"=>"obox",
    "CIRCLE"=>"odot",
    )

const _Palette = Dict(
    "BLACK"=>"silver",
    )


fcolor(p) = get(_Palette, p.color, lowercase(p.color))

farrow(p) = _ArrowHead[p.shape]

viznode(n) = string(n.id)


function vizedge(p, f, n)
    d = f=="l" ? p.meta.left : p.meta.right
    weak = isweak(n.meta.plug, d)
    s = weak ? "dashed" : "solid"
    h = farrow(n.meta.plug)
    t = farrow(d)
    u = fcolor(n.meta.plug)
    v = fcolor(d)
    l = f=="l" ? "nw" : "ne"
    """$(p.id):$l -> $(n.id):s [style=$s, arrowhead=$h, arrowtail=$t, color="$u:none;0.01:$v"]"""
end


function viz(node)
    edges = String[]
    function inner(n, f, p)
        isnothing(n) && return
        if !isnothing(p)
            push!(edges, vizedge(p, f, n))
        end
        inner(n.left, "l", n)
        inner(n.right, "r", n)
    end
    inner(node, nothing, nothing)

    edges = join(edges, '\n')
    """
    digraph {
    rankdir = "BT"
    bgcolor = "#202124"
    node [color="#5F626B", fontcolor="#f1f3f4", shape=circle]
    edge [color="#5F626B", dir=both]
    $edges
    }
    """
end


function melody(node)
    v = map(s->s.data, collect(node))
    join(v, '\n')
end


function strudel1(node)
    notes = ["$n$i" for i=3:5 for n='a':'g']
    m = mapreduce(*, collect(node)) do s
        ix = findall(!=('-'), s.data)
        if isempty(ix)
            "~"
        elseif length(ix) == 1
            notes[ix] |> only
        else
            q = join(notes[ix], ',')
            "[$q]"
        end * ' '
    end
    """setcpm(110*3); note("<$m~ ~ ~>").sound("gm_xylophone")\n"""
end


function strudel(node, qs='1':'3')
    notes = ["$n$i" for i=3:5 for n='a':'g']
    gain = Dict('1'=>0.3, '2'=>0.5, '3'=>1.0)
    ns = collect(node)
    function vol(u)
        any(s->u∈s.data, ns) || return ""
        g = gain[u]
        m = mapreduce(*, ns) do s
            ix = findall(==(u), s.data)
            if isempty(ix)
                "~"
            elseif length(ix) == 1
                notes[ix] |> only
            else
                q = join(notes[ix], ',')
                "[$q]"
            end * ' '
        end
        """\$: note("<$m~ ~ ~>").sound("gm_xylophone").postgain($g)\n"""
    end
    s = join(map(vol, qs))
    "setcpm(110*3);\n$s"
end


function parseargs(args)
    needs_help = false
    filename = "-"
    part = 3
    melody = false
    strudel = false
    state = :ParseArg
    for arg in args
        if state == :ParseArg
            if startswith(arg, '-')
                if arg == "-h" || arg == "-help" || arg == "--help"
                    needs_help = true
                elseif arg == "-p" || arg == "--part"
                    state = :ParsePart
                elseif arg == "-p1"
                    part = 1
                elseif arg == "-p2"
                    part = 2
                elseif arg == "-p3"
                    part = 3
                elseif arg == "-m" || arg == "--melody"
                    melody = true
                elseif arg == "-s" || arg == "--strudel"
                    strudel = true
                elseif arg == "-"
                    filename = arg
                else
                    needs_help = true
                    break
                end
            else
                filename = arg
            end
        elseif state == :ParsePart
            part = parse(Int, arg)
            state = :ParseArg
        end
    end
    state != :ParseArg && (needs_help = true)
    viz = !(melody || strudel)
    return (; needs_help, filename, part, viz, melody, strudel)
end


const _help_page = """
usage: viz.jl [-h] [-p PART] [-m] [-s] FILE
options:
  -m,--melody   print the melody
  -s,--strudel  print the melody
  -p,--part     select the algorithm
  -h            print this help
"""

function @main(args)
    opts = parseargs(args)
    if opts.needs_help
        print(_help_page)
        return 0
    end
    io = stdin
    if opts.filename != "-"
        io = open(opts.filename)
    end
    data = readchomp(io)
    if opts.filename != "-"
        close(io)
    end

    f = buildtree
    if opts.part == 1
        f = buildtree1
    elseif opts.part == 2
        f = buildtree2
    elseif opts.part == 3
        f = buildtree3
    end

    ns = parsenotes(data)
    root = f(ns)
    opts.melody && melody(root) |> println
    opts.strudel && strudel(root) |> println
    opts.viz && viz(root) |> println

    return 0
end
