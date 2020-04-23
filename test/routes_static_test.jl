import Dance

include("./utils/main.jl")


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


## Test all routes with pending slash, to ensure is removed ##
@testset "HTTP.listen" begin
    @async Dance.launch(true)

    # Favicon
    make_and_test_request_get("/favicon.ico/", 200, Dict("Content-Type" => "image/x-icon"), 15406, false, read("../../files/html/favicon.ico"))

    # Single static file
    make_and_test_request_get("/files/image.jpg/", 200, Dict("Content-Type" => "image/jpeg"), 84668, false, read("files/image.jpg"))

    # Static dir
    for item in [
        ["shipping_containers.jpg", 84668],
        ["office/coffee_and_laptop.jpg", 2126200],
        ["outdoors/scenary/hills_in_mist.jpg", 3181705],
        ["outdoors/wildlife/goat_and_sheep.jpg", 3175701]
    ]
        path::String = item[1]
        content_length::Int64 = item[2]
        make_and_test_request_get("/static/$path/", 200, Dict("Content-Type" => "image/jpeg"), content_length, false, read(joinpath("../sample/static", path)))
    end
end


delete_project()
