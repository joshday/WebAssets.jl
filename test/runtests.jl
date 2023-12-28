module WebAssetsTests

using Test
using Scratch
using WebAssets

delete_scratch!(WebAssetsTests, "WebAssets_jl")

@test isempty(@list())

url = "https://cdn.plot.ly/plotly-2.24.0.min.js"

a = @add url
b = @add url

@test a == b

@test isfile(a)

@test_logs (:info, "WebAssets - Downloading: $url") @update url

@test @list() == [url]

@remove url

@test !isfile(a)
@test isempty(@list())

@update()

end #module
