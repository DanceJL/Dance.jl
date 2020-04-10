module URIUtils

const ROUTE_REGEX_BASIC_STRUCTURE = r"([^\/(?<]+)+"
const ROUTE_REGEX_PARAM_ONLY = r"(<[^\/(?)]+)+"


"""
    get_path_segments(path::String)

Array from breaking path at slashes
"""
function get_path_segments(path::String) :: Array{String, 1}
    path_segments::Array{String, 1} = split(path, "/")
    return filter!(e->e≠"", path_segments)
end


"""
    get_path_param_segments(;request_path::String, route_path::String)

Parse route.path and match param sections with corresponding request path segments
"""
function get_path_param_segments(;request_path::String, route_path::String) :: Array{String, 1}
    request_path_param_segments::Array{String, 1} = []

    request_path_segments::Array{String, 1} = get_path_segments(request_path)

    for (idx, item) in enumerate(collect(eachmatch(ROUTE_REGEX_BASIC_STRUCTURE, route_path)))
        if endswith(item.match, ")")
            push!(request_path_param_segments, request_path_segments[idx])
        end
    end

    return request_path_param_segments
end

end
