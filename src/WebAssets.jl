module WebAssets

import Scratch
import Downloads: download

export @asset, @list

#-----------------------------------------------------------------------------# settings
scratchdir = "__web_assets__"

#-----------------------------------------------------------------------------# url2filename
charmap = [':' => 'C', '/' => 'S', '?' => 'Q']

url2filename(url) = replace(lowercase(url), charmap...)

filename2url(file) = replace(file, reverse.(charmap)...)

#-----------------------------------------------------------------------------# VersionedAsset
struct VersionedAsset
    get_versions::Function
    get_url::Function
end

#-----------------------------------------------------------------------------# @asset
macro asset(url)
    Base.remove_linenums!(esc(quote
        let
            dir = WebAssets.Scratch.get_scratch!($__module__, WebAssets.scratchdir)
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
            dir = WebAssets.Scratch.get_scratch!($pkg, WebAssets.scratchdir)
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
