module ScratchspaceAssetsTests

using Test
using Scratch
using ScratchspaceAssets
S = ScratchspaceAssets

with_scratch_directory(mkpath(joinpath(tempdir(), "ScratchspaceAssetsTests"))) do
    clear_scratchspaces!()

    # start with blank slate
    dir = get_scratch!(".")
    @test isempty(readdir(dir))

    # add asset and test that it exists in the scratchspace
    url = "https://cdn.plot.ly/plotly-2.24.0.min.js"
    plotly = @asset url
    @test !isempty(readdir(dir))
    @test isfile(plotly)
    @test length(S.@list()) == 1

    # Test that file isn't downloaded again
    @test @allocated(plotly2 = @asset url) < 15_000

    # cleanup
    clear_scratchspaces!()
    @test !isfile(plotly)
    @test length(S.@list()) == 0
end

end #module
