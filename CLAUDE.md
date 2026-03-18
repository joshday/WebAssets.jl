## Architecture

WebAssets is a single-file Julia package (`src/WebAssets.jl`) with no submodules. All functionality lives in one ~160-line file.

**Core concept:** URLs are cached as files in a [Scratch.jl](https://github.com/JuliaPackaging/Scratch.jl) scratchspace. The scratchspace is keyed by `Module` — by default `Main`, but any registered module can have its own isolated cache via `MODULE[]` or by passing the module explicitly.

**URL ↔ filename encoding:** URLs are mapped to filesystem-safe filenames via `charmap` (a `NamedTuple` of `Char => Char` replacements). The mapping is bijective so filenames can be decoded back to URLs. The `url2filename`/`filename2url` and `url2path`/`path2url` pairs handle this.

**Public API — each function has three call forms:**
1. `WebAssets.fn(url)` — uses `MODULE[]` (default `Main`)
2. `WebAssets.fn(m::Module, url)` — explicit module
3. `@WebAssets.fn url` — macro form that captures `@__MODULE__` at call site

**`add`/`@add`** forward all extra kwargs to `Downloads.download` (e.g. `timeout`, `headers`, `downloader`).

**`@download` macro** differs from `@add`: it hashes all positional args and kwargs to produce a cache key (not URL-derived), making it suitable for arbitrary `Downloads.download` calls beyond simple URL caching.

**`Info` struct** holds `path` (full local path), `downloaded` (from `mtime`), and `size`. `show` recovers the URL from the filename via `filename2url` if the basename contains `"://"` after decoding; otherwise displays the raw path (e.g. for `@download` hash-named files). `remove(::Info)` deletes `x.path` directly.
