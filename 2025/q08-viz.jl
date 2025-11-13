#!/usr/bin/env julia
import Combinatorics: combinations


function parsenotes(text)
    [parse(Int, m.match) for m in eachmatch(r"\d+", text)]
end


function circle(N, p)
    a = π * ( 4(p - 1) / N - 1) / 2
    [sin(a) cos(a)]
end


function linefunc(a, b)
    ay, ax = a
    by, bx = b
    y = bx - ax
    x = ay - by
    c = bx*(ay-by) - by*(ax-bx)
    [y x c]
end


function solve(a, b, c, d)
    u = linefunc(a, b)
    v = linefunc(c, d)
    w = [u; v]
    A = w[:,1:2]
    b = w[:,3]
    A\b
end


function solve(N, lines)
    res = Vector{Float64}[]
    for ((a,b),(c,d)) in combinations(lines, 2)
        if (a < c < b < d) || (c < a < d < b)
            v = [circle(N,p) for p in [a,b,c,d]]
            q = solve(v...)
            push!(res, q)
        end
    end
    stack(res, dims=1)
end


function viz(data, N::Int; pix::Bool=false, h::Real=4096, w::Real=4096)
    o = [h/2 w/2]
    r = minimum(o)
    s = round(r / 1000 / log10(length(data)), digits=4)
    poly = map(data) do p
        y, x = round.(o .+ r * circle(N, p), digits=4)
        "$x,$y "
    end |> join
    body = """<polyline points="$poly" fill="none" stroke="#cfdbffcc" stroke-width="$s" />"""
    if pix
        ps = solve(N, map(minmax, data, data[2:end]))
        ps = round.(o .+ r * ps, digits=4)
        cs = map(eachrow(ps)) do p
            y,x = p
            """<circle cx="$x" cy="$y" r="$s" fill="#cfdbffaa"/>"""
        end
        body = map(Iterators.partition(cs, 100)) do b
            """<g>$(join(b))</g>"""
        end |> join
    end

    """
<?xml version="1.0"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"
  "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">

<svg xmlns="http://www.w3.org/2000/svg"
      width="$w" height="$h" style="background-color:#202124">
  <circle cx="$(w/2)" cy="$(h/2)" r="$r"
      fill="#202124" stroke="#5F626B" stroke-width="$(r/1000)" />
  $body
</svg>
    """
end


function parseargs(args)
    usage = """
    usage: viz.jl [-n N] [-px] <data.txt>
    """
    if isempty(args)
        print(usage); exit()
    end

    fn = nothing
    n = nothing
    pix = false
    state = 0

    for s in args
        if state == 0
            if startswith(s, "-")
                if s == "-"
                    fn = stdin
                elseif s == "-h"
                    print(usage); exit()
                elseif s == "-n"
                    state = 1
                elseif s == "-px"
                    pix = true
                else
                    print(stderr, usage)
                    error("unknown option $s")
                end
            else
                fn = s
            end
        elseif state == 1
            n = parse(Int, s)
            state = 0
        end
    end

    if state == 1
        print(stderr, usage)
        error("option needs a value: -n")
    end

    isnothing(fn) && (fn = stdin)
    isnothing(n) && (n = 256)

    (; n, fn, pix)
end


function main(args)
    data = readchomp(args.fn)
    s = parsenotes(data)
    println(viz(s, args.n, pix=args.pix))
end


main(parseargs(ARGS))
