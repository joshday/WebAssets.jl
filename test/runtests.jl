module WebAssetsTests

using Test
using WebAssets
using Dates

# Dummy module for testing Module-based methods
module TestPkg end

@testset "WebAssets" begin
    @testset "charmap has no duplicate values" begin
        values = last.(WebAssets.charmap)
        @test length(values) == length(unique(values))
    end

    @testset "dir" begin
        # dir with explicit module
        @test isdir(WebAssets.dir(Main))
        @test isdir(WebAssets.dir(TestPkg))
        # Unregistered modules (without package UUID) share the same scratch space
        @test WebAssets.dir(Main) == WebAssets.dir(TestPkg)
    end

    @testset "MODULE ref" begin
        # Set the default module
        WebAssets.MODULE[] = Main
        @test WebAssets.MODULE[] === Main
        @test WebAssets.dir() == WebAssets.dir(Main)
    end

    @testset "url2filename / filename2url round-trip" begin
        urls = [
            "https://example.com",
            "https://example.com/path/to/file.js",
            "https://example.com/style.css?v=123",
            "https://example.com/page#section",
            "https://example.com/search?q=test&page=1",
            "https://cdn.example.com/lib/v1.0.0/bundle.min.js",
            "https://example.com/path%20with%20spaces",
        ]
        for url in urls
            filename = WebAssets.url2filename(url)
            recovered = WebAssets.filename2url(filename)
            @test recovered == lowercase(url)
        end
    end

    @testset "url2filename removes filesystem-unsafe characters" begin
        url = "https://example.com/file?query=1#section"
        filename = WebAssets.url2filename(url)
        unsafe_chars = [':', '/', '?', '#', '<', '>', '*', '|', '"', '\\']
        for char in unsafe_chars
            @test !occursin(char, filename)
        end
    end

    @testset "url2path / path2url round-trip" begin
        # Ensure MODULE is set for dir() to work
        WebAssets.MODULE[] = Main

        url = "https://example.com/style.css"

        # Default directory
        path = WebAssets.url2path(url)
        recovered = WebAssets.path2url(path)
        @test recovered == lowercase(url)
        @test startswith(path, WebAssets.dir())

        # Custom directory
        custom_dir = mktempdir()
        custom_path = WebAssets.url2path(url, custom_dir)
        @test startswith(custom_path, custom_dir)
        @test WebAssets.path2url(custom_path) == lowercase(url)
    end

    @testset "add, list, remove" begin
        # Ensure MODULE is set for functions without explicit module
        WebAssets.MODULE[] = Main

        test_url = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"

        # Clean up if exists from previous test
        WebAssets.remove(test_url)
        @test lowercase(test_url) ∉ WebAssets.list()

        # Add
        path = WebAssets.add(test_url)
        @test isfile(path)
        @test lowercase(test_url) ∈ WebAssets.list()

        # Add again (should not re-download, same path returned)
        path2 = WebAssets.add(test_url)
        @test path == path2

        # Add with force=true (should re-download)
        mtime_before = mtime(path)
        sleep(0.1)  # Ensure time difference
        path3 = WebAssets.add(test_url; force=true)
        @test path == path3
        @test mtime(path3) > mtime_before

        # Remove
        WebAssets.remove(test_url)
        @test !isfile(path)
        @test lowercase(test_url) ∉ WebAssets.list()

        # Remove non-existent file (should not error)
        WebAssets.remove(test_url)
    end

    @testset "info" begin
        # Ensure MODULE is set
        WebAssets.MODULE[] = Main

        test_url = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"

        # Clean up and add
        WebAssets.remove(test_url)
        WebAssets.add(test_url)

        # Test info()
        infos = WebAssets.info()
        @test infos isa Vector{WebAssets.Info}
        @test !isempty(infos)

        # Find our test file in the info list
        test_info = filter(i -> i.url == lowercase(test_url), infos)
        @test length(test_info) == 1

        info = test_info[1]
        @test info.url == lowercase(test_url)
        @test info.downloaded isa DateTime
        @test info.size > 0

        # Test show method
        io = IOBuffer()
        show(io, info)
        output = String(take!(io))
        @test occursin(info.url, output)

        # Clean up
        WebAssets.remove(test_url)
    end

    @testset "Module-based methods" begin
        test_url = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"

        # Clean up
        WebAssets.remove(TestPkg, test_url)
        @test lowercase(test_url) ∉ WebAssets.list(TestPkg)

        # Add using Module argument
        path = WebAssets.add(TestPkg, test_url)
        @test isfile(path)
        @test startswith(path, WebAssets.dir(TestPkg))
        @test lowercase(test_url) ∈ WebAssets.list(TestPkg)

        # Test info with Module
        infos = WebAssets.info(TestPkg)
        @test infos isa Vector{WebAssets.Info}
        @test any(i -> i.url == lowercase(test_url), infos)

        # Add with force=true
        mtime_before = mtime(path)
        sleep(0.1)
        path2 = WebAssets.add(TestPkg, test_url; force=true)
        @test path == path2
        @test mtime(path2) > mtime_before

        # Remove using Module argument
        WebAssets.remove(TestPkg, test_url)
        @test !isfile(path)
        @test lowercase(test_url) ∉ WebAssets.list(TestPkg)
    end
end

end # module
