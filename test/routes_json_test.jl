import Dance

include("./utils/main.jl")


Dance.start_project("demo")
project_settings()
routes("json")


## Test all routes with pending slash, to ensure is removed ##
@testset "HTTP.listen" begin
    @async include(joinpath(abspath(pwd()), "dance.jl"))
    sleep(1)

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
    # Test using OPTIONS method before POST (see https://github.com/axios/axios/issues/475)
    make_and_test_request_options("/post/dict/12")
    make_and_test_request_post("/post/dict/12", Dict("b" => "abc"), 200, Dict("Content-Type" => "application/json"), 8, true, Dict("b" => 12))

    # Test setting Header value in backend
    # Test accented character, for correct UTF-8 length
    make_and_test_request_post(
        "/post/dataframe/",
        [
            ["A", "B"],
            [1, "M"],
            [2, "F"],
            [3, "G"],
            [4, "ñ"]
        ],
        200,
        Dict("Content-Type" => "application/json", "foo" => "bar"),
        44,
        true,
        [
            ["A", "B"],
            [1, "M"],
            [2, "F"],
            [3, "G"],
            [4, "ñ"]
        ]
    )
end


delete_project()
