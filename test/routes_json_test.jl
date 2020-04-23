import Dance

include("./utils/main.jl")


Dance.start_project("demo")
routes("json")
project_settings_and_launch()


## Test all routes with pending slash, to ensure is removed ##
@testset "HTTP.listen" begin
    @async Dance.launch(true)

    make_and_test_request_get("/dict/", 200, Dict("Content-Type" => "application/json"), 9, true, Dict("a" => 123))

    make_and_test_request_get(
        "/dataframe/",
        200,
        Dict("Content-Type" => "application/json"),
        43,
        true,
        [
            ["A", "B"],
            [1, "M"],
            [2, "F"],
            [3, "F"],
            [4, "M"]
        ]
    )

    # Test int url param
    make_and_test_request_post("/post/dict/12", Dict("b" => "abc"), 200, Dict("Content-Type" => "application/json"), 8, true, Dict("b" => 12))

    # Test setting Header value in backend
    make_and_test_request_post(
        "/post/dataframe/",
        [
            ["A", "B"],
            [1, "M"],
            [2, "F"],
            [3, "G"],
            [4, "Z"]
        ],
        200,
        Dict("Content-Type" => "application/json", "foo" => "bar"),
        43,
        true,
        [
            ["A", "B"],
            [1, "M"],
            [2, "F"],
            [3, "G"],
            [4, "Z"]
        ]
    )
end


delete_project()
