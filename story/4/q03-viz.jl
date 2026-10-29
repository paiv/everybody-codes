#!/usr/bin/env julia


function parsenotes(text)
    d = Dict(split(s,'=') for s in split(text, '\n', keepempty=false))
    width = parse(Int, d["width"])
    height = parse(Int, d["height"])
    hoff = parse.(Int, collect(d["horizontal-offsets"]))
    voff = parse.(Int, collect(d["vertical-offsets"]))
    return (; width, height, hoff, voff)
end


function viz(notes; cellsize=15, scale=2, pad=4)
    gwidth = min(800, notes.width)
    gheight = min(800, notes.height)
    w = cellsize * scale
    width = 2pad + gwidth * w
    height = 2pad + gheight * w
    """
    <?xml version="1.0"?>
    <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"
      "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
    <svg xmlns="http://www.w3.org/2000/svg"
          width="$width" height="$height" style="background-color:#202124">
    <style>
    .l{fill:none;stroke:#00db43;stroke-width:2;}
    .c0{fill:#003913;stroke:none;}
    .c1{fill:#3c372b;stroke:none;}
    .c2{fill:#0ac73e;stroke:none;}
    .c3{fill:#d8c28b;stroke:none;}
    </style>
    """ |> print

    oy,ox = pad, pad
    hs = collect(Iterators.take(Iterators.cycle(notes.hoff), gheight+1))
    vs = collect(Iterators.take(Iterators.cycle(notes.voff), gwidth+1))
    tc, c = false, false
    rv = 1:gheight+1
    rh = 1:gwidth+1

    for y=1:gheight
        py = oy + (y-1) * w
        for x=1:gwidth
            t = (x - hs[y]) % 2 == 1
            l = (y - vs[x]) % 2 == 1
            b = (x - hs[y+1]) % 2 == 1
            r = (y - vs[x+1]) % 2 == 1
            if x == 1
                c = tc
                t && (c = !tc)
                tc = c
            else
                l && (c = !c)
            end
            px = ox + (x-1) * w
            k = Int(c)
            if t && b && l && r
                k += 2
            end
            """<rect class="c$k" x="$px" y="$py" width="$w" height="$w"/>""" |> println
        end
    end

    for y=rv
        path = prod(rh) do x
            t = (x - hs[y]) % 2 == 1
            l = (y - vs[x]) % 2 == 1
            px = ox + (x-1) * w
            res = ""
            (t && x!=last(rh)) && (res *= " M $px,$oy h $w")
            (l && y!=last(rv)) && (res *= " M $px,$oy v $w")
            return res
        end
        oy += w
        """<path class="l" d="$path z"/>""" |> println
    end
    print("</svg>")
end


function parseargs(args)
    usage = """
    usage: viz.jl [-h] <data.txt>
    """
    if isempty(args)
        print(usage); exit()
    end

    fn = nothing
    state = :root

    for s in args
        if state == :root
            if startswith(s, "-")
                if s == "-"
                    fn = stdin
                elseif s == "-h" || s == "-help" || s == "--help"
                    print(usage); exit()
                else
                    print(stderr, usage)
                    error("unknown option $s")
                end
            else
                fn = s
            end
        end
    end

    isnothing(fn) && (fn = stdin)
    (; fn)
end


function @main(args)
    opt = parseargs(args)
    text = readchomp(opt.fn)
    notes = parsenotes(text)
    viz(notes)
    return 0
end

