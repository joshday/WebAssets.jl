module ScratchspaceAssets

using Scratch: Scratch
using Downloads: download
using SHA: sha256

export @asset, Scratch

#-----------------------------------------------------------------------------# __init__
const dir = Ref("")
const available_assets = Set{String}()

function __init__()
    dir[] = Scratch.@get_scratch!(".")
end

#-----------------------------------------------------------------------------# utils
# Extract semantic version number (e.g. `1.2.3`) from a string.
extract_semver(x::AbstractString) = match(r"(\d+)\.(\d+)\.(\d+)", x).match

# e.g. github_latest_release("plotly", "plotly.js")
function github_latest_release(owner::AbstractString, repo::AbstractString)
    url = "https://api.github.com/repos/$owner/$repo/releases/latest"
    extract_semver(read(download(url), String))
end

#-----------------------------------------------------------------------------# @asset
macro asset(url)
    esc(quote
        let
            sha256 = ScratchspaceAssets.sha256
            url = $url
            path = joinpath(Scratch.@get_scratch!("assets"), string(bytes2hex(sha256(url)), '_', basename(url)))
            !isfile(path) && download(url, path)
            push!(ScratchspaceAssets.available_assets, path)
            path
        end
    end)
end

macro asset(get_latest_version, template)
    esc(
        quote
            let
                get_latest_version = $get_latest_version
                template = $template
                sha256 = ScratchspaceAssets.sha256
                dir = mkpath(joinpath(Scratch.@get_scratch!("assets"), bytes2hex(sha256(template))))
                try
                    v = get_latest_version()
                    url = replace(template, r"VERSION" => v)
                    path = joinpath(dir, string(bytes2hex(sha256(url)), '_', basename(url)))
                    !isfile(path) && download(url, path)
                    push!(ScratchspaceAssets.available_assets, path)
                    for file in filter(!=(basename(path)), readdir(dir))
                        @info "Replacing Asset: $file → $(basename(path))"
                        rm(joinpath(dir, file))
                    end
                    path
                catch
                    @warn "Error fetching latest version for template URL: $template."
                end
            end
        end
    )
end

end
