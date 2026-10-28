#!/usr/bin/env julia


function parserule(text)
    a,q,b = split(text, r"\b")
    x,y = [parse(Int, i) for i in [a, b]]
    return q=="<" ? (x,y) : (y,x)
end


function parserow(text)
    parserule.(split(text))
end


function parsenotes(text)
    parserow.(split(text, '\n', keepempty=false))
end


function viz(data)
    nodes = (n, row) -> join("n$(n)_$(x) [label = $x]\n"
        for x in unique(t
        for ps in row for t in ps))
    edges = (n, row) -> join("n$(n)_$(a) -> n$(n)_$(b)\n"
        for (a,b) in row)
    text = join("""
        subgraph cluster_$i {
            label="$i"
            $(nodes(i, row))
            $(edges(i, row))
        }
        """
        for (i,row) in enumerate(data)
    )
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
    print(viz(data))
    return 0
end

