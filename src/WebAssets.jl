module WebAssets

import Downloads: download
using Dates, Scratch, StyledStrings

#-----------------------------------------------------------------------------# dir
const MODULE = Ref{Module}(Main)

dir(m::Module = MODULE[]) = Scratch.get_scratch!(m, "WebAssets_cache")

#-----------------------------------------------------------------------------# url2filename
const charmap = (':' => 'C', '/' => 'S', '?' => 'Q', '{' => 'L', '}' => 'R', '#' => 'H', '%' => 'P',
    '&' => 'A', '\\' => 'B', '<' => 'K', '>' => 'G', '*' => 'X', '$' => 'D', '!' => 'E', '"' => 'W',
    '\'' => 'O', '|' => 'I')

"Convert a URL to a filesystem-safe filename."
url2filename(url) = replace(lowercase(url), charmap...)

"Convert a filename produced by `url2filename` back to its original URL."
filename2url(file) = replace(file, reverse.(charmap)...)

"Return the full path in directory `d` (default: `dir()`) for the given URL."
url2path(url, d::AbstractString = dir()) = joinpath(d, url2filename(url))

"Recover the URL from a file path produced by `url2path`."
path2url(path) = filename2url(basename(path))

#-----------------------------------------------------------------------------# add
"""
    add(url; force=false, kw...)
    add(m::Module, url; force=false, kw...)

Download `url` to the scratch space and return the local file path.
Skips the download if the file is already cached, unless `force=true`.
Keyword arguments are forwarded to `Downloads.download`.
"""
add(url; kw...) = add(MODULE[], url; kw...)

function add(m::Module, url; force::Bool=false, kw...)
    file = url2path(url, dir(m))
    isfile(file) && !force ? file : download(url, file; kw...)
end

"Equivalent to `add(@__MODULE__, url; kwargs...)`."
macro add(url, kwargs...)
    kws = [Expr(:kw, a.args[1], esc(a.args[2])) for a in kwargs]
    :(add($__module__, $(esc(url)); $(kws...)))
end

"""
    @download(args...; kwargs...)

Call `Downloads.download(args..., output; kwargs...)` where `output` is a path in the calling
module's scratch space derived from a hash of the arguments. Returns the output path.
Specifying `output` explicitly is an error — it is managed by WebAssets.
"""
macro download(args...)
    pos_args = Any[]
    kw_args  = Any[]
    for arg in args
        if Meta.isexpr(arg, :parameters)
            for kw in arg.args
                Meta.isexpr(kw, :kw) && kw.args[1] == :output &&
                    error("@download: `output` is managed by WebAssets — do not specify it")
                push!(kw_args, kw)
            end
        elseif Meta.isexpr(arg, (:(=), :kw)) && arg.args[1] == :output
            error("@download: `output` is managed by WebAssets — do not specify it")
        else
            push!(pos_args, arg)
        end
    end
    quote
        let _key = string(hash(("Downloads.download", $(map(esc, pos_args)...), (; $(map(esc, kw_args)...)))), base=16)
            _path = joinpath(dir($__module__), _key)
            isfile(_path) || download($(map(esc, pos_args)...), _path; $(map(esc, kw_args)...))
            _path
        end
    end
end

#-----------------------------------------------------------------------------# list
"Extract the host (e.g. `\"cdn.jsdelivr.net\"`) from a URL string."
function gethost(url::AbstractString)
    m = match(r"^[a-z]+://([^/:]+)", url)
    isnothing(m) ? "" : m.captures[1]
end

"""
    list(m::Module = MODULE[]; domain="", subdomain="")

Return a vector of cached asset URLs for module `m`.
Optionally filter by `domain` (e.g. `"jsdelivr.net"`) or `subdomain` (e.g. `"cdn"`).
"""
function list(m::Module = MODULE[]; domain::AbstractString="", subdomain::AbstractString="")
    urls = path2url.(readdir(dir(m)))
    !isempty(domain) && filter!(u -> occursin(domain, gethost(u)), urls)
    !isempty(subdomain) && filter!(u -> startswith(gethost(u), subdomain * "."), urls)
    return urls
end

"Equivalent to `list(@__MODULE__; kwargs...)`."
macro list(kwargs...)
    kws = [Expr(:kw, a.args[1], esc(a.args[2])) for a in kwargs]
    :(list($__module__; $(kws...)))
end

#-----------------------------------------------------------------------------# remove
"""
    remove(url)
    remove(m::Module, url)

Delete the cached file for `url` from the scratch space. No-ops if the file does not exist.
"""
remove(url) = remove(MODULE[], url)

function remove(m::Module, url)
    file = url2path(url, dir(m))
    isfile(file) && rm(file)
end

"Equivalent to `remove(@__MODULE__, url)`."
macro remove(url)
    :(remove($__module__, $(esc(url))))
end

#-----------------------------------------------------------------------------# info
"""
    Info

Metadata for a cached asset.

# Fields
- `path::String` — the local file path in the scratchspace
- `downloaded::DateTime` — when the file was cached
- `size::Int` — file size in bytes
"""
struct Info
    path::String
    downloaded::DateTime
    size::Int
end

Info(path::AbstractString) = Info(path, unix2datetime(mtime(path)), filesize(path))

"""
    info(m::Module = MODULE[])

Return a `Vector{Info}` describing all cached assets for module `m`.
"""
info(m::Module = MODULE[]) = Info.(readdir(dir(m); join=true))

"Equivalent to `info(@__MODULE__)`."
macro info()
    :(info($__module__))
end

remove(x::Info) = isfile(x.path) && rm(x.path)

function Base.show(io::IO, x::Info)
    name = basename(x.path)
    url = filename2url(name)
    label = occursin("://", url) ? url : x.path
    s = styled"{bright_black:$label} {bright_cyan:$(x.downloaded)} {bright_yellow:$(Base.format_bytes(x.size))}"
    print(io, s)
end

end
