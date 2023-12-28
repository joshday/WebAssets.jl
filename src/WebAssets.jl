module WebAssets

import Downloads: download
using Scratch

export @add, @list, @remove, @update

#-----------------------------------------------------------------------------# scratch_dir
const scratch_dir = "WebAssets_jl"

#-----------------------------------------------------------------------------# url2filename
charmap = [':' => 'C', '/' => 'S', '?' => 'Q', '{' => 'L', '}' => 'R']
url2filename(url) = replace(lowercase(url), charmap...)
filename2url(file) = replace(file, reverse.(charmap)...)

# Where a given asset will be downloaded
macro path(url = "")
    esc(:(joinpath(WebAssets.Scratch.@get_scratch!(WebAssets.scratch_dir), WebAssets.url2filename($url))))
end

#-----------------------------------------------------------------------------# @add
macro add(url)
    esc(quote
        let
            path = WebAssets.@path $url
            try
                if !isfile(path)
                    @info string("WebAssets - Downloading: ", $url)
                    WebAssets.download($url, path)
                end
                path
            catch
                error("\"$url\" failed to download.  Check the URL and your internet connection.")
            end
            path
        end
    end)
end

#-----------------------------------------------------------------------------# @remove
macro remove(url)
    esc(quote
        let
            path = WebAssets.@path $url
            if isfile(path)
                rm(path)
            else
                error("No asset found with URL: $url")
            end
        end
    end)
end

#-----------------------------------------------------------------------------# @list
macro list()
    esc(quote
        map(WebAssets.filename2url, readdir(WebAssets.@path))
    end)
end

#-----------------------------------------------------------------------------# @update
macro update(url)
    esc(quote
        WebAssets.@remove url
        WebAssets.@add url
    end)
end

macro update()
    esc(quote
        for url in WebAssets.@list()
            WebAssets.@update url
        end
    end)
end

end
