#!/usr/bin/env julia
import JSON


const Pos = CartesianIndex{2}
const Dir = Complex{Int}
const (DS,DU,DD,DL,DR) = [(0,0),(0,-1),(0,1),(-1,0),(1,0)] .|> splat(Dir)


const MAX_HEADS = 10
const MAX_RULES = 10000


function Base.:+(i::Pos, d::Dir)
    y,x = i.I
    Pos(y + imag(d), x + real(d))
end


struct Rule{N}
    state::Symbol
    next::Symbol
    read::NTuple{N,Char}
    write::NTuple{N,Char}
    move::NTuple{N,Char}
end


function Base.show(io::IO, r::Rule{N}) where N
    print(io, string(r.state, ' ', join(r.read), ' ', r.next, ' ',
        join(r.write), ' ', join(r.move)))
end


struct ParsedProgram{N}
    heads::NTuple{N,Char}
    rules::Vector{Rule{N}}
end

Base.size(p::ParsedProgram{N}) where N = N
Base.length(p::ParsedProgram) = length(p.rules)


function Base.parse(::Type{Rule{N}}, text) where N
    ps = split(text)
    length(ps) < 5 && error("rule format: STATE READ NEXT-STATE WRITE MOVE: $(repr(text))")
    s,p,t,f,d = ps
    p,f,d = Tuple(p), Tuple(f), Tuple(d)
    length(p) != N && error("READ needs $N args: $(repr(text))")
    length(f) != N && error("WRITE needs $N args: $(repr(text))")
    length(d) != N && error("MOVE needs $N args: $(repr(text))")
    Rule(Symbol(s), Symbol(t), p, f, d)
end


function Base.parse(::Type{ParsedProgram}, text)
    heads = nothing
    rules = nothing
    N = 0
    state = :head
    for line in eachline(IOBuffer(text))
        s = strip(line)
        isempty(s) && continue
        startswith(s, "//") && continue
        if state == :head
            !startswith(s, "HEADS") && error("first rule should be HEADS")
            ps = split(s)
            length(ps) != 2 && error("format: HEADS ABC...")
            heads = Tuple(ps[2])
            heads ⊈ 'A':'Z' && error("invalid $s")
            N = length(heads)
            N > MAX_HEADS && error("HEADS limit is $MAX_HEADS, got $N")
            rules = Rule{N}[]
            state = :rule
        elseif state == :rule
            r = parse(Rule{N}, s)
            push!(rules, r)
        end
    end
    isnothing(heads) && error("missing HEADS rule")
    ParsedProgram(heads, rules)
end


macro rule_str(text)
    p = parse(ParsedProgram, text)
    return :($p)
end


const Palette = [:red, :green, :blue, :magenta, :yellow, :cyan]


function render(io::IO, grid::AbstractDict{Pos,Char}; pois::AbstractVector{Pos}=Pos[])
    miny,maxy = extrema(p[1] for p in Iterators.flatten([pois, keys(grid)]))
    minx,maxx = extrema(p[2] for p in Iterators.flatten([pois, keys(grid)]))
    for y in miny:maxy
        for x in minx:maxx
            p = Pos(y,x)
            c = get(grid, p, ' ')
            i = findfirst(==(p), pois)
            if isnothing(i)
                print(io, c)
            else
                w = Palette[mod(i, 1:length(Palette))]
                printstyled(io, c, reverse=true, color=w)
            end
        end
        println(io)
    end
end



const HeadMoves = Dict('S'=>DS, 'U'=>DU, 'D'=>DD, 'L'=>DL, 'R'=>DR)


struct CompiledProgram{N}
    heads::NTuple{N,Int}
    rules::Vector{Rule{N}}
    index::Dict{Symbol,Vector{Int}}
end

heads(p::CompiledProgram) = join(p.heads .+ ('A'-1))


function compile(program::ParsedProgram{N}) where N
    rules = Rule{N}[]
    ix = Dict{Symbol,Vector{Int}}()
    for (i,r) in enumerate(program.rules)
        l = get!(ix, r.state) do
            Int[]
        end
        push!(l, i)
        push!(rules, r)
    end
    heads = program.heads .- ('A'-1)
    CompiledProgram(heads, rules, ix)
end


mutable struct Image
    program::CompiledProgram
    grid::Dict{Pos,Char}
    spawn::Vector{Pos}
    state::Symbol
    heads::Vector{Pos}
    steps::Int
    usedrules::Set{Rule}
end

Image(p, g, q, s, h) = Image(p, g, q, s, h, 0, Set{Rule}())


function Base.show(io::IO, image::Image)
    println(io, image.state)
    render(io, image.grid, pois=image.heads)
end


function build(program, grid, spawn)
    heads = [spawn[i] for i in program.heads]
    grid = Dict(p=>c for (p,c) in pairs(grid) if c != ' ')
    Image(program, grid, copy(spawn), :START, heads)
end


function arity(f)
    methods(f).ms[1].nargs - 1
end


function debugdata(v)
    join(x==' ' ? '_' : x for x in v)
end


function matchread(s, data)
    all(zip(s, data)) do (q, x)
        (q == '*') ||
        (q == '!' && x ∉ " _") ||
        (q == '_' && x ∈ " _") ||
        (q == x)
    end
end


function matchwrite(s, data)
    [(q=='*' ? '*' : q) for (q,x) in zip(s, data)]
end


function run(program, state, data)
    ix = program.index[state]
    rule = nothing
    out = nothing
    for r in view(program.rules, ix)
        if matchread(r.read, data)
            !isnothing(rule) && error("multiple rules matched $state $(debugdata(data))")
            rule = r
            out = matchwrite(r.write, data)
        end
    end
    isnothing(rule) && error("no rule matched $state $(debugdata(data))")
    return (rule, out)
end


function evolve!(image)
    image.state == :STOP && return false
    data = [get(image.grid, i, ' ') for i in image.heads]
    rule,out = run(image.program, image.state, data)
    image.steps += 1
    push!(image.usedrules, rule)
    n = length(image.heads)
    for i=1:n, j=i+1:n
        if image.heads[i] == image.heads[j]
            if out[i]!='*' && out[j]!='*' && out[i] != out[j]
                error("multiple values for the same cell")
            end
        end
    end
    for i=1:n
        if out[i] != '*'
            image.grid[image.heads[i]] = out[i]
        end
        image.heads[i] += HeadMoves[rule.move[i]]
    end
    image.state = rule.next
    return image.state != :STOP
end


applyops(t, c::Symbol, d, s) = applyops(t, String(c), d, s)
applyops(t, c::String, d) = applyops(t, collect(c), d)
applyops(t, c::String, d, s) = applyops(t, collect(c), d, s)
applyops(t, c::NTuple{N,Char}, d, s) where N =
    applyops(t, collect(c), d, s)


function applyops(operations, code::AbstractVector{Char}, data)
    f = [get(operations, Symbol(i)) do
            c = string(i)
            _ -> c
        end
        for i in code]
    [arity(g)==2 ? g(data,i) : g(data)
        for (i,g) in enumerate(f)]
end


function applyops(operations, code::AbstractVector{Char}, data, context)
    f = [get(operations, Symbol(i)) do
            c = i
            _ -> c
        end
        for i in code]
    join(arity(g)==3 ? g(data,i,context) :
            arity(g)==2 ? g(data,i) : g(data)
        for (i,g) in enumerate(f))
end


function applypred(f, data, context)
    isnothing(f) && return true
    arity(f) == 2 && return f(data, context)
    return f(data)
end


function mergenames!(d, s)
    for (k,v) in s
        if v isa AbstractString
            d[k] = _ -> v
        elseif v isa Function
            d[k] = v
        elseif v isa AbstractChar
            c = string(v)
            d[k] = _ -> c
        else
            error(v)
        end
    end
    return d
end


namegen(t, c) = namegen(t, c, c)

function namegen(table, code::AbstractString, data)
    s = collect(code)
    u = unique(s)
    j = indexin(s, u)
    l = applyops(table, u, data)
    [join(v[i] for i in j) for v in Iterators.product(l...)]
end


function assemble(prog, labels, operations; start=:START, xpred=nothing)
    start = String(start)
    baselab = Dict{Symbol,Function}(:_ => _->"_", :* => _->"*", :! => _->"!")
    baseops = Dict{Symbol,Function}(:* => _->'*')
    labels = mergenames!(baselab, labels)
    operations = mergenames!(baseops, operations)
    res = ["HEADS " * join(prog.heads)]
    for rule in prog.rules
        for s in namegen(labels, String(rule.state))
            s == start && (s = "START")
            for p in namegen(labels, join(rule.read), s)
                !applypred(xpred, p, s) && continue
                d = applyops(operations, rule.move, p, s)
                w = applyops(operations, rule.write, p, s)
                t = applyops(operations, rule.next, p, s)
                t == start && (t = "START")
                push!(res, "$s $p $t $w $d")
                length(res)-1 > MAX_RULES && error("Maximum $MAX_RULES reached")
            end
        end
    end
    join(res, '\n')
end


function pad(a, c)
    h, w = size(a)
    m = similar(a, (h+2, w+2))
    m[2:h+1, 2:w+1] = a
    m[1,:] .= c
    m[end,:] .= c
    m[:,1] .= c
    m[:,end] .= c
    return m
end


function Base.parse(::Type{Pos}, text)
    i = parse.(Int, split(text, ','))
    return Pos(i...)
end


function parsegrid(text, pad=' ')
    l = split(text, '\n', keepempty=false)
    w = maximum(length, l)
    stack(rpad.(l, w, pad), dims=1)
end

function parsenotes(text)
    bs = split(text, "\n\n", keepempty=false)
    s,c = bs
    g = parsegrid(c)
    p = parse.(Pos, split(s))
    p = [Pos(mod.(q.I, axes(g))...) for q in p]
    return (p, g)
end


function printframe(image; fps=1.0)
    printstyled(image, '\n')
    fps > 0 && sleep(1/fps)
end


function play(viz, image)
    viz(image)
    while evolve!(image)
        viz(image)
    end
    viz(image)
end


struct TestCase
    spawn::Vector{Pos}
    grid::Dict{Pos,Char}
    expect::Dict{Pos,Char}
    tr::Union{Function,Nothing}
end


function tridentity(d)
    miny = minimum(p[1] for (p,v) in d if v∉" _")
    minx = minimum(p[2] for (p,v) in d if v∉" _")
    o = Pos(miny-1, minx-1)
    Dict(p-o=>v for (p,v) in d if v∉" _")
end


function trsort(d)
    join(sort([x for x in values(d) if x ∉ " _"]))
end


const _Transforms = Dict("sort"=>trsort, "id"=>tridentity)

function parsetransform(line)
    !startswith(line, r"\s*transform:") && error("format: \"transform: [id,sort]\"")
    i = findfirst(':', line)
    s = strip(line[i+1:end])
    f = get(_Transforms, s, nothing)
    isnothing(f) && error("unknown transform: $s")
    return f
end


function parsetestgrid(lines, spawn)
    line = first(lines)
    !startswith(line, r"\s*test:") && error("format: \"test: data\"")
    i = findfirst(':', line)
    s = lstrip(line[i+1:end])
    l = [s]
    if length(lines) > 1
        l = isempty(s) ? lines[2:end] : [s; lines[2:end]]
    end
    w = maximum(length, l)
    m = stack(rpad.(l, w, ' '), dims=1)
    g = Dict(p=>c for (p,c) in pairs(m) if c ∉ " _")
    p = [Pos(mod.(q.I, axes(m))...) for q in spawn]
    return (g, p)
end


function parseexpect(lines)
    line = first(lines)
    !startswith(line, r"\s*expect:") && error("format: \"expect: data\"")
    i = findfirst(':', line)
    s = lstrip(line[i+1:end])
    l = [s]
    if length(lines) > 1
        l = isempty(s) ? lines[2:end] : [s; lines[2:end]]
    end
    w = maximum(length, l)
    m = stack(rpad.(l, w, ' '), dims=1)
    Dict(p=>c for (p,c) in pairs(m) if c ∉ " _")
end


function readtests(fn)
    res = TestCase[]
    sspawn = nothing
    spawn = nothing
    grid = nothing
    tr = nothing
    cache = nothing
    state = :spawn
    for line in readlines(fn)
        if state == :spawn
            ps = split(line)
            isempty(ps) && continue
            sspawn = parse.(Pos, ps)
            grid = nothing
            state = :tr
        elseif state == :tr
            if isempty(strip(line))
                tr = tridentity
            else
                tr = parsetransform(line)
            end
            state = :igrid
        elseif state == :igrid
            isempty(strip(line)) && continue
            cache = [line]
            state = :grid
        elseif state == :grid
            if isempty(strip(line))
                grid,spawn = parsetestgrid(cache, sspawn)
                cache = nothing
                state = :itest
            elseif startswith(line, r"\s*expect:")
                grid,spawn = parsetestgrid(cache, sspawn)
                cache = [line]
                state = :test
            else
                push!(cache, line)
            end
        elseif state == :itest
            isempty(strip(line)) && continue
            cache = [line]
            state = :test
        elseif state == :test
            if isempty(strip(line))
                expect = parseexpect(cache)
                t = TestCase(spawn, grid, expect, tr)
                push!(res, t)
                cache = nothing
                state = :igrid
            elseif startswith(line, r"\s*test:")
                expect = parseexpect(cache)
                t = TestCase(spawn, grid, expect, tr)
                push!(res, t)
                cache = [line]
                state = :grid
            else
                push!(cache, line)
            end
        end
    end
    state == :grid && error("missing test expectation")
    state == :itest && error("missing test expectation")
    if state == :test
        expect = parseexpect(cache)
        t = TestCase(spawn, grid, expect, tr)
        push!(res, t)
    end
    return res
end


validate(test, image; tid=nothing) =
    validate(stderr, test, image, tid=tid)

function validate(io::IO, test, image; tid=nothing)
    s = test.tr(test.expect)
    t = test.tr(image.grid)
    print(io, "test ")
    !isnothing(tid) && print(io, "$tid ")
    if s == t
        printstyled(io, "OK", color=:green)
        println(io)
    else
        printstyled(io, "Err", color=:red)
        println(io)
        if (s isa AbstractString) && ('\n' ∉ s)
            println(io, "expected: ", s)
            println(io, "  actual: ", t)
        else
            println(io, "expected:")
            render(io, s)
            println(io, "  actual:")
            render(io, t)
        end
        exit(1)
    end
end


function runtest(program, test; verbose=false, fps=1.0, tid=nothing)
    img = build(program, test.grid, test.spawn)
    if verbose
        play(i->printframe(i, fps=fps), img)
    else
        while evolve!(img) end
    end
    ok = validate(test, img, tid=tid)
    return (; ok, steps=img.steps, rules=img.usedrules)
end


function processinputtest(io, obj)
    state = :head
    op = nothing
    for case in obj["cases"]
        if state == :case
            g = case["validate"]
            g != op && println(stderr, "mismatched transform $op != $g")
        elseif state == :head
            p = case["startPoints"]
            ps = [join([
                    p[k]["y"]==0 ? 1 : 0,
                    p[k]["x"]==0 ? 1 : 0,
                ], ',')
                for k in sort(collect(keys(p)))]
            println(io, join(ps, ' '))
            op = case["validate"]
            if op == "EXACT"
            elseif op == "TEXT"
                println(io, "transform: sort")
            else
                error("unhandled transform $op")
            end
            println(io)
            state = :case
        end
        println(io, '\n', "test:")
        println(io, case["data"], '\n')
        println(io, '\n', "expect:")
        println(io, case["expected"], '\n')
    end
end


function processinput(opt)
    for fn in opt.testfile
        obj = JSON.parsefile(fn)
        if "cases" in keys(obj)
            processinputtest(stdout, obj)
        else
            println(stderr, "skipping $fn")
        end
    end
    return 0
end


function processprog(opt, program)
    if !isnothing(program)
        pp = program
    else
        text = read(opt.progfile)
        pp = parse(ParsedProgram, text)
    end

    asm = assemble(pp, NamesRead, NamesWrite, start=START)
    (opt.printprog && !opt.cleanprog) && println(asm)

    isempty(opt.testfile) && return 0

    prog = compile(parse(ParsedProgram, asm))
    cprog = ["HEADS " * heads(prog)]
    total = 0
    steps = 0
    for fn in opt.testfile
        for t in readtests(fn)
            (total += 1) <= opt.skipn && continue
            try
                res = runtest(prog, t, verbose=opt.verbose, fps=opt.fps, tid=total)
                steps += res.steps
                opt.cleanprog && union!(cprog, string.(res.rules))
            catch
                if total > 1
                    print(stderr, "test $total ")
                    printstyled(stderr, "Err", color=:red)
                    println(stderr)
                end
                rethrow()
            end
        end
    end
    println(stderr, "steps: $steps")

    opt.cleanprog && println(join(cprog, '\n'))
    return 0
end


const START = :START
const NamesRead = Dict{Symbol,Function}()
const NamesWrite = Dict{Symbol,Function}()
const Predicate = _ -> true
const Program::Union{ParsedProgram,Nothing} = nothing
program() = nothing


const _usage_prog = "usage: gridos.jl [-h] [-v] [--fps FPS] [-p] [-c] PROGRAM [--skip N] [TEST...]\n"
const _usage_in = "usage: gridos.jl [-h] input [TEST...]\n"

const _help_prog = """
    usage: gridos.jl [-h] [-v] [--fps N] [-p] [-c] prog [--skip N] [test...]

    positional arguments:
      prog                  program file to execute
      test                  test files

    options:
      -p,--print            print the program
      -c,--clean            purge the program of unused rules
      --fps N               animation speed
      --skip N              skip N tests
      -v,--verbose          verbose output
      -h,--help             show this help
    """

function argerror(s; usage=_usage_prog)
    print(stderr, usage)
    error(s)
end


function parseargs(args; skipprogram=false)
    needshelp = false
    printprog = false
    cleanprog = false
    verbose = false
    fps = 10.0
    state = skipprogram ? :prog : :sub
    progfile = nothing
    testfile = String[]
    skipn = 0
    for arg in args
        if arg=="-h" || arg=="-help" || arg=="--help"
            needshelp = true
            break
        end
        if state == :sub
            if startswith(arg, '-') && arg != "-"
                argerror("unknown option $arg")
            elseif arg == "in" || arg == "input"
                state = :in
            else
                if !skipprogram
                    progfile = arg
                else
                    push!(testfile, arg)
                end
                state = :prog
            end
        elseif state == :prog
            if startswith(arg, '-') && arg != "-"
                if arg=="-v" || arg=="--verbose"
                    verbose = true
                elseif arg=="--fps"
                    state = :fps
                elseif arg=="--skip"
                    state = :skip
                elseif arg=="-c" || arg=="--clean"
                    cleanprog = true
                elseif arg=="-p" || arg=="--print"
                    printprog = true
                else
                    argerror("unknown option $arg")
                end
            else
                if isnothing(progfile) && !skipprogram
                    progfile = arg
                else
                    push!(testfile, arg)
                end
            end
        elseif state == :fps
            fps = parse(Float64, arg)
            state = :prog
        elseif state == :skip
            skipn = parse(Int, arg)
            state = :prog
        elseif state == :in
            if startswith(arg, '-')
                argerror("unknown option $arg", usage=_usage_in)
            else
                push!(testfile, arg)
            end
        end
    end
    if !needshelp
        progfile == "-" && (progfile = stdin)
        state == :fps && argerror("--fps: expected a value")
        state == :skip && argerror("--skip: expected a value")
        (state == :in && isempty(testfile)) && argerror("missing input", usage=_usage_in)
        (state == :prog && !skipprogram && isnothing(progfile)) &&
            argerror("missing program")
    end
    (; needshelp, state, printprog, cleanprog, verbose, fps,
        progfile, testfile, skipn)
end


function @main(args)
    prog = Program
    hasprog = !isnothing(prog)
    if !hasprog
        s = program()
        if !isnothing(s)
            prog = parse(ParsedProgram, s)
            hasprog = true
        end
    end
    opt = parseargs(args, skipprogram=hasprog)
    if opt.needshelp
        print(opt.state == :in ? _usage_in : _help_prog)
        return 0
    end

    if opt.state == :in
        processinput(opt)
    else
        processprog(opt, prog)
    end
end

