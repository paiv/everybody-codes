#!/usr/bin/env julia


const Pos = CartesianIndex{2}


function parserow(text)
    [parse(Int, m[1]) for m in eachmatch(r"(-?\d+)", text)]
end


function parsenotes(text)
    parserow.(split(text, '\n', keepempty=false))
end


function evaldesign1(data)
    pos = 0
    seen = Set([pos])
    path = [pos]
    for x in data
        q = pos - x
        if q < 0 || q ∈ seen
            q = pos + x
        end
        pos = q
        push!(seen, pos)
        push!(path, pos)
    end
    return path
end


function evaldesign2(data)
    pos = 0
    seen = Set([pos])
    path = [pos]
    for x in data
        q = pos - x
        if q < 0 || q ∈ seen
            q = pos + x
            while q ∈ seen
                q += 1
            end
        end
        pos = q
        push!(seen, pos)
        push!(path, pos)
    end
    return path
end


shrink(r) = first(r)+1 : last(r)-1
nonintersect(r, a, b) = (a∉r && b∉r) || (a∈shrink(r) && b∈shrink(r))
isintersect(r, a, b) = !nonintersect(r, a, b)


function evaldesign3(data)
    olist = UnitRange{Int}[]
    elist = UnitRange{Int}[]
    p = 0
    seen = Set([p])
    path = [p]
    step = 1
    for x in data
        ls = isodd(step) ? olist : elist
        q = p - x
        if q<0 || q∈seen || any(isintersect(r,p,q) for r in ls)
            q = p + x
            if !isempty(ls)
                b = 1 + max(q, maximum(last(r) for r in ls))
                while q<=b && (q∈seen || any(isintersect(r,p,q) for r in ls))
                    q += 1
                end
                q > b && continue
            end
        end
        push!(ls, p<q ? (p:q) : (q:p))
        p = q
        push!(seen, p)
        push!(path, p)
        step += 1
    end
    return path
end


function viz(paths; scale=20, pad=20)
    width, height = 1, 1
    oy,ox = pad, pad
    ip = 0
    body = prod(paths) do path
        ip += 1
        opath, epath = "", ""
        ody, edy = 0, 0
        for i in 1:2:length(path)-1
            a, b = path[i:i+1]
            ody = max(ody, ceil(Int, abs(b-a)/2 * scale))
        end
        for i in 2:2:length(path)-1
            a, b = path[i:i+1]
            edy = max(edy, ceil(Int, abs(b-a)/2 * scale))
        end
        py = oy + edy
        for i in 1:2:length(path)-1
            a, b = minmax(path[i:i+1]...)
            r = (b - a)/2 * scale
            px = ox + a * scale
            tx = ox + b * scale
            width = max(width, tx + pad)
            opath *= " M $px,$py A $r $r 0 0 0 $tx,$py"
        end
        for i in 2:2:length(path)-1
            a, b = minmax(path[i:i+1]...)
            r = (b - a)/2 * scale
            px = ox + a * scale
            tx = ox + b * scale
            width = max(width, tx + pad)
            epath *= " M $px,$py A $r $r 0 0 1 $tx,$py"
        end
        oy += (ody + edy) + pad
        height = oy
        """
        <g id="seq$ip">
          <path class="o" d="$opath" />
          <path class="e" d="$epath" />
        </g>
        """
    end

    """
    <?xml version="1.0"?>
    <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"
      "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
    <svg xmlns="http://www.w3.org/2000/svg"
          width="$width" height="$height" style="background-color:#202124">
    <style>.o,.e{fill:none;stroke-width:2;opacity:.85}
    .o{stroke:#00db43;}
    .e{stroke:#eed699;}
    </style>
    $body
    </svg>
    """
end


function parseargs(args)
    usage = """
    usage: viz.jl [-h] [-p PART] <data.txt>
    """
    if isempty(args)
        print(usage); exit()
    end

    fn = nothing
    part = 3
    state = :root

    for s in args
        if state == :root
            if startswith(s, "-")
                if s == "-"
                    fn = stdin
                elseif s == "-h" || s == "-help" || s == "--help"
                    print(usage); exit()
                elseif s == "-p" || s == "--part"
                    state = :part
                else
                    print(stderr, usage)
                    error("unknown option $s")
                end
            else
                fn = s
            end
        elseif state == :part
            part = parse(Int, s)
            state = :root
        end
    end

    if state == :part
        print(stderr, usage)
        error("option needs a value: -p")
    end

    if part ∉ 1:3
        print(stderr, usage)
        error("invalid option: -p $part")
    end

    isnothing(fn) && (fn = stdin)
    (; fn, part)
end


function @main(args)
    opt = parseargs(args)
    text = readchomp(opt.fn)
    data = parsenotes(text)

    paths = if opt.part == 1
        evaldesign1.(data)
    elseif opt.part == 2
        evaldesign2.(data)
    else
        evaldesign3.(data)
    end

    print(viz(paths))
    return 0
end

