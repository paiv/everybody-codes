include("../gridos.jl")

function program(N=300)
    res = ["HEADS AA"]
    push!(res, "START ** A0 ** SD")
    for i=-10:N
        push!(res, "A$i A_ A$(i-2) PP RR")
        push!(res, "A$i AA A$(i+0) PP RR")
        push!(res, "A$i AB A$(i+1) PP RR")
        push!(res, "A$i AC A$(i+3) PP RR")
        push!(res, "A$i AD A$(i+5) PP RR")

        push!(res, "A$i B_ A$(i-1) PP RR")
        push!(res, "A$i BA A$(i+1) PP RR")
        push!(res, "A$i BB A$(i+2) PP RR")
        push!(res, "A$i BC A$(i+4) PP RR")
        push!(res, "A$i BD A$(i+6) PP RR")

        push!(res, "A$i C_ A$(i+1) PP RR")
        push!(res, "A$i CA A$(i+3) PP RR")
        push!(res, "A$i CB A$(i+4) PP RR")
        push!(res, "A$i CC A$(i+6) PP RR")
        push!(res, "A$i CD A$(i+8) PP RR")

        push!(res, "A$i D_ A$(i+3) PP RR")
        push!(res, "A$i DA A$(i+5) PP RR")
        push!(res, "A$i DB A$(i+6) PP RR")
        push!(res, "A$i DC A$(i+8) PP RR")
        push!(res, "A$i DD A$(i+10) PP RR")
    end
    for i=-10:-1
        push!(res, "A$i __ T$i ** LL")
    end
    for i=-10:-3
        push!(res, "T$i PP T$(i+2) __ LL")
    end
    for i=3:N
        push!(res, "A$i __ T$(i-2) PP RR")
        push!(res, "T$i __ T$(i-2) PP RR")
    end
    push!(res, "A2 __ STOP PP RR")
    push!(res, "A1 __ STOP P* RR")
    push!(res, "A0 __ STOP ** SS")
    push!(res, "T2 __ STOP PP RR")
    push!(res, "T1 __ STOP P* RR")
    push!(res, "T-1 PP STOP *_ SS")
    push!(res, "T-2 PP STOP __ SS")
    join(res, '\n')
end

