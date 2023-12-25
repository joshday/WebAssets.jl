module WebAssets

import Downloads: download
using Scratch

export Project, @project

#-----------------------------------------------------------------------------# url2filename
charmap = [':' => 'C', '/' => 'S', '?' => 'Q', '{' => 'L', '}' => 'R']
url2filename(url) = replace(lowercase(url), charmap...)
filename2url(file) = replace(file, reverse.(charmap)...)

#-----------------------------------------------------------------------------# Project
struct Project
    dir::String
    registry::Dict{Symbol, String}  # name => url
end
Project(dir::String; kw...) = Project(dir, Dict{Symbol, String}(kw))

dir(p::Project) = getfield(p, :dir)
registry(p::Project) = getfield(p, :registry)

function Base.:(==)(a::Project, b::Project)
    propertynames(a) == propertynames(b) && all(getproperty(a,x) == getproperty(b,x) for x in propertynames(a))
end

function Base.show(io::IO, p::Project)
    print(io, "Project")
    printstyled(io, "(dir=\"$(dir(p))\")"; color=:light_black)
    for (k, v) in registry(p)
        printstyled(io, "\n    • ", k, ": "; color=:light_cyan)
        printstyled(io, filename2url(basename(v)); color=:light_green)
    end
end

# core function:
function get_asset(path::String, url::String)
    try
        if !isfile(path)
            @info "WebAssets - Downloading: $url"
            download(url, path)
        end
        return path
    catch
        error("\"$url\" failed to download.  Check the URL and your internet connection.")
    end
end

Base.propertynames(p::Project) = collect(keys(registry(p)))

Base.getproperty(p::Project, name::Symbol) = get_asset(p, registry(p)[name])

function Base.setproperty!(p::Project, name::Symbol, url::String)
    registry(p)[name] = url
end

function Base.delete!(p::Project, name::Symbol)
    rm(getproperty(p, name))
    delete!(registry(p), name)
end
Base.setproperty!(p::Project, name::Symbol, ::Nothing) = delete!(p, name)


function update!(p::Project, name::Symbol)
    _url = url(p, name)
    delete!(p, name)
    setproperty!(p, name, _url)
end
update!(p::Project) = foreach(x -> update!(p, x), propertynames(p))


#-----------------------------------------------------------------------------# @project
macro project(x...)
    x2 = map(x) do x
        x isa Expr && x.head == :(=) && x.args[1] isa Symbol ||
            error("Arguments to @project are expected to be of the form: `name = \"url\"`.  Found: `$x`")
        x.args[1] = Expr(:., :proj, QuoteNode(x.args[1]))
        x
    end

    esc(quote
        let
            proj = WebAssets.Project(WebAssets.Scratch.@get_scratch!("WebAssets_jl"))
            $(x2...)
            proj
        end
    end)
end

end
