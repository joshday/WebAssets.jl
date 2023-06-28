using Test
using Scratch
using ScratchspaceAssets
using Downloads: download

with_scratch_directory(mkpath(joinpath(tempdir(), "ScratchspaceAssetsTests"))) do
    clear_scratchspaces!()

    @test isempty(readdir(@get_scratch!(".")))

    plotly = @asset "https://cdn.plot.ly/plotly-2.24.0.min.js"
    plotly_latest = @asset () -> begin
        v = ScratchspaceAssets.github_latest_release("plotly", "plotly.js")
        "https://cdn.plot.ly/plotly-$v.min.js"
    end

    # Now they exist:
    @test isfile(plotly)
    @test isfile(plotly_latest)

    # Test that file isn't downloaded again
    @test @allocated(plotly2 = @asset "https://cdn.plot.ly/plotly-2.24.0.min.js") < 15_000

    # cleanup
    clear_scratchspaces!()
    @test !isfile(plotly)
    @test !isfile(plotly_latest)
end
