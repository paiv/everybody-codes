include("../gridos.jl")

const Program = rule"""
    HEADS AAAAACCBBA

    START ********** S1 ********** SDDDDRRRRR
    S1 ********** S2 ********** SSDDDRRRRS
    S2 ********** S3 ********** SSSDDSDUSS
    S3 ********** I  ********** SSSSDDDDDS

    I a________! Ma____ _********* RRRRRRRRRR
    I a_________ STOP   _********* RRRRRRRRRR
    I ab_______! Maa___ x_******** RRRRRRRRRR
    I ab________ STOP   x_******** RRRRRRRRRR
    I abc______! Maaa__ xx_******* RRRRRRRRRR
    I abc_______ STOP   xx_******* RRRRRRRRRR
    I abcd_____! Maaaa_ xxx_****** RRRRRRRRRR
    I abcd______ STOP   xxx_****** RRRRRRRRRR
    I abcde____! Maaaaa xxxx_***** RRRRRRRRRR
    I abcde_____ STOP   xxxx_***** RRRRRRRRRR

    Mf____ a________! Ma____ _****z**** RRRRRRRRRR
    Mf____ a_________ STOP   _****z**** RRRRRRRRRR
    Mfg___ ab_______! Maa___ x_***zz*** RRRRRRRRRR
    Mfg___ ab________ STOP   x_***zz*** RRRRRRRRRR
    Mfgh__ abc______! Maaa__ xx_**zzz** RRRRRRRRRR
    Mfgh__ abc_______ STOP   xx_**zzz** RRRRRRRRRR
    Mfghi_ abcd_____! Maaaa_ xxx_*zzzz* RRRRRRRRRR
    Mfghi_ abcd______ STOP   xxx_*zzzz* RRRRRRRRRR
    Mfghij abcde____! Maaaaa xxxxyzzzz* RRRRRRRRRR
    Mfghij abcde_____ STOP   xxxxyzzzz* RRRRRRRRRR
"""

const NamesRead = Dict(
    :a => "AB",
    :b => "AB",
    :c => "AB",
    :d => "AB",
    :e => "AB",
    :f => "AB",
    :g => "AB",
    :h => "AB",
    :i => "AB",
    :j => "AB",
)

const NamesWrite = Dict(
    :a => (v,i) -> v[i-1],
    :x => (v,i) -> ((v[i] == v[i+1]) ? '@' : '_'),
    :y => (v,i,s) -> ((v[i] == s[i+1]) ? '@' : '_'),
    :z => (v,i,s) -> ((v[i-5] == s[i-4]) ? '@' : '*'),
)

