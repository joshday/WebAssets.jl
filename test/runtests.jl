using Test
using ScratchspaceAssets: ScratchspaceAssets, @asset, clear_assets!, dir

@testset "clear_assets!" begin
    clear_assets!()
    @test isempty(readdir(dir[]))
end

#-----------------------------------------------------------------------------# Test Module
module Thing
    using ..ScratchspaceAssets
    using ..Test

    plotly = ""
    plotly_latest = ""

    function __init__()
        global plotly = @asset "https://cdn.plot.ly/plotly-2.24.0.min.js"
        global plotly_latest = @asset () -> begin
            v = ScratchspaceAssets.github_latest_release("plotly", "plotly.js")
            "https://cdn.plot.ly/plotly-$v.min.js"
        end
    end

    # These are populated in __init__, so these don't exist yet
    @test !isfile(plotly)
    @test !isfile(plotly_latest)
end #module

# Now they exits:
@test isfile(Thing.plotly)
@test isfile(Thing.plotly_latest)

# cleanup
@testset "clear_assets!" begin
    clear_assets!()
    @test !isfile(Thing.plotly)
    @test !isfile(Thing.plotly_latest)
end
