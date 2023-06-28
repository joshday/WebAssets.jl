module ScratchspaceAssets

using Scratch
using Downloads: download

export @asset
# Reexport Scratch.jl
export Scratch, with_scratch_directory, scratch_dir, get_scratch!, delete_scratch!, clear_scratchspaces!, @get_scratch!

#-----------------------------------------------------------------------------# __init__
const dir = Ref("")
const loaded_assets = String[]

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

#-----------------------------------------------------------------------------# @asset
macro asset(x)
    esc(quote
        let
            url = $x isa Base.Callable ? $x() : string($x)
            path = joinpath(Scratch.@get_scratch!("assets"), string(hash(url), '_', basename(url)))
            !isfile(path) && download(url, path)
            push!(ScratchspaceAssets.loaded_assets, path)
            path
        end
    end)
end


end
