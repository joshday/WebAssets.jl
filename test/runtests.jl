using Test
using ScratchspaceAssets: ScratchspaceAssets, @asset, clear_assets!, dir

@testset "clear_assets!" begin
    clear_assets!()
    @test isempty(readdir(dir[]))
end

#-----------------------------------------------------------------------------# Test Module
module Thing
    using ..ScratchspaceAssets
    using Downloads: download


    function __init__()
        global plotly = @asset "https://cdn.plot.ly/plotly-2.24.0.min.js"
        global plotly_latest = @asset () -> begin
            v = ScratchspaceAssets.github_latest_release("plotly", "plotly.js")
            "https://cdn.plot.ly/plotly-$v.min.js"
        end
    end
end #module

#-----------------------------------------------------------------------------# @test
@test isfile(Thing.plotly)
@test isfile(Thing.plotly_latest)

@testset "clear_assets!" begin
    clear_assets!()
    @test !isfile(Thing.plotly)
    @test !isfile(Thing.plotly_latest)
end
