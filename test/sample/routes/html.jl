import DataFrames

using Dance.Router


function df() :: DataFrames.DataFrame
    return DataFrames.DataFrame(A = 1:4, B = ["M", "F", "F", "M"])
end


function dict_1(params_dict::Dict{Symbol, Union{Float64, Int64, String}}) :: Dict{Symbol, Float64}
    return Dict(:a => params_dict[:value])
end


function dict_2(params_dict::Dict{Symbol, Union{Float64, Int64, String}}) :: Dict{Symbol, Int64}
    return Dict(Symbol(params_dict[:key]) => params_dict[:value])
end


function hello() :: String
    return "Hello World"
end


route("/", hello; method=GET, endpoint=HTML)
route_group(route_prefix="/dict", method=GET, endpoint=HTML, [
    (path=r"/(?<value>\d.)", action=dict_1)
    (path=r"/(?<key>\w+)/(?<value>\d{3})", action=dict_2)
])
route("/dataframe", df; method=GET, endpoint=HTML)
