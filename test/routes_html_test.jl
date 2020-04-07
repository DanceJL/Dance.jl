import Dance
import HTTP
import JSON

include("./utils.jl")


Dance.start_project("demo")
routes_html("html")
project_settings_and_launch()


## Test all routes with pending slash, to sensure is removed ##
@testset "HTTP.listen" begin
    @async Dance.launch(true)

    r = HTTP.request("GET", "http://127.0.0.1:8000/")
    @test r.status==200
    compare_http_header(r.headers, "content_type", "text/html; charset=UTF-8")
    @test extract_html_body_content(r.body)=="Hello World"

    r = HTTP.request("GET", "http://127.0.0.1:8000/dict/")
    @test r.status==200
    compare_http_header(r.headers, "content_type", "text/html; charset=UTF-8")
    @test JSON.parse(extract_html_body_content(r.body))==Dict("a" => 123)

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
