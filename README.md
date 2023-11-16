# WebAssets

[![Build Status](https://github.com/joshday/WebAssets.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/joshday/WebAssets.jl/actions/workflows/CI.yml?query=branch%3Amain)


**WebAssets** provides a simple mechanism of downloading static files based on a url.


# Usage

- The `@asset` macro returns the local file path of a downloaded url (inside module's scratchspace).

```julia
# .julia/scratchspaces/<UUID_of_calling_module>/__ASSETS__/<stringified_url>
plotly = @asset "https://cdn.plot.ly/plotly-2.27.0.min.js"
```

```julia
@list MyModule  # Vector{String} of MyModule's asset URLs
```
