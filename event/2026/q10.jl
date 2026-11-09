#!/usr/bin/env julia
import DataStructures: counter


const Pos = CartesianIndex{2}
const Turn = Complex{Int}
const (U,D,L,R) = [(-1,0),(1,0),(0,-1),(0,1)] .|> Pos
const (TL,TR,TT) = [(0,-1),(0,1),(-1,0)] .|> splat(Turn)
const dirs = Dict('^'=>U, 'v'=>D, '<'=>L, '>'=>R)


function Base.:*(p::Pos, d::Turn)
    q = complex(p[2], p[1]) * d
    Pos(imag(q), real(q))
end


function parsenotes(text)
    grid = stack(split(text), dims=1)
    cpos = findall(∈(keys(dirs)), grid)
    cdir = [dirs[grid[p]] for p in cpos]
    grid[cpos] .= '.'
    return (grid, cpos, cdir)
end


function evolve!(cpos, cdir; grid)
    p = cpos .+ cdir
    s = grid[p] .!= '.'
    cpos .+= cdir .* (.!s)
    cdir[s] .*= TR
    q = counter(cpos)
    t = [q[p]>1 for p in cpos]
    cdir[t] .*= TT
    return (s, t)
end


function part1(data; T=10)
    grid, cpos, cdir = parsenotes(data)
    sum(1:T) do _
        a, b = evolve!(cpos, cdir, grid=grid)
        return sum(a) + sum(b)
    end
end


function part2(data; N=10000)
    grid, cpos, cdir = parsenotes(data)
    #println("T=0")
    #viz(grid, cpos, cdir, falses(length(cpos))) |> println
    cn = zeros(Int, length(cpos))
    t = 0
    seen = Dict()
    while !isempty(cpos)
        t += 1
        p = cpos .+ cdir
        a = grid[p] .!= '.'
        cpos .+= cdir .* (.!a)
        if any(a)
            cdir[a] .*= TR
            cn .+= a
            vs = get(seen, (0,cpos,cdir), nothing)
            if !isnothing(vs)
                vt,vn = vs
                dt = t - vt
                dn = cn .- vn
                st = minimum(@. (N - cn) ÷ dn)
                @. cn += st * dn
                t += dt * st
                empty!(seen)
            else
                seen[(0,copy(cpos),copy(cdir))] = (t, copy(cn))
            end
            ix = cn .>= N
            if any(ix)
                jx = .!ix
                cpos = cpos[jx]
                cdir = cdir[jx]
                cn = cn[jx]
                a = a[jx]
                empty!(seen)
            end
        end
        q = counter(cpos)
        b = [q[p]>1 for p in cpos]
        if any(b)
            cdir[b] .*= TT
            cn .+= b
            vs = get(seen, (1,cpos,cdir), nothing)
            if !isnothing(vs)
                vt,vn = vs
                dt = t - vt
                dn = cn .- vn
                st = minimum(@. (N - cn) ÷ dn)
                @. cn += st * dn
                t += dt * st
                empty!(seen)
            else
                seen[(1,copy(cpos),copy(cdir))] = (t, copy(cn))
            end
            ix = cn .>= N
            if any(ix)
                jx = .!ix
                cpos = cpos[jx]
                cdir = cdir[jx]
                cn = cn[jx]
                empty!(seen)
            end
        end
        #println("T=", t)
        #viz(grid, cpos, cdir, a.|b) |> println
    end
    return t
end


part3(data; N=1000000000000) = part2(data, N=N)


const _sdirs = Dict(zip(values(dirs), keys(dirs)))

const _palette = Dict(
    '.'=>:light_black, '#'=>:yellow,
    '>'=>:white, '<'=>:white, 'v'=>:white, '^'=>:white,
)

function viz(grid, cpos, cdir, poi)
    buf = IOBuffer()
    io = IOContext(buf, :color=>true)
    for y in axes(grid, 1)
        for x in axes(grid, 2)
            p = Pos(y, x)
            i = findfirst(==(p), cpos)
            s = isnothing(i) ? grid[p] : _sdirs[cdir[i]]
            c = get(_palette, s, :normal)
            r = !isnothing(i) && poi[i]
            printstyled(io, s, color=c, reverse=r)
        end
        println(io)
    end
    takestring!(buf)
end


data = raw"
###########
#####.#####
###.....###
##.......##
##.>>.<<.##
#v...>...v#
##...v...##
##.......##
###.....###
#####.#####
###########
"
@assert part1(data) == 29
@assert part2(data, N=10) == 53
@assert part2(data) == 50000


data = raw"
#######################
###########.###########
#######.^>.^.<^.#######
#####..<.>.v^>>^^<#####
####..v<^v.>.>v..^.####
###.................###
###.................###
##.......<...<.<....>##
##...v....>....v.v<.^##
##........###........##
##v......#####.......##
#.<......#####......>.#
##.......#####.......##
##........###........##
##...................##
##...................##
###.................###
###.................###
####...............####
#####.............#####
#######....v....#######
###########.###########
#######################
"
@assert part3(data) == 13314695352588


println("part1: ", part1(readchomp("q10_p1.txt")))
println("part2: ", part2(readchomp("q10_p2.txt")))
println("part3: ", part3(readchomp("q10_p3.txt")))
