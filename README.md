# WebAssets

[![Build Status](https://github.com/joshday/WebAssets.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/joshday/WebAssets.jl/actions/workflows/CI.yml?query=branch%3Amain)


**WebAssets** provides a simple API for managing local versions of files based on URLs.

If you squint it kinda looks like a lightweight, narrower-scope [DataDeps.jl](https://github.com/oxinabox/DataDeps.jl).

# Usage


```julia
proj = @project(
    plotlyjs = "https://cdn.plot.ly/plotly-2.24.0.min.js",
    katexcss = "https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css",
)

# Use assets:
proj.plotlyjs  # path to local file (file will be downloaded if necessary)

# Add more assets
proj.katexjs = "https://cdn.jsdelivr.net/npm/katex/dist/katex.min.js"

# Delete assets
proj.katexjs = nothing  # same as `delete!(proj, :katexjs)`

# Re-download assets
WebAssets.update!(proj, :plotlyjs)
WebAssets.update!()  # Re-download everything in project
```


# Details

- Files are saved in the calling module's scratchspace.
    - See [Scratch.jl](https://github.com/JuliaPackaging/Scratch.jl) for details.
- `Project(directory::String)` is the lower-level struct that determines where assets are stored locally.

```julia
@project(kw...)  # Same as Project(@get_scratch!("WebAssets_jl"), kw...)
```
