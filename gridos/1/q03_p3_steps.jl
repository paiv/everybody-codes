include("../gridos.jl")

const abc = string(0:9..., 'A':'F'..., 'a':'e'...)
const abp = Dict(zip(abc, abc[2:end]))
const E = abc[21]
const ijk = "IJKLMNOP"
const ijp = merge!(Dict(zip(ijk, ijk[2:end])), Dict('P'=>'A'))

const NamesRead = Dict(
    :i => ijk,
    :e => E,
    :x => "01234567",
    :n => abc[1:end-1],
)

const NamesWrite = Dict(
    :y => (v,i,s) -> parse(Int,s[2])+1,
    :z => (v,i,s) -> i<=(parse(Int,s[2])+2)÷2 ? '~' : '*',
    :d => (v,i,s) -> i<=(findfirst(s[1],ijk)+1) ? 'R' : 'D',
    :m => (v,i,s) -> abp[s[2]],
    :w => (v,i,s) -> i<=(findfirst(s[2],abc)+1)÷2 ? '~' : '*',
    :j => (v,i,s) -> ijp[s[1]],
)

const Program = rule"""
    HEADS AAAAAAAAAA
    START ########## I0 ********** RDDDDDDDDD

    ix #_________ j0 ********** dddddddddd
    ix =_________ jy zzzzzzzzzz dddddddddd
    i0 __________ STOP ********** SSSSSSSSSS

    An #_________ A0 ********** RRRRRRRRRR
    Ae #_________ A0 ********** RRRRRRRRRR
    Ae =_________ B0 ~~~~~~~~~~ RDDDDDDDDD
    An =_________ Am wwwwwwwwww RRRRRRRRRR
    A0 __________ STOP ********** SSSSSSSSSS

    B0 #_________ α ********** LLLLLLLLLL
    α  ~~~~~~~~~_ β *********~ RRRRRRRRRR
    β  #_________ F ********** LUUUUUUUUU
    F  ~~~~~~~~~~ F ********** RRRRRRRRRR
    F  ~_~~~~~~~~ F *~******** RRRRRRRRRR
    F  #_________ A0 ********** RRRRRRRRRR

    B0 =_________ C ********** LLLLLLLLLL
    C ~~~~~~~~~_ D *********~ RRRRRRRRRR
    E =_________ B0 ~~~~~~~~~~ RDDDDDDDDD
    D =_________ E ~~~~~~~~~~ RRRRRRRRRR
    E #_________ γ ********** LUUUUUUUUU
    γ ~_~~~~~~~~ δ *~******** LLLLLLLLLL
    δ ~~~~~~~~~~ γ ********** LUUUUUUUUU
    γ ~~~~~~~~~~ ε ********** RDDDDDDDDD
    ε ~~~~~~~~~~ F ********** RRRRRRRRRR


    """
