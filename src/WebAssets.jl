module WebAssets

import Scratch
import Downloads: download

export @asset, @list

#-----------------------------------------------------------------------------# url2filename
charmap = [':' => 'C', '/' => 'S', '?' => 'Q']

url2filename(url) = replace(lowercase(url), charmap...)

filename2url(file) = replace(file, reverse.(charmap)...)

#-----------------------------------------------------------------------------# StaticAsset
struct StaticAsset
    url::String
end

struct VersionedAsset
    get_versions::Function
end

#-----------------------------------------------------------------------------# @asset
macro asset(url)
    Base.remove_linenums!(esc(quote
        let
            dir = WebAssets.Scratch.get_scratch!($__module__, "__ASSETS__")
            path = joinpath(dir, WebAssets.url2filename($url))
            isfile(path) || WebAssets.download($url, path)
            path
        end
    end))
end

macro list()
    esc(:(WebAssets.@list($__module__)))
end

macro list(pkg)
    esc(quote
        let
            dir = WebAssets.Scratch.get_scratch!($pkg, "__ASSETS__")
            WebAssets.filename2url.(readdir(dir))
        end
    end)
end

#-----------------------------------------------------------------------------#
# function github_latest_release(owner::AbstractString, repo::AbstractString; key::Symbol = :name)
#     url = "https://api.github.com/repos/$owner/$repo/releases/latest"
#     obj = JSON3.read(read(download(url)))
#     VersionNumber(obj[key])
# end

end
