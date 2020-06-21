import Dance

include("./utils/main.jl")


Dance.start_project("demo")
project_settings()
routes("html")


## Test all routes with pending slash, to ensure is removed ##
@testset "HTTP.listen" begin
    @async include(joinpath(abspath(pwd()), "dance.jl"))
    sleep(1)

    make_and_test_request_get("/", 200, Dict("Content-Type" => "text/html; charset=UTF-8"), 217, false, "Hello World")

    # Test decimal url param
    make_and_test_request_get("/dict/12.3/", 200, Dict("Content-Type" => "text/html; charset=UTF-8"), 216, true, Dict("a" => 12.3))

    # Test int and string url params
    make_and_test_request_get("/dict/abc/123/", 200, Dict("Content-Type" => "text/html; charset=UTF-8"), 217, true, Dict("abc" => 123))

    make_and_test_request_get(
        "/dataframe/",
        200,
        Dict("Content-Type" => "text/html; charset=UTF-8"),
        249,
        true,
        [
            ["A", "B"],
            [1, "M"],
            [2, "F"],
            [3, "F"],
            [4, "M"]
        ]
    )
end


delete_project()
