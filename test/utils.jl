function compare_http_header(headers::Array, key::String, value::String) :: Nothing
    for item in headers
        if item[1]==key
            @test item[2]==value
        end
    end
end


function delete_project() :: Nothing
    cd("..")
    rm("demo", recursive=true)
    Dance.Router.delete_routes!()
    nothing
end


function extract_html_body_content(html_body::Array{UInt8,1}) :: String
    return split(
        split(String(html_body), "<div id=\"js-dance-json-data\">")[2],
        "</div>"
    )[1]
end


function extract_json_content(json_body::Array{UInt8,1}) :: String
    return String(json_body)
end


function project_settings_and_launch() :: Bool
    ## Add `dev.jl` file with 1 overwrite & 1 new entry ##
    cd("demo/settings")

    touch("dev.jl")
    open("dev.jl", "w") do io
        write(io, ":dev = true \n")
        write(io, ":foo = \"bar\"")
    end

    open("Global.jl", "a+") do io
        write(io, "include(\"dev.jl\")")
    end

    cd("..")

    Dance.pre_launch(joinpath(abspath(@__DIR__), "demo"))
end



function routes(file_suffix::String) :: Nothing
    cd("demo")
    open("routes.jl", "w") do io_routes
        open("../sample/routes_" * file_suffix * ".jl") do io_file
            write(io_routes, io_file)
        end
    end
    cd("..")
end
