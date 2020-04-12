import Dance
import HTTP
import JSON

include("./utils.jl")


Dance.start_project("demo")
routes("json")
project_settings_and_launch()


## Test all routes with pending slash, to ensure is removed ##
@testset "HTTP.listen" begin
    @async Dance.launch(true)

    r = HTTP.request("GET", "http://127.0.0.1:8000/dict/")
    @test r.status==200
    compare_http_header(r.headers, "content_type", "application/json")
    @test JSON.parse(extract_json_content(r.body))==Dict("a" => 123)

    r = HTTP.request("GET", "http://127.0.0.1:8000/dataframe/")
    @test r.status==200
    compare_http_header(r.headers, "content_type", "application/json")
    @test JSON.parse(extract_json_content(r.body))==[
        ["A", "B"],
        [1, "M"],
        [2, "F"],
        [3, "F"],
        [4, "M"]
    ]

    # Test int url param
    body_dict::Dict = Dict("b" => "abc")
    r = HTTP.request("POST", "http://127.0.0.1:8000/post/dict/12", [], JSON.json(body_dict))
    @test r.status==200
    compare_http_header(r.headers, "content_type", "application/json")
    @test JSON.parse(extract_json_content(r.body))==Dict("b" => 12)

    # Test setting Header value in backend
    body_df::Array = [
        ["A", "B"],
        [1, "M"],
        [2, "F"],
        [3, "G"],
        [4, "Z"]
    ]
    r = HTTP.request("POST", "http://127.0.0.1:8000/post/dataframe/", [], JSON.json(body_df))
    @test r.status==200
    compare_http_header(r.headers, "content_type", "application/json")
    compare_http_header(r.headers, "foo", "bar")
    @test JSON.parse(extract_json_content(r.body))==body_df
end


delete_project()
