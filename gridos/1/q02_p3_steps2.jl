include("../gridos.jl")

const Program = rule"""
    HEADS AAAAABBBBB

    START ********** RL ********** SRDULRUDLS

    RL A________A STOP _********_ SSSSSSSSSS
    RL a________a STOP _********_ SSSSSSSSSS
    RL B________B STOP _********_ SSSSSSSSSS
    RL b________b STOP _********_ SSSSSSSSSS
    RL aa______aa STOP __*@****__ SSSSSSSSSS
    RL ab______ab STOP __******__ SSSSSSSSSS
    RL ba______ba STOP __******__ SSSSSSSSSS
    RL bb______bb STOP __*@****__ SSSSSSSSSS
    LR _a______a_ STOP *_******_* SSSSSSSSSS
    LR _a______b_ STOP *_******_* SSSSSSSSSS
    LR _b______a_ STOP *_******_* SSSSSSSSSS
    LR _b______b_ STOP *_******_* SSSSSSSSSS
    II A________A STOP _********_ SSSSSSSSSS
    II B________B STOP _********_ SSSSSSSSSS

    RL cde____fgk RL _l*styx*l_ RRRRLRLLLL
    RL c_d____d_c II _**t**t**_ DDDDDDDDDD
    RL lmd____glm JJ __*styw*__ DDDDDDDDDD
    LR dce____fkg LR l_*suzx*_l LLLLRLRRRR
    LR _cd____gk_ DR *_**uz**_* DDDDDDDDDD
    MM dge____egi LR *_*usxu*_* LLLLRLRRRR

    II *!******!* MM ********** LLSSSSSSRR
    JJ ********** LR ********** LLSSSSSSRR
    DR ********** RL ********** RRSSSSSSLL

"""

const NamesRead = Dict(
    :c => "ABab",
    :d => "AB",
    :e => "_AB",
    :f => "_AB",
    :g => "AB",
    :h => "AB",
    :i => "AB",
    :k => "ABab",
    :l => "ab",
    :m => "ab",
)

const NamesWrite = Dict(
    :l => (v,i) -> lowercase(v[i]),
    :s => v -> (uppercase(v[1]) == uppercase(v[2]) ? '@' : '*'),
    :t => v -> (uppercase(v[1]) == uppercase(v[3]) ? '@' : '*'),
    :u => v -> (uppercase(v[2]) == uppercase(v[3]) ? '@' : '*'),
    :w => v -> (uppercase(v[3]) == uppercase(v[8]) ? '@' : '*'),
    :x => v -> (uppercase(v[10]) == uppercase(v[9]) ? '@' : '*'),
    :y => v -> (uppercase(v[10]) == uppercase(v[8]) ? '@' : '*'),
    :z => v -> (uppercase(v[9]) == uppercase(v[8]) ? '@' : '*'),
)

function Base.show(io::IO, image::Image)
    println(io, sum(==('@'),values(image.grid)), ' ', image.state)
    render(io, image.grid, pois=image.heads)
end


