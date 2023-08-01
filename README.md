# ScratchspaceAssets

[![Build Status](https://github.com/joshday/ScratchspaceAssets.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/joshday/ScratchspaceAssets.jl/actions/workflows/CI.yml?query=branch%3Amain)


**ScratchspaceAssets** provides a simple mechanism of downloading static files based on a url.


# Usage

- The `@asset` macro uses functionality provided by [Scratch.jl](https://github.com/JuliaPackaging/Scratch.jl) to download the provided url (if it hasn't already been downloaded):
- The file at the provided url will be placed in the scratchspace of the calling module, e.g. `~/.julia/scratchspaces/<UUID_of_calling_module>/__ASSETS__/<file>`

```julia
@asset url
```

- The `@list` macro lets you view which urls have already been downloaded:

```julia
@list

@list SomeModule
```

# Examples

```julia
using ScratchspaceAssets

plotly = @asset "https://cdn.plot.ly/plotly-2.24.0.min.js"

# get latest version of Plotly

using JSON3, HTTP

function plotly_latest()
    res = HTTP.get("https://api.github.com/repos/plotly/plotly.js/releases/latest")
    latest = VersionNumber(JSON3.read(res.body).name)
    @asset "https://cdn.plot.ly/plotly-$latest.min.js"
end
```
