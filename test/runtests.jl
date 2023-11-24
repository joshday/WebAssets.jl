module WebAssetsTests

using Test
using Scratch
using WebAssets

with_scratch_directory(mkpath(joinpath(tempdir(), "WebAssetsTests"))) do
    @testset "Tests" begin
        # verify that the scratchspace is empty
        clear_scratchspaces!()
        dir = get_scratch!(".")
        @test isempty(readdir(dir))

        # add asset and test that it exists in the scratchspace
        plotly = @asset "https://cdn.plot.ly/plotly-2.24.0.min.js"
        @test @allocated(@asset "https://cdn.plot.ly/plotly-2.24.0.min.js") < 15_000 # verify nothing is downloaded (allocations due to Scratch.jl)
        @test !isempty(readdir(dir))
        @test isfile(plotly)
        @test length(WebAssets.@list()) == 1

        # add same asset with url variable
        url = "https://cdn.plot.ly/plotly-2.24.0.min.js"
        plotly2 = @asset url
        @test plotly == plotly2
        @test isfile(plotly2)
        @test length(WebAssets.@list()) == 1

        # different asset with string interpolation
        v = "2.27.1"
        plotly3 = @asset "https://cdn.plot.ly/plotly-$v.min.js"
        @test isfile(plotly3)
        @test length(WebAssets.@list()) == 2

        # different asset with function
        get_url() = "https://cdn.plot.ly/plotly-2.27.0.min.js"
        plotly4 = @asset get_url()
        @test isfile(plotly4)
        @test length(WebAssets.@list()) == 3
    end
end

end #module
