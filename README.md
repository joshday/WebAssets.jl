# ScratchspaceAssets

[![Build Status](https://github.com/joshday/ScratchspaceAssets.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/joshday/ScratchspaceAssets.jl/actions/workflows/CI.yml?query=branch%3Amain)


This package relies on [Scratch.jl](https://github.com/JuliaPackaging/Scratch.jl) to manage single-file artifact-like things.


# Usage

The only export is the `@asset` macro, which downloads the file at the provided URL (if not already downloaded)
and places it in the calling module's scratchspace.

Assets are stored on disk as:
```
.julia/scratchspaces/<calling_module_UUID>/assets/<string(hash(url))>_<basename(url)>
```

```julia
using ScratchspaceAssets
# Static URL
plotly = @asset "https://cdn.plot.ly/plotly-2.24.0.min.js"

# You can also provide a function that returns the URL.
# This is useful if you always want to pull the latest version of an asset.
# There is currently no mechanism for cleaning up outdated assets (other than what is already in Scratch.jl)
plotly_latest = @asset () -> begin
    v = ScratchspaceAssets.github_latest_release("plotly", "plotly.js")
    "https://cdn.plot.ly/plotly-$v.min.js"
end
```

- `ScratchspaceAssets.available_assets` is a `Set{String}` with all the file paths found via `@asset` in the current Julia session:

```
Set{String} with 2 elements:
  "/Users/<user>/.julia/scratchspaces/<UUID>/assets/15877489554269599553_plotly-2.24.2.min.js"  # plotly_latest
  "/Users/<user>/.julia/scratchspaces/<UUID>/assets/6869591778587603294_plotly-2.24.0.min.js"   # plotly
```
