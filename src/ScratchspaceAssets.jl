module ScratchspaceAssets

using Scratch: @get_scratch!
using Downloads: download
using SHA: sha256

export @asset

#-----------------------------------------------------------------------------# __init__
const dir = Ref{String}("")

function __init__()
    dir[] = @get_scratch!(".")
end

#-----------------------------------------------------------------------------# utils
# Extract semantic version number (e.g. `1.2.3`) from a string.
# TODO include build metadata after `+`
extract_semver(x::AbstractString) = match(r"(\d+)\.(\d+)\.(\d+)", x).match

# e.g. github_latest_release("plotly", "plotly.js")
function github_latest_release(owner::AbstractString, repo::AbstractString)
    url = "https://api.github.com/repos/$owner/$repo/releases/latest"
    extract_semver(read(download(url), String))
end

#-----------------------------------------------------------------------------# asset!
function asset!(url::String; force=false)
    path = joinpath(dir[], string(hash(url), '_', basename(url)))
    isfile(path) && !force || download(url, path)
    return path
end
asset!(f::Function; force=false) = asset!(f(); force)

clear_assets!(urls::String...) = map(urls) do x
    rm(path = joinpath(dir[], string(hash(x), '_', basename(x))), force=true)
end
clear_assets!() = foreach(x -> rm(joinpath(dir[], x); force=true), readdir(dir[]))

#-----------------------------------------------------------------------------# list_assets
function assets(pattern = r""; ignore=[".DS_Store"])
    filter(x -> occursin(pattern, x) && x ∉ ignore, readdir(dir[]))
end

#-----------------------------------------------------------------------------# @asset
macro asset(x)
    esc(:(ScratchspaceAssets.asset!($x)))
end

end
