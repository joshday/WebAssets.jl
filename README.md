# WebAssets

[![Build Status](https://github.com/joshday/WebAssets.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/joshday/WebAssets.jl/actions/workflows/CI.yml?query=branch%3Amain)


**WebAssets** provides a simple API for managing local versions of files based on URLs.

## Usage

```julia
using WebAssets

# Download file (if necessary) to scratchspace and return the path
path = WebAssets.add("https://cdn.plot.ly/plotly-2.24.0.min.js")

# List asset URLs
WebAssets.list()
# 1-element Vector{String}:
#  "https://cdn.plot.ly/plotly-2.24.0.min.js"

# Get info about downloaded assets
WebAssets.info()
# 1-element Vector{WebAssets.Info}:
#  https://cdn.plot.ly/plotly-2.24.0.min.js 2026-01-27T14:55:07.216 3.420 MiB

# Force a re-download
WebAssets.add("https://cdn.plot.ly/plotly-2.24.0.min.js"; force=true)

# Delete the downloaded file
WebAssets.remove("https://cdn.plot.ly/plotly-2.24.0.min.js")
```

## Using a Package's Scratch Space

Other packages can use WebAssets to manage assets in their own scratchspace by passing their module as the first argument:

```julia
module MyPackage

using WebAssets

function __init__()
    # Downloads to MyPackage's scratch space
    WebAssets.add(@__MODULE__, "https://example.com/asset.js")
end

# List assets in MyPackage's scratch space
WebAssets.list(@__MODULE__)

# Get info for MyPackage's assets
WebAssets.info(@__MODULE__)

# Remove from MyPackage's scratch space
WebAssets.remove(@__MODULE__, "https://example.com/asset.js")

end
```
