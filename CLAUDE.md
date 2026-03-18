# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

Run tests:
```julia
# From Julia REPL with project activated
using Pkg; Pkg.test()

# Or run directly
julia --project=. test/runtests.jl
```

Run a single testset (by name):
```julia
using Test, WebAssets
include("test/runtests.jl")
```

## Architecture

WebAssets is a single-file Julia package (`src/WebAssets.jl`) with no submodules. All functionality lives in one ~160-line file.

**Core concept:** URLs are cached as files in a [Scratch.jl](https://github.com/JuliaPackaging/Scratch.jl) scratchspace. The scratchspace is keyed by `Module` — by default `Main`, but any registered module can have its own isolated cache via `MODULE[]` or by passing the module explicitly.

**URL ↔ filename encoding:** URLs are mapped to filesystem-safe filenames via `charmap` (a `NamedTuple` of `Char => Char` replacements). The mapping is bijective so filenames can be decoded back to URLs. The `url2filename`/`filename2url` and `url2path`/`path2url` pairs handle this.

**Public API — each function has three call forms:**
1. `WebAssets.fn(url)` — uses `MODULE[]` (default `Main`)
2. `WebAssets.fn(m::Module, url)` — explicit module
3. `@WebAssets.fn url` — macro form that captures `@__MODULE__` at call site

**`@download` macro** differs from `@add`: it hashes all positional args and kwargs to produce a cache key (not URL-derived), making it suitable for arbitrary `Downloads.download` calls beyond simple URL caching.

**`Info` struct** holds `url`, `downloaded` (from `mtime`), and `size` for display via `StyledStrings`.
