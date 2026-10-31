#!/usr/bin/env julia

const Pos = CartesianIndex{2}
const (U,D,L,R) = [(-1,0),(1,0),(0,-1),(0,1)] .|> Pos
const neibs = [U,D,L,R,U+L,U+R,D+L,D+R]


function parsenotes(text)
    grid = parse.(Int, stack(split(text), dims=1))
    start = Pos(cld.(size(grid),2)...)
    return (grid, start)
end


function markland(grid, start)
    fringe = [start]
    seen = Set{Pos}()
    while !isempty(fringe)
        p = pop!(fringe)
        p ∈ seen && continue
        push!(seen, p)
        for d in neibs
            q = p + d
            if q∉seen && sum(grid[q+t]==1 || q+t∈seen for t in neibs if checkbounds(Bool, grid, q+t)) >= 5
                push!(fringe, q)
            end
        end
    end
    return seen
end


function marksand(land)
    fringe = [q for q in land
        if any(q+t∉land for t in neibs)]
    seen = Set{Pos}()
    while !isempty(fringe)
        p = pop!(fringe)
        p ∈ seen && continue
        push!(seen, p)
        for d in neibs
            q = p + d
            if q∈land && q∉seen && sum(q+t∉land || q+t∈seen for t in neibs) >= 5
                push!(fringe, q)
            end
        end
    end
    return seen
end


function marktrees(land, sand)
    UU,DD,LL,RR = U+U, D+D, L+L, R+R
    mask = [UU+L,UU,UU+R,U+LL,U+L,U,U+R,U+RR,LL,L,R,RR,D+LL,D+L,D,D+R,D+RR,DD+L,DD,DD+R]
    seen = Set{Pos}()
    nosand = setdiff(land, sand)
    for p in nosand
        if all(p+t∈nosand for t in mask)
            push!(seen, p)
        end
    end
    for _ in 1:2
        trees = copy(seen)
        for p in setdiff(nosand, seen)
            if sum(p+t∈trees for t in neibs) >= 4 && all(p+t∉sand for t in neibs)
                push!(seen, p)
            end
        end
    end
    return seen
end


const _palette = Dict(
    '.'=>:blue,
    '='=>:yellow,
    '#'=>:light_green,
    '@'=>:green,
)


function render(grid)
    buf = IOBuffer()
    io = IOContext(buf, :color=>true)
    for row in eachrow(grid)
        run = ""
        c, tc = :none, :none
        for x in row
            c = _palette[x]
            if tc == :none
                run, tc = string(x), c
            elseif c != tc
                printstyled(io, run, color=tc)
                run, tc = string(x), c
            else
                run *= x
            end
        end
        if !isempty(run)
            printstyled(io, run, color=c)
        end
        println(io)
    end
    takestring!(buf)
end


function viz(grid, start)
    land = markland(grid, start)
    sand = marksand(land)
    trees = marktrees(land, sand)
    m = fill('.', size(grid))
    m[collect(land)] .= '#'
    m[collect(sand)] .= '='
    m[collect(trees)] .= '@'
    render(m)
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
    grid, start = parsenotes(text)
    viz(grid, start) |> print
    return 0
end

