#!/usr/bin/env julia


function parserow(text)
    [m[1] for m in eachmatch(r"(\w+)", text)]
end


function parsenotes(text)
    Dict(k=>vs for (k,vs...) in parserow.(split(text)))
end


function viz(data)
    text = join("$k -> $v\n"
        for (k,vs) in data for v in vs)
    """
    digraph {
    bgcolor = "#202124"
    node [color = "#5F626B", fontcolor = "#f1f3f4"]
    edge [color = "#5F626B"]
    $text
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

