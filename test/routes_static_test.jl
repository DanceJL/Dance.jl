import Dance
import HTTP

include("./utils.jl")


Dance.start_project("demo")
routes("static")

# Create file for static file route
mkdir("demo/files")
cp("sample/static/shipping_containers.jpg", "demo/files/image.jpg")


# Ensure route paths cannot go higher than project route in directory structure
@test_logs (:error, "Route paths cannot go higher than project route in directory structure") project_settings_and_launch()
lines_array = []
open("routes.jl", "r") do io
    global lines_array = readlines(io)
    for (idx, line) in enumerate(lines_array)
        if line=="route(\"/../files/image.jpg\", output_file_as_string; method=GET, endpoint=STATIC)"
            global lines_array
            deleteat!(lines_array, idx)
        end
    end
end
lines_string = ""
for line in lines_array
    global lines_string
    lines_string = lines_string * line * "\n"
end
open("routes.jl", "w") do io
    write(io, lines_string)
end
Dance.Router.delete_routes!()
Dance.pre_launch(joinpath(abspath(@__DIR__), "demo"))


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
