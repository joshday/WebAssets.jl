module WebAssetsTests

using Test
using Scratch
using WebAssets

with_scratch_directory(mkpath(joinpath(tempdir(), "WebAssetsTests"))) do
    clear_scratchspaces!()

    # start with blank slate
    dir = get_scratch!(".")
    @test isempty(readdir(dir))

    # add asset and test that it exists in the scratchspace
    url = "https://cdn.plot.ly/plotly-2.24.0.min.js"
    plotly = @asset url
    @test !isempty(readdir(dir))
    @test isfile(plotly)
    @test length(WebAssets.@list()) == 1

    # Test that file isn't downloaded again
    @test @allocated(plotly2 = @asset url) < 15_000

    clear_scratchspaces!()
    # test that string interpolation works
    v = "2.24.0"
    url = "https://cdn.plot.ly/plotly-$v.min.js"
    plotly = @asset url
    @test !isempty(readdir(dir))
    @test isfile(plotly)
    @test length(WebAssets.@list()) == 1

    @test @allocated(plotly2 = @asset url) < 15_000

    # cleanup
    clear_scratchspaces!()
    @test !isfile(plotly)
    @test length(WebAssets.@list()) == 0
end

end #module
