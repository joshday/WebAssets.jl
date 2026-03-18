module WebAssetsTests

using Test
using WebAssets
using Dates

# Dummy module for testing Module-based methods
module TestPkg end

const TEST_URL = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"

@testset "WebAssets" begin
    @testset "charmap has no duplicate values" begin
        values = last.(WebAssets.charmap)
        @test length(values) == length(unique(values))
    end

    @testset "dir" begin
        @test isdir(WebAssets.dir(Main))
        @test isdir(WebAssets.dir(TestPkg))
        # Unregistered modules (without package UUID) share the same scratch space
        @test WebAssets.dir(Main) == WebAssets.dir(TestPkg)
    end

    @testset "MODULE ref" begin
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
        WebAssets.MODULE[] = Main

        WebAssets.remove(TEST_URL)
        @test lowercase(TEST_URL) ∉ WebAssets.list()

        path = WebAssets.add(TEST_URL)
        @test isfile(path)
        @test lowercase(TEST_URL) ∈ WebAssets.list()

        # Cached: same path, no re-download
        path2 = WebAssets.add(TEST_URL)
        @test path == path2

        # force=true re-downloads
        mtime_before = mtime(path)
        sleep(0.1)
        path3 = WebAssets.add(TEST_URL; force=true)
        @test path == path3
        @test mtime(path3) > mtime_before

        WebAssets.remove(TEST_URL)
        @test !isfile(path)
        @test lowercase(TEST_URL) ∉ WebAssets.list()

        # Removing non-existent file does not error
        WebAssets.remove(TEST_URL)
    end

    @testset "@add macro" begin
        WebAssets.MODULE[] = Main

        WebAssets.remove(TEST_URL)

        path = WebAssets.@add TEST_URL
        @test isfile(path)
        @test startswith(path, WebAssets.dir(@__MODULE__))
        @test lowercase(TEST_URL) ∈ WebAssets.list()

        # force=true
        mtime_before = mtime(path)
        sleep(0.1)
        path2 = WebAssets.@add TEST_URL force=true
        @test path == path2
        @test mtime(path2) > mtime_before

        WebAssets.@remove TEST_URL
        @test !isfile(path)
    end

    @testset "@download macro" begin
        path = WebAssets.@download TEST_URL
        @test isfile(path)
        @test startswith(path, WebAssets.dir(@__MODULE__))

        # Cached: same path returned without re-download
        path2 = WebAssets.@download TEST_URL
        @test path == path2

        # Different URL → different cache key → different path
        other_url = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"
        path3 = WebAssets.@download other_url
        @test path3 != path

        # Different kwargs → different cache key
        key_plain  = string(hash(("Downloads.download", TEST_URL, (;))), base=16)
        key_with_kw = string(hash(("Downloads.download", TEST_URL, (; verbose=true))), base=16)
        @test key_plain != key_with_kw
        @test endswith(path, key_plain)

        # Specifying output is a compile-time error
        @test_throws Exception macroexpand(@__MODULE__,
            :(WebAssets.@download "https://example.com" output="/tmp/foo"))

        rm(path)
        rm(path3)
        @test !isfile(path)
        @test !isfile(path3)
    end

    @testset "list with domain and subdomain filters" begin
        WebAssets.MODULE[] = Main

        urls = [
            "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css",
            "https://unpkg.com/react@18/umd/react.production.min.js",
            "https://cdnjs.cloudflare.com/ajax/libs/lodash.js/4.17.21/lodash.min.js",
            "https://ga.jspm.io/npm:es-module-shims@1.5.1/dist/es-module-shims.js",
        ]

        for url in urls
            WebAssets.remove(url)
            WebAssets.add(url)
        end

        all_urls = WebAssets.list()
        for url in urls
            @test lowercase(url) ∈ all_urls
        end

        # domain filter
        jsdelivr_urls = WebAssets.list(domain="jsdelivr.net")
        @test any(u -> occursin("jsdelivr.net", u), jsdelivr_urls)
        @test !any(u -> occursin("unpkg.com", u), jsdelivr_urls)
        @test !any(u -> occursin("cloudflare.com", u), jsdelivr_urls)

        cloudflare_urls = WebAssets.list(domain="cloudflare.com")
        @test length(filter(u -> occursin("cloudflare.com", u), cloudflare_urls)) == 1
        @test !any(u -> occursin("jsdelivr.net", u), cloudflare_urls)

        # subdomain filter
        cdn_urls = WebAssets.list(subdomain="cdn")
        @test any(u -> occursin("cdn.jsdelivr.net", u), cdn_urls)
        @test !any(u -> occursin("unpkg.com", u), cdn_urls)
        @test !any(u -> occursin("cdnjs.cloudflare.com", u), cdn_urls)

        cdnjs_urls = WebAssets.list(subdomain="cdnjs")
        @test length(cdnjs_urls) >= 1
        @test all(u -> startswith(WebAssets.gethost(u), "cdnjs."), cdnjs_urls)

        ga_urls = WebAssets.list(subdomain="ga")
        @test length(ga_urls) >= 1
        @test all(u -> startswith(WebAssets.gethost(u), "ga."), ga_urls)

        # combined domain + subdomain filter
        cdnjs_cloudflare_urls = WebAssets.list(domain="cloudflare.com", subdomain="cdnjs")
        @test length(cdnjs_cloudflare_urls) == 1
        @test occursin("cdnjs.cloudflare.com", cdnjs_cloudflare_urls[1])

        for url in urls
            WebAssets.remove(url)
        end
    end

    @testset "@list macro" begin
        WebAssets.MODULE[] = Main
        WebAssets.add(TEST_URL)

        result = WebAssets.@list
        @test result isa Vector{String}
        @test lowercase(TEST_URL) ∈ result

        result_filtered = WebAssets.@list domain="jsdelivr.net"
        @test all(u -> occursin("jsdelivr.net", u), result_filtered)

        result_subdomain = WebAssets.@list subdomain="cdn"
        @test all(u -> startswith(WebAssets.gethost(u), "cdn."), result_subdomain)

        WebAssets.remove(TEST_URL)
    end

    @testset "gethost helper" begin
        @test WebAssets.gethost("https://example.com/path") == "example.com"
        @test WebAssets.gethost("https://cdn.example.com/path/file.js") == "cdn.example.com"
        @test WebAssets.gethost("http://api.example.com:8080/data") == "api.example.com"
        @test WebAssets.gethost("https://sub.domain.example.com/") == "sub.domain.example.com"
        @test WebAssets.gethost("ftp://files.example.com/file.txt") == "files.example.com"
        @test WebAssets.gethost("invalid-url") == ""
        @test WebAssets.gethost("example.com/path") == ""
    end

    @testset "info" begin
        WebAssets.MODULE[] = Main

        WebAssets.remove(TEST_URL)
        WebAssets.add(TEST_URL)

        infos = WebAssets.info()
        @test infos isa Vector{WebAssets.Info}
        @test !isempty(infos)

        test_info = filter(i -> i.url == lowercase(TEST_URL), infos)
        @test length(test_info) == 1

        i = test_info[1]
        @test i.url == lowercase(TEST_URL)
        @test i.downloaded isa DateTime
        @test i.size > 0

        # show method includes url
        io = IOBuffer()
        show(io, i)
        @test occursin(i.url, String(take!(io)))

        WebAssets.remove(TEST_URL)
    end

    @testset "@info macro" begin
        WebAssets.MODULE[] = Main
        WebAssets.add(TEST_URL)

        result = WebAssets.@info
        @test result isa Vector{WebAssets.Info}
        @test any(i -> i.url == lowercase(TEST_URL), result)

        WebAssets.remove(TEST_URL)
    end

    @testset "Module-based methods" begin
        WebAssets.remove(TestPkg, TEST_URL)
        @test lowercase(TEST_URL) ∉ WebAssets.list(TestPkg)

        path = WebAssets.add(TestPkg, TEST_URL)
        @test isfile(path)
        @test startswith(path, WebAssets.dir(TestPkg))
        @test lowercase(TEST_URL) ∈ WebAssets.list(TestPkg)

        infos = WebAssets.info(TestPkg)
        @test infos isa Vector{WebAssets.Info}
        @test any(i -> i.url == lowercase(TEST_URL), infos)

        mtime_before = mtime(path)
        sleep(0.1)
        path2 = WebAssets.add(TestPkg, TEST_URL; force=true)
        @test path == path2
        @test mtime(path2) > mtime_before

        WebAssets.remove(TestPkg, TEST_URL)
        @test !isfile(path)
        @test lowercase(TEST_URL) ∉ WebAssets.list(TestPkg)
    end
end

end # module
