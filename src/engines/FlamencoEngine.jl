import Flamenco


"""
    close_server()

Stop Flamenco server
"""
function close_server()
    Flamenco.close_server()
end


"""
    respond(; headers::Dict{String, String}, status_code::Int16, body::String) :: String

Return response for specified parameters
"""
respond(; headers::Dict{String, String}, status_code::Int16, body::String) = Flamenco.write_response(status_code, headers; body=body)


"""
    start_server(server_host::String, server_port::Int64) :: Nothing

Start Flamenco server and listen for incoming requests and return HTML or JSON body
"""
function start_server(server_host::String, server_port::Int64) :: Nothing
    Flamenco.start_server(server_host, server_port) do request::Flamenco.Server.Request
        render(; request_headers=request.headers, request_method=request.method, request_path=request.target, request_payload=request.body)
    end
end
