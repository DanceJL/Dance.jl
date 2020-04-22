module CoreEngine

import DataFrames
import JSON

import Dance.Configuration
import Dance.CoreRenderer
import Dance.Logger
import Dance.Router
import Dance.PayloadUtils
import Dance.URIUtils


const OUTPUT_DATA_FORMATS = Union{DataFrames.DataFrame, Dict, String}
const ROUTE_PARAMS_FORMATS = Union{Float64, Int64, String}


#=Chosen Engine must have following functions:
    - respond()
    - start_server()
=#

#= TODO: Include dynamically
Configuration.Settings[:engine] == "HTTP" =#
include("HTTPEngine.jl")


"""
    build_route_params_dict(;request_route_segments::Array{String, 1}, route_path::String)

Build dict of route params and corresponding values, by:
- Parsing route.path for only segment sections
- Looking-up request route segments at corresponding index
"""
function build_route_params_dict(;request_route_segments::Array{String, 1}, route_path::String) :: Dict
    route_params_dict::Dict{Symbol, ROUTE_PARAMS_FORMATS} = Dict()

    for (idx, item) in enumerate(collect(eachmatch(URIUtils.ROUTE_REGEX_PARAM_ONLY, route_path)))
        index::String = lstrip(split(item.match, ">")[1], '<')
        value::ROUTE_PARAMS_FORMATS = request_route_segments[idx]
        if tryparse(Float64, value) isa Number
            if tryparse(Int64, value) !== nothing
                value = parse(Int64, value)
            else
                value = parse(Float64, value)
            end
        end
        route_params_dict[Symbol(index)] = value
    end

    return route_params_dict
end


"""
    map_route_function_output()

Output from route.action can contain optional HTTP Headers params dict
"""
function map_route_function_output(output::Union{Tuple, OUTPUT_DATA_FORMATS})
    data::OUTPUT_DATA_FORMATS = ""
    headers::Dict{String, String} = Dict()

    if isa(output, Tuple)
        data = output[1]
        headers = output[2]
    else
        data = output
    end

    return headers, data
end


"""
    process_backend_function(;route::Router.Route, route_segments::Array{String, 1}, payload::String)

2 main cases

- JSON POST request with payload
- GET request

If error during process, render 500 response

Render 400 if badly supplied payload data
"""
function process_backend_function(;route::Router.Route, route_segments::Array{String, 1}, payload::String) :: Dict{Symbol, Union{Dict, Int64, String}}
    data::OUTPUT_DATA_FORMATS = ""
    headers::Dict{String, String} = Dict()
    output::Union{Tuple, OUTPUT_DATA_FORMATS} = ""
    received_data::Union{DataFrames.DataFrame, Union{Array{Any,1}, Dict}} = Dict()
    rendered_dict::Dict{Symbol, Union{Dict, Int64, String}} = Dict()
    route_params_dict::Dict{Symbol, ROUTE_PARAMS_FORMATS} = Dict()

    if route.endpoint==Router.JSON && length(payload)>0
        can_proceed::Bool = false
        try
            json_decoded_data::Union{Array{Any,1}, Dict} = JSON.parse(payload)
            if isa(json_decoded_data, Array{Any,1})
                received_data = PayloadUtils.convert_array_to_dataframe(json_decoded_data)
            else
                received_data = json_decoded_data
            end
            can_proceed = true
        catch e
            rendered_dict = render_400(;endpoint=route.endpoint)
        end
        if can_proceed
            try
                if route.has_regex
                    route_params_dict = build_route_params_dict(;request_route_segments=route_segments, route_path=route.path)
                    output = route.action(route_params_dict, received_data)
                else
                    output = route.action(received_data)
                end
                headers, data = map_route_function_output(output)
                rendered_dict = render_200(;headers=headers, endpoint=route.endpoint, data=data, html_file=route.html_file)
            catch e
                rendered_dict = render_500(;endpoint=route.endpoint, data=e, html_file=route.html_file, request_path=route.path)
            end
        end
    elseif route.endpoint==Router.JSON || route.endpoint==Router.HTML
        try
            if route.has_regex
                route_params_dict = build_route_params_dict(;request_route_segments=route_segments, route_path=route.path)
                output = route.action(route_params_dict)
            else
                output = route.action()
            end
            headers, data = map_route_function_output(output)
            rendered_dict = render_200(;headers=headers, endpoint=route.endpoint, data=data, html_file=route.html_file)
        catch e
            rendered_dict = render_500(;endpoint=route.endpoint, data=e, html_file=route.html_file, request_path=route.path)
        end
    else
        try
            output = route.action(route.path)
            headers, data = map_route_function_output(output)
            rendered_dict = render_200(;headers=headers, endpoint=route.endpoint, data=data, html_file=route.html_file)
        catch e
            rendered_dict = render_500(;endpoint=route.endpoint, data=e, html_file=route.html_file, request_path=route.path)
        end
    end

    return rendered_dict
end


"""
    render_200(;headers::Dict{String, String}, endpoint::String, data::OUTPUT_DATA_FORMATS, html_file::String)

Render HTTP 200 response
"""
function render_200(;headers::Dict{String, String}, endpoint::String, data::OUTPUT_DATA_FORMATS, html_file::String) :: Dict{Symbol, Union{Dict, Int64, String}}
    return CoreRenderer.render(;headers=headers, status_code=200, endpoint=endpoint, data=data, html_file=html_file)
end


"""
    render_400(;endpoint::String)

Render HTTP 400 response

No HTML output file required here, as limited to JSON request
"""
function render_400(;endpoint::String) :: Dict{Symbol, Union{Dict, Int64, String}}
    return CoreRenderer.render(;status_code=400, endpoint=endpoint, data="Bad Request", html_file="")
end


"""
    render_404(;endpoint::String)

Render HTTP 404 response
"""
function render_404(;endpoint::String) :: Dict{Symbol, Union{Dict, Int64, String}}
    return CoreRenderer.render(;status_code=404, endpoint=endpoint, data="Not Found", html_file=Configuration.Settings[:html_base_filename]*".html")
end


"""
    render_405(;endpoint::String, html_file::String)

Render HTTP 405 response
"""
function render_405(;endpoint::String, html_file::String) :: Dict{Symbol, Union{Dict, Int64, String}}
    return CoreRenderer.render(;status_code=405, endpoint=endpoint, data="Method Not Allowed", html_file=html_file)
end


"""
    render_500(;endpoint::String, data::String, html_file::String, request_path::String)

Render HTTP 500 response

Only if NOT Prod: output error details to page
"""
function render_500(;endpoint::String, data::String, html_file::String, request_path::String) :: Dict{Symbol, Union{Dict, Int64, String}}
    Logger.log("500 Internal Server Error when rendering url: $request_path")

    ## Only output error details if NOT Prod ##
    if Configuration.is_prod()
        data = "Internal Server Error"
    else
        data = "Internal Server Error: " * data
    end

    return CoreRenderer.render(;status_code=500, endpoint=endpoint, data=data, html_file=html_file)
end


"""
    render(;request_headers::Array, request_method::String, request_path::String, request_payload::String)

Main entry point of HTTP Rendering

- Invalid method will render 405 response
- If error during process, render 500 response

Check Headers if was JSON request, to return 404 as JSON output
"""
function render(;request_headers::Array, request_method::String, request_path::String, request_payload::String)
    rendered_dict::Dict{Symbol, Union{Dict, Int64, String}} = Dict()
    request_route_segments::Array{String, 1} = []

    route::Union{Router.Route, Nothing} = Router.get_route(request_path)

    if isa(route, Router.Route)
        try
            ## Check if method allowed ##
            if route.method==request_method
                if route.has_regex
                    request_route_segments = URIUtils.get_path_param_segments(;request_path=request_path, route_path=route.path)
                end
                rendered_dict = process_backend_function(;route=route, route_segments=request_route_segments, payload=request_payload)
            else
                rendered_dict = render_405(;endpoint=route.endpoint, html_file=route.html_file)
            end
        catch e
            rendered_dict = render_500(;endpoint=route.endpoint, data=string(e), html_file=route.html_file, request_path=route.path)
        end
    else
        ## Check Headers if was JSON request, to return 404 in JSON format ##
        content_type::String = ""
        endpoint::String = Router.HTML
        try
            for pair in request_headers
                if pair.first=="Content-Type"
                    content_type = pair.second
                end
            end
            if content_type=="application/json"
                endpoint = Router.JSON
            end
        catch e
            nothing
        end

        rendered_dict = render_404(;endpoint=endpoint)
    end

    ## Automaticlly set `Content-Type` Header ##
    rendered_dict[:headers]["Content-Type"] = rendered_dict[:content_type]

    return respond(;
        headers=rendered_dict[:headers], status_code=rendered_dict[:status_code], body=rendered_dict[:body]
    )
end

end
