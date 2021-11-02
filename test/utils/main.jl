import HTTP
import JSON

include("./request.jl")


function delete_project(server::Bool=true) :: Nothing
    cd("..")
    rm("demo", recursive=true)

    if server
        Dance.CoreEngine.close_server()
    end

    Dance.Router.delete_routes!()
    nothing
end


function dirs_add_multiple() :: Nothing
    mkdir("code")
    mkdir("node_modules")  # test ignores node dir

    cd("code")  # test dir with file & sub-dir
    touch("file1.jl")
    mkdir("sub-dir1")  # test dir with only sub-dir
    cd("sub-dir1")
    mkdir("sub-dir2")  # test dir with file
    cd("sub-dir2")
    touch("file2.jl")

    cd("../../..")
    nothing
end


function dirs_add_single() :: Nothing
    mkdir("code")
    mkdir("node_modules")  # test ignores node dir

    cd("code")  # test dir with file & sub-dir
    touch("file1.jl")

    cd("..")
    nothing
end


function make_and_test_request_get(path::String, status::Int64, headers::Dict{String, String}, content_length::Int64, is_json_body::Bool, body::Any) :: Nothing
    r = HTTP.request("GET", "http://127.0.0.1:8000$path")
    parse_and_test_request(r, status, headers, content_length, is_json_body, body)
end


function make_and_test_request_options(path::String) :: Nothing
    r = HTTP.request("OPTIONS", "http://127.0.0.1:8000$path")
    compare_http_header(r.headers, "Allow", "POST")
    compare_http_header(r.headers, "Access-Control-Allow-Methods", "POST")
    compare_http_header(r.headers, "Access-Control-Allow-Headers", "X-PINGOTHER, Content-Type")
end


function make_and_test_request_post(path::String, payload::Union{Array, Dict}, status::Int64, headers::Dict{String, String}, content_length::Int64, is_json_body::Bool, body::Any) :: Nothing
    r = HTTP.request("POST", "http://127.0.0.1:8000$path", [], JSON.json(payload))
    parse_and_test_request(r, status, headers, content_length, is_json_body, body)
end


function project_settings() :: Nothing
    ## Add `dev.jl` file with 1 overwrite & 1 new entry ##
    cd("demo/settings")

    touch("dev.jl")
    open("dev.jl", "w") do io
        write(io, ":dev = true\n")
        write(io, ":foo = \"bar\"")
    end

    open("Global.jl", "a+") do io
        write(io, "include(\"dev.jl\")")
    end

    cd("..")
end


function routes(file_suffix::String) :: Nothing
    open("routes.jl", "w") do io_routes
        open("../sample/routes/" * file_suffix * ".jl") do io_file
            write(io_routes, io_file)
        end
    end

    nothing
end
