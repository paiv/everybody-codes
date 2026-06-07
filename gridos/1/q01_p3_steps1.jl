include("../gridos.jl")

const START = :A0

function program(N=300)
    res = ["HEADS A"]
    for i=-10:N
        push!(res, "A$i A B$(i-1) P D")
        push!(res, "A$i B B$i P D")
        push!(res, "A$i C B$(i+2) P D")
        push!(res, "A$i D B$(i+4) P D")

        push!(res, "B$i _ C$(i-1) P R")
        push!(res, "B$i A C$(i+1) P R")
        push!(res, "B$i B C$(i+2) P R")
        push!(res, "B$i C C$(i+4) P R")
        push!(res, "B$i D C$(i+6) P R")

        push!(res, "C$i _ D$(i-1) P U")
        push!(res, "C$i A D$(i+1) P U")
        push!(res, "C$i B D$(i+2) P U")
        push!(res, "C$i C D$(i+4) P U")
        push!(res, "C$i D D$(i+6) P U")

        push!(res, "D$i A A$(i-1) P R")
        push!(res, "D$i B A$i P R")
        push!(res, "D$i C A$(i+2) P R")
        push!(res, "D$i D A$(i+4) P R")

        push!(res, "A$i _ T$(i-1) P R")
        push!(res, "D$i _ T$(i-1) P R")
    end
    for i=1:N
        push!(res, "T$i _ T$(i-1) P R")
    end
    push!(res, "T0 _ STOP * S")
    push!(res, "T-1 _ U-1 * L")
    for i=-10:-2
        push!(res, "T$i _ U$i * L")
        push!(res, "U$i P V$(i+1) _ D")
        push!(res, "V$i P W$(i+1) _ L")
        push!(res, "W$i P X$(i+1) _ U")
        push!(res, "X$i P U$(i+1) _ L")
    end
    push!(res, "U-1 P STOP _ S")
    push!(res, "V-1 P STOP _ S")
    push!(res, "W-1 P STOP _ S")
    push!(res, "X-1 P STOP _ S")
    join(res, '\n')
end

