#!/usr/bin/env julia

const R = UnitRange{Int}


function parsenotes(text)
    nums = [[parse(Int, m[1]) for m in eachmatch(r"(\d+)", s)]
        for s in split(text)]
    gs = Dict(0=>[0:1])
    for (x,y,n) in nums
        r = y:y+n
        gs[x] = push!(get(gs, x, R[]), r)
    end
    return gs
end


function viz(data; h::Real=4096, w::Real=4096)
    maxx = maximum(keys(data))
    maxy = maximum(last(r) for rs in values(data) for r in rs)
    s = min(w / (maxx+1), h / (maxy+1))
    lw = round(log10(w)/4, digits=4)

    function ln(x, r)
        x = round(x * s, digits=4)
        a = round(first(r) * s, digits=4)
        b = round(last(r) * s, digits=4)
        """<line x1="$x" y1="$a" x2="$x" y2="$b" stroke="#ffdecfcc" stroke-width="$lw"/>\n"""
    end

    poly = join(ln(x, r) for (x,rs) in data for r in rs)

    """
<?xml version="1.0"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"
  "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">

<svg xmlns="http://www.w3.org/2000/svg"
      width="$w" height="$h" style="background-color:#202124">
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


function @main(args)
    args = parseargs(args)
    data = readchomp(args.fn)
    s = parsenotes(data)
    println(viz(s, w=args.sz, h=args.sz))
    return 0
end
