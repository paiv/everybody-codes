#!/usr/bin/env julia

const Pos = CartesianIndex{2}
const (U,D,L,R) = [(-1,0),(1,0),(0,-1),(0,1)] .|> Pos


function parsenotes(text)
    s = stack(split(text), dims=1)
    ix = findall(∈('1':'9'), s)
    g = fill(-1, size(s))
    g[ix] .= parse.(Int, s[ix])
    s[ix] .= ' '
    t, d = prep(g)
    return (g, t, d)
end


function prep(grid)
    w = count(>(0), grid[1,:])
    b = 2w - 1
    s = [
        [Pos(i, findfirst(>(0), grid[i,:])) for i=1:w],
        Pos.(1, findall(>(0), grid[1,:])),
        [Pos(i, findlast(>(0), grid[i,:])) for i=1:w],
        [Pos(i, findlast(>(0), grid[i,:])) for i=w:b],
        Pos.(b, findall(>(0), grid[b,:])),
        [Pos(i, findfirst(>(0), grid[i,:])) for i=w:b],
    ]
    dirs = [D+R, D+L, 2L, U+L, U+R, 2R]
    sides = [union(s[i], s[mod(i+1,1:6)]) for i=1:6]
    return (sides, dirs)
end


function lightmap(grid, sides, dirs, t, m, hs)
    i = mod(t, 1:6)
    s, d = sides[i], dirs[i]
    m .= false
    m[s] = grid[s] .> 0
    hs[s] = grid[s]
    q = s
    while !isempty(s)
        q = filter(s .+ d) do p
            checkbounds(Bool, grid, p)
        end
        m[q] = @. (0 < grid[q] > hs[q-d]-1)
        hs[q] = @. max(0, hs[q-d]-1, grid[q])
        s = q
    end
end


const _palette = Dict(
    1=>60, 2=>71, 3=>73, 4=>75, 5=>77,
    6=>79, 7=>81, 8=>83, 9=>87,
)


function viz(g, pois; sprite=false)
    buf = IOBuffer()
    io = IOContext(buf, :color=>true)
    for y in axes(g, 1)
        for x in axes(g, 2)
            p = Pos(y, x)
            v = g[p]
            l = p in pois
            c = (v>0 && l) ? :bold : get(_palette,v,:light_black)
            k = sprite ? '@' : v
            k = v < -1 ? 'X' : v > 0 ? k : ' '
            printstyled(io, k, color=c)
        end
        println(io)
    end
    takestring!(buf) |> print
end


function Base.sleep(; fps=1.0)
    if fps > 0
        sleep(1 / fps)
    else
        readline()
    end
    nothing
end


function play(data; N=100000, fps=1.0, sprite=false)
    grid, sides, dirs = data
    lm = falses(size(grid))
    hs = zeros(Int, size(grid))
    res, n, t = 0, 0, 0

    viz(grid, Pos[], sprite=sprite)
    sleep(fps=fps)

    while n < N
        @. grid[grid < -2] += 1
        @. grid[grid == -2] = 1
        lightmap(grid, sides, dirs, t+=1, lm, hs)
        pois = findall(lm)
        ix = findall(==(9), grid) ∩ pois
        n += length(ix)
        res += sum(lm)

        println()
        viz(grid, pois, sprite=sprite)
        sleep(fps=fps)

        @. grid[lm] += 1
        @. grid[ix] = -6

        println(t, ": ", res, " (", n, ')')
        viz(grid, pois, sprite=sprite)
        sleep(fps=fps)
    end
    nothing
end


function parseargs(args)
    usage = """
    usage: viz.jl [-h] [-f FPS] [-@] <data.txt>
    """
    if isempty(args)
        print(usage); exit()
    end

    fn = nothing
    fps = 4.0
    sprite = false
    state = :root

    for s in args
        if state == :root
            if startswith(s, "-")
                if s == "-"
                    fn = stdin
                elseif s == "-h" || s == "-help" || s == "--help"
                    print(usage); exit()
                elseif s == "-f" || s == "--fps"
                    state = :fps
                elseif s == "-@"
                    sprite = true
                else
                    print(stderr, usage)
                    error("unknown option $s")
                end
            else
                fn = s
            end
        elseif state == :fps
            fps = parse(Float64, s)
            state = :root
        end
    end

    state == :fps && error("-f/--fps: option needs a value")

    isnothing(fn) && (fn = stdin)
    (; fn, fps, sprite)
end


function @main(args)
    opt = parseargs(args)
    text = readchomp(opt.fn)
    data = parsenotes(text)
    play(data, fps=opt.fps, sprite=opt.sprite)
    return 0
end

