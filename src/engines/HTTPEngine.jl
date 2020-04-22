import HTTP


"""
    respond(;headers::Dict, status_code::Int64, content_type::String, body::String)

Return HTTP.Response for specified parameters
"""
function respond(;headers::Dict, status_code::Int64, content_type::String, body::String) :: HTTP.Response
    headers["content_type"] = content_type
    return HTTP.Response(status_code, headers; body=body)
end


"""
    start_server(server_host::String, server_port::Int64)

Start HTTP.jl server and listen for incoming requests and return HTML or JSON body
"""
function start_server(server_host::String, server_port::Int64) :: Nothing
    HTTP.Handlers.serve(server_host, server_port) do request::HTTP.Request
        render(;request_headers=request.headers, request_method=request.method, request_path=request.target, request_payload=String(take!(IOBuffer(request.body))))
    end
end
