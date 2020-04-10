import DataFrames

using Dance.Router


function df() :: DataFrames.DataFrame
    return DataFrames.DataFrame(A = 1:4, B = ["M", "F", "F", "M"])
end


function dict_1(params_dict::Dict{Symbol, Any}) :: Dict
    return Dict(:a => params_dict[:value])
end


function dict_2(params_dict::Dict{Symbol, Any}) :: Dict
    return Dict(Symbol(params_dict[:key]) => params_dict[:value])
end


function hello() :: String
    return "Hello World"
end


route("/", hello; method=GET, endpoint=HTML)
route(r"/dict/(?<value>\d.)", dict_1; method=GET, endpoint=HTML)
route(r"/dict/(?<key>\w+)/(?<value>\d{3})", dict_2; method=GET, endpoint=HTML)
route("/dataframe", df; method=GET, endpoint=HTML)
