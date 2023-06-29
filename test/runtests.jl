using Test
using Scratch
using ScratchspaceAssets
using Downloads: download

with_scratch_directory(mkpath(joinpath(tempdir(), "ScratchspaceAssetsTests"))) do
    clear_scratchspaces!()

    @test isempty(readdir(@get_scratch!(".")))

    plotly = @asset "https://cdn.plot.ly/plotly-2.24.0.min.js"

    get_plotly_latest = () -> ScratchspaceAssets.github_latest_release("plotly", "plotly.js")
    plotly_latest = @asset get_plotly_latest "https://cdn.plot.ly/plotly-VERSION.min.js"

    # Now they exist:
    @test isfile(plotly)
    @test isfile(plotly_latest)
    @test length(ScratchspaceAssets.available_assets) == 2

    # Test that file isn't downloaded again
    @test @allocated(plotly2 = @asset "https://cdn.plot.ly/plotly-2.24.0.min.js") < 15_000

    # cleanup
    clear_scratchspaces!()
    @test !isfile(plotly)
    @test !isfile(plotly_latest)
end
