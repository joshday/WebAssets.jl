module WebAssets

import Scratch
import Downloads: download

export add!, remove!, list, update!

#-----------------------------------------------------------------------------# __init__
const DIR = Ref{String}()

function __init__()
    DIR[] = Scratch.@get_scratch!("registry")
end

#-----------------------------------------------------------------------------# url2filename
charmap = [':' => 'C', '/' => 'S', '?' => 'Q']
url2filename(url) = replace(lowercase(url), charmap...)
filename2url(file) = replace(file, reverse.(charmap)...)

#-----------------------------------------------------------------------------# dir!
dir!(newdir::String = Scratch.@get_scratch!("registry")) = (DIR[] = newdir)


#-----------------------------------------------------------------------------# add!
function add!(url::String; dir=DIR[])
    try
        path = joinpath(dir, url2filename(url))
        isfile(path) || download(url, path)
        return path
    catch
        error("add!(\"$url\") failed.  Check the URL and your internet connection.")
    end
end

#-----------------------------------------------------------------------------# remove!
function remove!(url::String; dir = DIR[])
    path = joinpath(dir, url2filename(url))
    isfile(path) ? rm(path) : error("No such asset: \"$url\"")
    return list()
end


#-----------------------------------------------------------------------------# list
list(; dir = DIR[]) = filename2url.(readdir(dir))

#-----------------------------------------------------------------------------# update!
function update!(url::String; dir=DIR[])
    remove!(url; dir)
    add!(url; dir)
    list(; dir)
end

function update!(; dir=DIR[])
    for url in list(dir=dir)
        @info "Updating: $url"
        update!(url; dir=dir)
    end
    list(; dir)
end

end
