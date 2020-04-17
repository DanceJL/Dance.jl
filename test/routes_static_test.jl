import Dance
import HTTP

include("./utils.jl")


Dance.start_project("demo")
routes("static")

# Create file for static file route
mkdir("demo/files")
cp("sample/static/shipping_containers.jpg", "demo/files/image.jpg")

project_settings_and_launch()


@testset "HTTP.listen" begin
    @async Dance.launch(true)

    # Favicon
    r = HTTP.request("GET", "http://localhost:8000/favicon.ico")
    @test r.status==200
    compare_http_header(r.headers, "content_type", "image/x-icon")
    @test r.body==read("../../files/html/favicon.ico")

    # Single static file
    r = HTTP.request("GET", "http://localhost:8000/files/image.jpg")
    @test r.status==200
    compare_http_header(r.headers, "content_type", "image/jpeg")
    @test r.body==read("files/image.jpg")

    # Static dir
    for path in [
        "shipping_containers.jpg",
        "office/coffee_and_laptop.jpg",
        "outdoors/scenary/hills_in_mist.jpg",
        "outdoors/wildlife/goat_and_sheep.jpg"
    ]
        r = HTTP.request("GET", "http://localhost:8000/static/$path")
        @test r.status==200
        compare_http_header(r.headers, "content_type", "image/jpeg")
        @test r.body==read(joinpath("../sample/static", path))
    end
end


delete_project()
