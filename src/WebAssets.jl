module WebAssets

import Downloads: download
using Dates, Scratch, StyledStrings

export @add, @list, @remove, @update


dir() = Scratch.@get_scratch!("WebAssets_jl")
dir(m::Module) = Scratch.get_scratch!(m, "assets")

#-----------------------------------------------------------------------------# url2filename
const charmap = (':' => 'C', '/' => 'S', '?' => 'Q', '{' => 'L', '}' => 'R', '#' => 'H', '%' => 'P',
    '&' => 'A', '\\' => 'B', '<' => 'K', '>' => 'G', '*' => 'X', '$' => 'D', '!' => 'E', '"' => 'W',
    '\'' => 'O', '|' => 'I')

url2filename(url) = replace(lowercase(url), charmap...)

filename2url(file) = replace(file, reverse.(charmap)...)

url2path(url) = joinpath(dir(), url2filename(url))
url2path(url, d::AbstractString) = joinpath(d, url2filename(url))

path2url(path) = filename2url(basename(path))


#-----------------------------------------------------------------------------# add
function add(url; force::Bool=false)
    file = url2path(url)
    return isfile(file) && !force ? file : download(url, file)
end
function add(m::Module, url; force::Bool=false)
    file = url2path(url, dir(m))
    return isfile(file) && !force ? file : download(url, file)
end

#-----------------------------------------------------------------------------# list
function list()
    path2url.(readdir(dir()))
end
list(m::Module) = path2url.(readdir(dir(m)))

#-----------------------------------------------------------------------------# remove
function remove(url)
    file = url2path(url)
    isfile(file) && rm(file)
end
function remove(m::Module, url)
    file = url2path(url, dir(m))
    isfile(file) && rm(file)
end

#-----------------------------------------------------------------------------# info
struct Info
    url::String
    downloaded::DateTime
    size::Int
end

function Info(path::AbstractString)
    Info(path2url(path), unix2datetime(mtime(path)), filesize(path))
end

function info()
    Info.(readdir(dir(); join=true))
end
info(m::Module) = Info.(readdir(dir(m); join=true))

function Base.show(io::IO, x::Info)
    s = styled"{bright_black:$(x.url)} {bright_cyan:$(x.downloaded)} {bright_yellow:$(Base.format_bytes(x.size))}"
    print(io, s)
end

end
