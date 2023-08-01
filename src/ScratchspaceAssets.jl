module ScratchspaceAssets

import Scratch
import Downloads: download

export @asset, @list

#-----------------------------------------------------------------------------# @asset
charmap = [':' => 'C', '/' => 'S', '?' => 'Q']

url2filename(url) = replace(lowercase(url), charmap...)

filename2url(file) = replace(file, reverse.(charmap)...)

macro asset(url)
    Base.remove_linenums!(esc(quote
        let
            dir = ScratchspaceAssets.Scratch.get_scratch!($__module__, "__ASSETS__")
            path = joinpath(dir, ScratchspaceAssets.url2filename($url))
            isfile(path) || ScratchspaceAssets.download($url, path)
            path
        end
    end))
end

macro list()
    esc(:(ScratchspaceAssets.@list($__module__)))
end

macro list(pkg)
    esc(quote
        let
            dir = ScratchspaceAssets.Scratch.get_scratch!($pkg, "__ASSETS__")
            ScratchspaceAssets.filename2url.(readdir(dir))
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
