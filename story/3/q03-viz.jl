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
    notes = ["$n$i" for i=3:5 for n='a':'g']
    m = mapreduce(*, collect(node)) do s
        cs = collect(s.data)
        ix = findall(!=('-'), cs)
        isempty(ix) && return "~ "
        all(isdigit, cs[ix]) || return "~ "
        ps = notes[ix]
        q = join(ps, ',')
        # ts = cs[ix] .- '0'
        # ns = map(zip(ps,ts)) do (p,t)
        #     "[$p@$t ~@$(4-t)]"
        # end
        # q = join(ns, ',')
        "[$q] "
    end
    """\$: note("<$m ~ ~ ~>*8").sound("gm_blown_bottle")"""
end


function parseargs(args)
    needs_help = false
    filename = "-"
    part = 3
    melody = false
    state = :ParseArg
    for arg in args
        if state == :ParseArg
            if startswith(arg, '-')
                if arg == "-h" || arg == "-help" || arg == "--help"
                    needs_help = true
                elseif arg == "-p" || arg == "--part"
                    state = :ParsePart
                elseif arg == "-m" || arg == "--melody"
                    melody = true
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
    return (; needs_help, filename, part, melody)
end


const _help_page = """
usage: viz.jl [-h] [-p PART] [-m] FILE
options:
  -m,--melody   print the melody
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

    p = opts.melody ? melody : viz

    ns = parsenotes(data)
    root = f(ns)
    s = p(root)
    println(s)

    return 0
end
