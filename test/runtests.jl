module WebAssetsTests

using Test
using Scratch
using WebAssets
using WebAssets: add!, remove!, list, update!, dir!, url2filename, filename2url

url = "https://cdn.plot.ly/plotly-2.24.0.min.js"

file = url2filename(url)
@test file == "httpsCSScdn.plot.lySplotly-2.24.0.min.js"
@test filename2url(file) == url


path = mkpath(joinpath(tempdir(), "WebAssets_jl_tests"))

dir!(path)

@test WebAssets.DIR[] == path
@test list() == []

add!(url)

@test list() == [url]

update!()
update!(url)

foreach(remove!, list())

end #module
