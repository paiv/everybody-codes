#!/usr/bin/env julia

function parsenotes(text)
    parse.(Int, stack(split(text), dims=1))
end


function viz(io, data)
    pal = [
        [0x5E, 0x4F, 0xA2],
        [0x32, 0x88, 0xBD],
        [0x66, 0xC2, 0xA5],
        [0xAB, 0xDD, 0xA4],
        [0xE6, 0xF5, 0x98],
        [0xFE, 0xE0, 0x8B],
        [0xFD, 0xAE, 0x61],
        [0xF4, 0x6D, 0x43],
        [0xD5, 0x3E, 0x4F],
        [0x9E, 0x01, 0x42],
    ]
    h, w = size(data)
    s = """
    P3
    $w $h 255
    """
    print(s)
    for s in eachrow(data)
        for x in s .+ 1
            println(join(pal[x], ' '))
        end
    end
end


function parseargs(args)
    usage = """
    usage: viz.jl <data.txt> > out.ppm
    """
    if isempty(args)
        print(usage); exit()
    end

    fn = nothing
    out = nothing
    state = 0

    for s in args
        if state == 0
            if startswith(s, "-")
                if s == "-"
                    fn = stdin
                elseif s == "-h" || s == "--help"
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
    isnothing(out) && (out = stdout)
    (; fn, out)
end


function main(args)
    data = readchomp(args.fn)
    s = parsenotes(data)
    viz(args.out, s)
end


main(parseargs(ARGS))
