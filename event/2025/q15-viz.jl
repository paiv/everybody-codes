#!/usr/bin/env julia

const Pos = CartesianIndex{2}
const neibs = [(-1,0),(1,0),(0,-1),(0,1)] .|> Pos
const (L,R) = [complex(0,-1), complex(0,1)]


function parsenotes(text)
    [(m[1] == "L" ? L : m[1] == "R" ? R : error(m), parse(Int, m[2]))
        for m in eachmatch(r"([A-Z]+)(\d+)", text)]
end

function Base.:*(a::Pos, b::Complex{Int})
    c = complex(a[2], a[1]) * b
    Pos(imag(c), real(c))
end


function viz(data; h::Real=4096, w::Real=4096)
    start, sdir = Pos(0, 0), Pos(-1,0)
    p, dir = start, sdir
    off, to = start, start
    xs, ys = Set{Int}(), Set{Int}()
    push!(ys, start[1])
    push!(xs, start[2])
    for (d, n) in data
        dir *= d
        p += dir * n
        off, to = min(off, p), max(to, p)
        push!(ys, p[1])
        push!(xs, p[2])
    end
    s = w / max((to - off).I...)
    lw = round(log10(w)/4, digits=4)

    function sp(p)
        x = round((p[2]-off[2]) * s, digits=4)
        y = round((p[1]-off[1]) * s, digits=4)
        string(x,',',y,' ')
    end
    function cc(y, x)
        x = round((x-off[2]) * s, digits=4)
        y = round((y-off[1]) * s, digits=4)
        """<circle cx="$x" cy="$y" r="$lw" fill="#cfdbff"/>\n"""
    end

    circ = String[]
    for y in ys, x in xs
        push!(circ, cc(y, x))
    end
    circ = join(circ)

    poly = String[]
    p, dir = start, sdir
    push!(poly, sp(p))
    for (d, n) in data
        dir *= d
        p += dir * n
        push!(poly, sp(p))
    end
    poly = """<polyline points="$(join(poly))" fill="none" stroke="#ffdecfcc" stroke-width="$lw" />"""

    """
<?xml version="1.0"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"
  "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">

<svg xmlns="http://www.w3.org/2000/svg"
      width="$w" height="$h" style="background-color:#202124">
  $circ
  $poly
</svg>
    """
end


const _usage = "usage: viz.jl [-s SIZE] <data.txt>\n"


function argerror(message)
    print(stderr, _usage)
    error(message)
end


function parseargs(args)
    if isempty(args)
        print(_usage); exit()
    end

    fn = nothing
    sz = nothing
    state = 0

    for s in args
        if state == 0
            if startswith(s, "-")
                if s == "-"
                    fn = stdin
                elseif s == "-h" || s == "--help"
                    print(_usage); exit()
                elseif s == "-s" || s == "--size"
                    state = 1
                else
                    argerror("unknown option $s")
                end
            else
                fn = s
            end
        elseif state == 1
            sz = parse(Int, s)
            state = 0
        end
    end

    if state == 1
        argerror("option needs a value: --size")
    end

    isnothing(fn) && (fn = stdin)
    isnothing(sz) && (sz = 4096)
    (; fn, sz)
end


function main(args)
    data = readchomp(args.fn)
    s = parsenotes(data)
    println(viz(s, w=args.sz, h=args.sz))
end


main(parseargs(ARGS))
