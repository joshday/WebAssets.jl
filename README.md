# WebAssets

[![Build Status](https://github.com/joshday/WebAssets.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/joshday/WebAssets.jl/actions/workflows/CI.yml?query=branch%3Amain)


**WebAssets** provides a simple mechanism of downloading static files based on a url.


# Usage

## `@asset`

- The `@asset` macro returns the local file path of a downloaded url.

```julia
# .julia/scratchspaces/<UUID_of_calling_module>/__ASSETS__/
plotly = @asset "https://cdn.plot.ly/plotly-2.27.0.min.js"
```
- The file at the provided url will be downloaded to the directory `/.julia/scratchspaces/<UUID_of_calling_module>/__web_assets__`

## `@versioned_asset get_versions()::Vector{T} get_url(::T)`

## `@list <module>`

- Return a `Vector{String}` of the provided module's `@asset`s.
