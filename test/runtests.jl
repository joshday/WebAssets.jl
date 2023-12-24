module WebAssetsTests

using Test
using Scratch
using WebAssets

delete_scratch!(WebAssetsTests, "WebAssets_jl")
delete_scratch!(WebAssetsTests, "WebAssets_jl2")

let
    v = "2.24.0"
    @test @project(plotly = "https://cdn.plot.ly/plotly-$v.min.js") isa Project
end

a = @project(
    plotlyjs = "https://cdn.plot.ly/plotly-2.24.0.min.js",
    katexcss = "https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css",
    katexjs = "https://cdn.jsdelivr.net/npm/katex/dist/katex.min.js"
)

b = Project(@get_scratch!("web_assets_jl2"))
b.plotlyjs = "https://cdn.plot.ly/plotly-2.24.0.min.js"
b.katexcss = "https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css"
b.katexjs = "https://cdn.jsdelivr.net/npm/katex/dist/katex.min.js"

@test WebAssets.registry(a) != WebAssets.registry(b)
@test a == b

@test WebAssets.dir(a) == @get_scratch!("WebAssets_jl")
@test length(WebAssets.registry(a)) == 3

plotly_url = WebAssets.url(a, :plotlyjs)
@test plotly_url == "https://cdn.plot.ly/plotly-2.24.0.min.js"

a.plotlyjs = nothing
@test length(WebAssets.registry(a)) == 2
@test_throws Exception a.plotlyjs

delete!(b, :plotlyjs)

@test a == b

# Test info statements printed during update!
@test_logs (:info,) WebAssets.update!(a, :katexjs)
@test_logs (:info,) (:info,) WebAssets.update!(a)

# Asset only downloads on first setindex!
@test_logs (:info,) a.plotlyjs = "https://cdn.plot.ly/plotly-2.24.0.min.js"
@test_logs a.plotlyjs = "https://cdn.plot.ly/plotly-2.24.0.min.js"

end #module
