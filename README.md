# WebAssets

[![Build Status](https://github.com/joshday/WebAssets.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/joshday/WebAssets.jl/actions/workflows/CI.yml?query=branch%3Amain)


**WebAssets** provides a simple API for managing local versions of files based on URLs.


# Usage


```julia
path = mkpath(joinpath(tempdir(), "my_assets"))

using WebAssets: dir!, add!, list, update!, remove!

# Change directory where local versions are saved.
# Default directory is the WebAssets.jl scratchspace (see Scratch.jl)
dir!(path)

# Download (if necessary) and return local file path.
add!("https://cdn.plot.ly/plotly-2.27.0.min.js")

# Get vector of `add!`-ed URLs
list()

# Re-download everything in list()
update!()

# Re-download a specific URL
update!("https://cdn.plot.ly/plotly-2.27.0.min.js")

# Remove the local file
remove!("https://cdn.plot.ly/plotly-2.27.0.min.js")
```
