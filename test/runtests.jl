module WebAssetsTests

using Test
using Scratch
using WebAssets
using WebAssets: add!, remove!, list, update!, dir!, url2filename, filename2url

url = "HTTPS://cdn.plot.ly/plotly-2.24.0.min.js"

file = url2filename(url)
@test file == "httpsCSScdn.plot.lySplotly-2.24.0.min.js"
@test filename2url(file) == lowercase(url)


path = mkpath(joinpath(tempdir(), "WebAssets_jl_tests"))

dir!(path)
foreach(remove!, list())

@test WebAssets.DIR[] == path
@test list() == []

add!(url)

@test list() == [lowercase(url)]

update!()
update!(url)

foreach(remove!, list())

end #module
