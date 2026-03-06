#!/usr/bin/env julia
import Dates: DateTime, datetime2unix, today, year, @dateformat_str
import Downloads: Downloads, Downloader
import JSON
import MbedTLS
import Printf: @sprintf
import TOML
import URIs: URI, absuri


const _BaseUrl = "https://api.everybody.codes"
const _BaseCdn = "https://everybody.codes"
const _DefaultEvent = "event/$(year(today()))"


mutable struct ApiSession
    baseurl::URI
    wpool::Downloader
    cpool::Downloader
    headers::Vector{Pair{String,String}}
    seed::Union{String,Nothing}
    function ApiSession(; headers, baseurl=_BaseUrl, seed=nothing)
        new(URI(baseurl), Downloader(), Downloader(), headers, seed)
    end
end


function apigetjson(api::ApiSession, url::URI)
    println(stderr, url)
    io = IOBuffer()
    r = Downloads.request(string(url), output=io, headers=api.headers,
        throw=false, timeout=10, downloader=api.wpool, verbose=false)
    !hasfield(typeof(r), :status) && error(r)
    r.status >= 300 && error(r)
    JSON.parse(String(take!(io)))
end


function parserfcdate(s::AbstractString)
    try
        return DateTime(s, dateformat"e, dd uuu yyyy HH:MM:SS \G\M\T")
    catch e
        try
            return DateTime(s, dateformat"e, dd-uuu-yyyy HH:MM:SS \G\M\T")
        catch
            dump(s)
            println(stderr, e)
        end
    end
end


function setfiledatefromheaders(headers::AbstractArray{Pair{String,String}}, fn::AbstractString)
    i = findfirst(==("last-modified")∘lowercase∘first, headers)
    isnothing(i) && return
    kv = headers[i]
    dt = parserfcdate(last(kv))
    isnothing(dt) && return
    t = datetime2unix(dt)
    fp = Base.Filesystem.open(fn, Base.Filesystem.JL_O_RDWR)
    Base.Filesystem.futime(fp, t, t)
    close(fp)
end


function apigetfile(api::ApiSession, fn::AbstractString, url::URI)
    println(stderr, url)
    h = filter(!=("Cookie")∘first, api.headers)
    r = Downloads.request(string(url), output=fn, headers=h,
        throw=false, timeout=10, downloader=api.cpool, verbose=false)
    !hasfield(typeof(r), :status) && error(r)
    r.status >= 300 && error(r)
    setfiledatefromheaders(r.headers, fn)
    return r
end


function apiget(api::ApiSession, url::AbstractString)
    ts = @sprintf "%.3f" time()
    url = absuri("$url?t=$ts", api.baseurl)
    apigetjson(api, url)
end


function cdnget(api::ApiSession, fn::AbstractString, url::AbstractString)
    ts = @sprintf "%.3f" time()
    url = absuri("$url?t=$ts", _BaseCdn)
    apigetfile(api, fn, url)
end


api_me(api::ApiSession) = apiget(api, "/user/me")

function api_questkeys(api::ApiSession, event::AbstractString, quest::AbstractString)
    apiget(api, "/event/$event/quest/$quest")
end

cdn_getnotes(api::ApiSession, fn::AbstractString, event::AbstractString, quest::AbstractString) =
    cdnget(api, fn, "/assets/$event/$quest/input/$(api.seed).json")

cdn_getinfo(api::ApiSession, fn::AbstractString, event::AbstractString, quest::AbstractString) =
    cdnget(api, fn, "/assets/$event/$quest/description.json")


function readenv()
    fn = joinpath(dirname(@__FILE__), ".env")
    env = TOML.parsefile(fn)
    codes = env["everybody-codes"]
    seed = get(codes, "seed", nothing)
    event = get(codes, "event", nothing)
    headers = Dict{String,String}(codes["headers"]...)
    res = Dict{String,Any}("headers"=>headers)
    for k in ["seed", "event"]
        k in keys(codes) && (res[k] = codes[k])
    end
    return res
end


function opensession(headers; seed=nothing)
    api = ApiSession(headers=collect(headers))
    if isnothing(seed)
        me = api_me(api)
        seed = me["seed"]
        @show seed
    end
    api.seed = seed
    return api
end


mutable struct DbEvent
    event::String
    eventid::SubString
    quest::String
    path::String
    function DbEvent(event, quest)
        _, eid = split(event, '/')
        path = joinpath(dirname(@__FILE__), event)
        new(event, eid, quest, path)
    end
end


function dbopenevent(event, quest)
    db = DbEvent(event, quest)
    if !isdir(db.path)
        println(db.path)
        print("create directory? [Y/n]: ")
        s = readline()
        s ∉ ["", "Y", "y"] && exit()
        mkpath(db.path)
    end
    return db
end


function dbgetinputfilename(db)
    qid = lpad(db.quest, 2, '0')
    joinpath(db.path, "q$qid.in")
end


function dbgetpartfilename(db, pid)
    qid = lpad(db.quest, 2, '0')
    joinpath(db.path, "q$(qid)_p$(pid).txt")
end


function dbgetinfofilename(db)
    qid = lpad(db.quest, 2, '0')
    joinpath(db.path, "q$(qid)_info.in")
end


function dbgetpartinfofilename(db, pid)
    qid = lpad(db.quest, 2, '0')
    joinpath(db.path, "q$(qid)_p$(pid).html")
end


function trydecryptinput(api, db, pid, cc)
    fn = dbgetinputfilename(db)
    kfn = "$fn.key"
    obj = Dict{String,Any}()
    if isfile(kfn)
        obj = JSON.parsefile(kfn)
    end
    if "key$pid" ∉ keys(obj)
        obj = api_questkeys(api, db.eventid, db.quest)
        JSON.json(kfn, obj)
    end
    k = get(obj, "key$pid", nothing)
    isnothing(k) && return
    MbedTLS.decrypt(MbedTLS.CIPHER_AES, k, hex2bytes(cc), k[1:16])
end


const _usage = """
prep.jl [-h] [-e EVENT] quest
"""


const _help_page = """
prep.jl [-h] [-e EVENT] quest

Download input notes of the quest.
Call prep repeatedly after solving each part of the quest.

Positional arguments:
  quest     quest number

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
    quest = nothing
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
                quest = s
            end
        elseif state == 1
            event = s
            state = 0
        end
    end
    if state == 1
        argerror("option needs a value: --event")
    end
    if isnothing(quest)
        argerror("missing quest")
    end
    res = Dict{String,Any}("quest"=>quest)
    !isnothing(event) && (res["event"] = event)
    return res
end


function main()
    args = parseargs(ARGS)
    env = merge(readenv(), args)
    api = opensession(env["headers"], seed=env["seed"])
    event = get(env, "event", _DefaultEvent)
    quest = env["quest"]
    db = dbopenevent(event, quest)
    all(1:3) do i
        fn = dbgetpartfilename(db, i)
        (t = isfile(fn)) && println(stderr, "$(basename(fn)) ok")
        return t
    end && return

    infn = dbgetinputfilename(db)
    infofn = dbgetinfofilename(db)
    if !isfile(infn)
        cdn_getnotes(api, infn, db.eventid, db.quest)
    end
    if !isfile(infofn)
        cdn_getinfo(api, infofn, db.eventid, db.quest)
    end
    function process(ff, ifn, xid=typemax(Int))
        obj = JSON.parsefile(ifn)
        lastpid = 0
        for (p, cc) in obj
            pid = tryparse(Int, p)
            if isnothing(pid)
                s = trydecryptinput(api, db, 1, cc)
                !isnothing(s) && println(stderr, String(s))
                continue
            end
            pid > xid && continue
            fn = ff(db, pid)
            if !isfile(fn)
                s = trydecryptinput(api, db, pid, cc)
                isnothing(s) && return lastpid
                lastpid = pid
                write(fn, s)
                println(stderr, fn)
            end
            println(stderr, "$(basename(fn)) ok")
        end
        return lastpid
    end
    i = process(dbgetpartfilename, infn)
    process(dbgetpartinfofilename, infofn, i)
end

main()
