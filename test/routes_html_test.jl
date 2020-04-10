import Dance
import HTTP
import JSON

include("./utils.jl")


Dance.start_project("demo")
routes_html("html")
project_settings_and_launch()


## Test all routes with pending slash, to ensure is removed ##
@testset "HTTP.listen" begin
    @async Dance.launch(true)

    r = HTTP.request("GET", "http://127.0.0.1:8000/")
    @test r.status==200
    compare_http_header(r.headers, "content_type", "text/html; charset=UTF-8")
    @test extract_html_body_content(r.body)=="Hello World"

    # Test decimal url param
    r = HTTP.request("GET", "http://127.0.0.1:8000/dict/12.3")
    @test r.status==200
    compare_http_header(r.headers, "content_type", "text/html; charset=UTF-8")
    @test JSON.parse(extract_html_body_content(r.body))==Dict("a" => 12.3)

    # Test int and string url params
    r = HTTP.request("GET", "http://127.0.0.1:8000/dict/abc/123")
    @test r.status==200
    compare_http_header(r.headers, "content_type", "text/html; charset=UTF-8")
    @test JSON.parse(extract_html_body_content(r.body))==Dict("abc" => 123)

    r = HTTP.request("GET", "http://127.0.0.1:8000/dataframe/")
    @test r.status==200
    compare_http_header(r.headers, "content_type", "text/html; charset=UTF-8")
    @test JSON.parse(extract_html_body_content(r.body))==[
        ["A", "B"],
        [1, "M"],
        [2, "F"],
        [3, "F"],
        [4, "M"]
    ]
end


delete_project()
