module WebAssets

import Scratch
import Downloads: download

export @asset, @list

#-----------------------------------------------------------------------------# settings
"Subdirectory of the scratch directory to store assets in."
scratchdir = "WebAssets_jl"

#-----------------------------------------------------------------------------# url2filename
charmap = [':' => 'C', '/' => 'S', '?' => 'Q']

url2filename(url) = replace(lowercase(url), charmap...)

filename2url(file) = replace(file, reverse.(charmap)...)


#-----------------------------------------------------------------------------# macros
function asset(mod::Module, url::AbstractString)
    dir = Scratch.get_scratch!(mod, scratchdir)
    path = joinpath(dir, url2filename(url))
    try
        isfile(path) || WebAssets.download(url, path)
    catch
        error("`@asset \"$url\"` failed to download.  Check the URL and your internet connection.")
    end
    return path
end

asset(mod::Module, f::Function) = asset(mod, f())


"""
    @asset url

Download the asset at `url` and return the path to the downloaded file.
If the asset has already been downloaded, the cached version will be returned.
"""
macro asset(url)
    esc(:(WebAssets.asset($__module__, $url)))
end


"""
    @list

Return a list of all assets (downloaded via the `@asset` macro) of the current module.
"""
macro list()
    esc(:(WebAssets.@list($__module__)))
end

"""
    @list pkg

Return a list of all assets (downloaded via the `@asset` macro) of the module `pkg`.
"""
macro list(pkg)
    esc(quote
        let
            dir = WebAssets.Scratch.get_scratch!($pkg, WebAssets.scratchdir)
            WebAssets.filename2url.(readdir(dir))
        end
    end)
end

end
