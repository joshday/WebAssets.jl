module ScratchspaceAssets

using Scratch: @get_scratch!
using Downloads: download
using SHA: sha256

export StaticAsset, VersionedAsset, @asset_str

#-----------------------------------------------------------------------------# __init__
dir = Ref{String}()

function __init__()
    dir[] = @get_scratch!("assets")
end

#-----------------------------------------------------------------------------# @asset_str
macro asset_str(ex)
    s = joinpath(dir[], string(ex))
    :($s)
end

#-----------------------------------------------------------------------------# StaticAsset
struct Asset
    name::String
    get_url::Union{String, Function}
    get_latest_version::Union{Nothing, Function}
    sha256::String
end

const assets = Dict{String, Asset}()

function register!(; name::String, url, version=nothing)
    global assets
    file = url isa String ? download(url) :
        version isa String ? download(url(version)) : download(url(version()))
    sha = open(io -> sha256(io), file, "r")
    haskey(assets, sha) && error("Asset is already registered as \"$(assets[sha].name)\".")
    any(x -> x.name == name, values(assets)) && error("Asset with name \"$name\" has already been registered.")
    path = asset_str(name)
    mv(file, path)
    assets[sha] = StaticAsset(name, url, sha)
    path
end

end
