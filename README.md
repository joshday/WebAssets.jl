# WebAssets

[![Build Status](https://github.com/joshday/WebAssets.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/joshday/WebAssets.jl/actions/workflows/CI.yml?query=branch%3Amain)


**WebAssets** provides a simple API for managing local versions of files based on URLs.  Files are cached in your scratchspace for future use.

## Usage

```julia
using WebAssets

# Download file (if necessary) to scratchspace and return the path
path = WebAssets.add("https://cdn.plot.ly/plotly-2.24.0.min.js")

# Keyword arguments are forwarded to Downloads.download
path = WebAssets.add("https://cdn.plot.ly/plotly-2.24.0.min.js"; timeout=30.0)

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

# Delete the downloaded file by URL or by Info
WebAssets.remove("https://cdn.plot.ly/plotly-2.24.0.min.js")
WebAssets.remove(WebAssets.info()[1])

# Filter list by domain or subdomain
WebAssets.list(domain="plot.ly")
WebAssets.list(subdomain="cdn")
```

## Macros

Each macro is equivalent to its function counterpart but automatically uses `@__MODULE__`'s scratchspace instead of `Main`.

```julia
# @add — download and cache a URL (kwargs forwarded to Downloads.download)
path = WebAssets.@add "https://cdn.plot.ly/plotly-2.24.0.min.js"
path = WebAssets.@add "https://cdn.plot.ly/plotly-2.24.0.min.js" force=true
path = WebAssets.@add "https://cdn.plot.ly/plotly-2.24.0.min.js" timeout=30.0

# @remove — delete a cached file
WebAssets.@remove "https://cdn.plot.ly/plotly-2.24.0.min.js"

# @list — list cached asset URLs
WebAssets.@list
WebAssets.@list domain="plot.ly"
WebAssets.@list subdomain="cdn"

# @info — get metadata for cached assets
WebAssets.@info
```

### `@download`

`@download` wraps `Downloads.download` directly, caching by a hash of all arguments rather than the URL string. Use this when you need to pass extra options to `Downloads.download`.

```julia
path = WebAssets.@download "https://example.com/data.json"

# Different kwargs produce a separate cache entry
path2 = WebAssets.@download "https://example.com/data.json" verbose=true

# Specifying `output` is an error — it is managed by WebAssets
WebAssets.@download "https://example.com/data.json" output="/tmp/foo"  # ERROR
```

## Using a Different Package's Scratchspace

- Methods that accept a `Module` argument are available for managing assets within a specific scratchspace (default is `Main`).
- Alternatively, set the `WebAssets.MODULE` Ref, e.g. `WebAssets.MODULE[] = @__MODULE__`.

```julia
WebAssets.add(@__MODULE__, "https://example.com/asset.js")

WebAssets.list(@__MODULE__)

WebAssets.info(@__MODULE__)

WebAssets.remove(@__MODULE__, "https://example.com/asset.js")
```
