using Dance.Router


function dict(params_dict::Dict{Symbol, Union{Float64, Int64, String}}, headers::Dict{String, String}) :: Dict{String, Int64}
    return Dict(params_dict[:key] => params_dict[:value])
end


route_group(route_prefix="/dict", method=GET, endpoint=EP_HTML, [
    (path=r"/(?<key>([^\/(?)]+))/(?<value>\d{3})", action=dict)
])
