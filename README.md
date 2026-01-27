# WebAssets

[![Build Status](https://github.com/joshday/WebAssets.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/joshday/WebAssets.jl/actions/workflows/CI.yml?query=branch%3Amain)


**WebAssets** provides a simple API for managing local versions of files based on URLs.  Files are cached in your scratchspace for future use.

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

## Using a Different Package's Scratchspace

- Methods that accept a `Module` argument are available for managing assets within a specific scratchspace (default is `Main`).
- Alternativly, set the `WebAssets.MODULE` Ref, e.g. `WebAssets.MODULE[] = @__MODULE__`.

```julia
WebAssets.add(@__MODULE__, "https://example.com/asset.js")

WebAssets.list(@__MODULE__)

WebAssets.info(@__MODULE__)

WebAssets.remove(@__MODULE__, "https://example.com/asset.js")
```
