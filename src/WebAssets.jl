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
    registry::Dict{Symbol, String}
end
Project(dir::String) = Project(dir, Dict{Symbol, String}())

dir(p::Project) = getfield(p, :dir)
registry(p::Project) = getfield(p, :registry)
url(p::Project, name::Symbol) = filename2url(basename(getproperty(p, name)))

Base.:(==)(a::Project, b::Project) = propertynames(a) == propertynames(b) && all(url(a, x) == url(b, x) for x in propertynames(a))

function Base.show(io::IO, p::Project)
    print(io, "Project")
    printstyled(io, "(dir=\"$(dir(p))\")"; color=:light_black)
    for (k, v) in registry(p)
        printstyled(io, "\n    • ", k, ": "; color=:light_cyan)
        printstyled(io, filename2url(basename(v)); color=:light_green)
    end
end

Base.propertynames(p::Project) = collect(keys(registry(p)))

function Base.setproperty!(p::Project, name::Symbol, url::String)
    try
        path = joinpath(dir(p), url2filename(url))
        if !isfile(path)
            @info "WebAssets - Downloading: $url"
            download(url, path)
        end
        registry(p)[name] = path
    catch
        error("\"$url\" failed to download.  Check the URL and your internet connection.")
    end
end

Base.getproperty(p::Project, name::Symbol) = registry(p)[name]


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
        x isa Expr && x.head == :(=) && x.args[1] isa Symbol && x.args[2] isa String ||
            error("Arguments to @project are expected to be of the form: `name = \"url\"`.  Found: `$x`")
        x.args[1] = Expr(:., :proj, QuoteNode(x.args[1]))
        x
    end

    esc(quote
        let
            proj = WebAssets.Project(WebAssets.Scratch.@get_scratch!("web_assets_jl"))
            $(x2...)
            proj
        end
    end)
end

end
