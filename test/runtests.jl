module WebAssetsTests

using Test
using Scratch
using WebAssets

delete_scratch!(WebAssetsTests, "WebAssets_jl")

a = @add "https://cdn.plot.ly/plotly-2.24.0.min.js"

@test isfile(a)

@test length(@list()) == 1

@remove "https://cdn.plot.ly/plotly-2.24.0.min.js"

@test !isfile(a)
@test length(@list()) == 0

end #module
