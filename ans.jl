#!/usr/bin/env julia
import Dates: today, year
import Downloads: Downloads, Downloader
import JSON
import TOML
import URIs: URI, absuri


const _BaseUrl = "https://everybody.codes"
const _DefaultEvent = "event/$(year(today()))"


mutable struct ApiSession
    baseurl::URI
    pool::Downloader
    headers::Vector{Pair{String,String}}
    function ApiSession(; headers, baseurl=_BaseUrl)
        new(URI(baseurl), Downloader(), headers)
    end
end


function apipostjson(api::ApiSession, url::URI, obj)
    s = JSON.json(obj)
    println(stderr, "POST $url $s")
    oi = IOBuffer(s)
    io = IOBuffer()
    headers = [api.headers; "Content-Type"=>"application/json"]
    r = Downloads.request(string(url), input=oi, output=io,
        method="POST", headers=headers,
        downloader=api.pool, verbose=false)
    res = String(take!(io))
    !isempty(res) && return JSON.parse(res)
    nothing
end


function apipost(api::ApiSession, url::AbstractString, obj)
    url = absuri(url, api.baseurl)
    apipostjson(api, url, obj)
end


function api_answer(api::ApiSession, event::AbstractString, quest::AbstractString,
    part::Int, ans)
    obj = Dict("answer"=>string(ans))
    apipost(api, "/api/event/$event/quest/$quest/part/$part/answer", obj)
end


function readenv()
    fn = joinpath(dirname(@__FILE__), ".env")
    env = TOML.parsefile(fn)
    codes = env["everybody-codes"]
    event = get(codes, "event", nothing)
    headers = Dict{String,String}(codes["headers"]...)
    res = Dict{String,Any}("headers"=>headers)
    for k in ["event"]
        k in keys(codes) && (res[k] = codes[k])
    end
    return res
end


function opensession(headers)
    ApiSession(headers=collect(headers))
end


mutable struct DbEvent
    event::String
    eventid::SubString
    quest::String
    function DbEvent(event, quest)
        _, eid = split(event, '/')
        new(event, eid, quest)
    end
end


const _usage = """
ans.jl [-h] [-e EVENT] quest part answer
"""


const _help_page = """
prep.jl [-h] [-e EVENT] quest part answer

Submit answer to the quest.

Positional arguments:
  quest     quest number
  part      part number
  answer    answer value

Options:
  -e,--event    event name (default: '$(_DefaultEvent)')
  -h,--help     print this help page
"""


function argerror(message)
    print(_usage)
    error(message)
end


function parseargs(args)
    state = 0
    event = nothing
    pos = String[]
    for s in args
        if state == 0
            if startswith(s, "-")
                if s == "-h" || s == "--help"
                    print(_help_page); exit()
                elseif s == "-e" || s == "--event"
                    state = 1
                else
                    argerror("unknown option $s")
                end
            else
                push!(pos, s)
            end
        elseif state == 1
            event = s
            state = 0
        end
    end
    if state == 1
        argerror("option needs a value: --event")
    end
    length(pos) < 1 && argerror("missing quest")
    length(pos) < 2 && argerror("missing part")
    length(pos) < 3 && argerror("missing answer")
    part = parse(Int, pos[2])
    quest, answer = pos[1], pos[end]
    res = Dict{String,Any}("quest"=>quest, "part"=>part, "answer"=>answer)
    !isnothing(event) && (res["event"] = event)
    return res
end


function main()
    args = parseargs(ARGS)
    env = merge(readenv(), args)
    event = get(env, "event", _DefaultEvent)
    db = DbEvent(event, env["quest"])
    part, ans = env["part"], env["answer"]
    api = opensession(env["headers"])
    res = api_answer(api, db.eventid, db.quest, part, ans)
    if isnothing(res)
        println("ignored")
    else
        for (k,v) in res
            println("$k: $v")
        end
    end
end

main()
