# WebAssets

[![Build Status](https://github.com/joshday/WebAssets.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/joshday/WebAssets.jl/actions/workflows/CI.yml?query=branch%3Amain)


**WebAssets** provides a simple API for managing local versions of files based on URLs.

# Usage

```julia
using WebAssets: @add, @list, @remove

# Download file (if necessary) to scratchspace and return the path
plotlyjs = @add "https://cdn.plot.ly/plotly-2.24.0.min.js"


# List assets
@list()
# 1-element Vector{String}:
#  "/Users/<user>/.julia/scratchsp" ⋯ 64 bytes ⋯ "dn.plot.lySplotly-2.24.0.min.js"


# Delete the downloaded file
@remove "https://cdn.plot.ly/plotly-2.24.0.min.js"
```
