#!/usr/bin/env julia


function parserow(text)
    id,e,cs... = [parse(Int, m[1]) for m in eachmatch(r"(-?\d+)", text)]
    (; id, e, cs)
end


function parsenotes(text)
    parserow.(split(text, '\n', keepempty=false))
end


function viz(data)
    nodes = join("""$(p.id) [label = "$(p.id)\\n($(p.e))"]\n"""
        for p in data)
    edges = join("$(p.id) -> $t\n"
        for p in data for t in p.cs)
    """
    digraph {
    bgcolor = "#202124"
    node [color = "#5F626B", fontcolor = "#f1f3f4"]
    edge [color = "#5F626B"]
    $nodes
    $edges
    }
    """
end


function parseargs(args)
    usage = """
    usage: viz.jl [-h] <data.txt>
    """
    if isempty(args)
        print(usage); exit()
    end

    fn = nothing
    state = 0

    for s in args
        if state == 0
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
    data = parsenotes(text)
    viz(data) |> print
    return 0
end

