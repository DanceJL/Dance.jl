import HTTP
import JSON

include("./request.jl")


function delete_project() :: Nothing
    cd("..")
    rm("demo", recursive=true)
    Dance.Router.delete_routes!()
    nothing
end


function make_and_test_request_get(path::String, status::Int64, headers::Dict{String, String}, content_length::Int64, is_json_body::Bool, body::Any) :: Nothing
    r = HTTP.request("GET", "http://127.0.0.1:8000$path")
    parse_and_test_request(r, status, headers, content_length, is_json_body, body)
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
