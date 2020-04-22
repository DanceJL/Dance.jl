import DataFrames

using Dance.Router


function get_df() :: DataFrames.DataFrame
    return DataFrames.DataFrame(A = 1:4, B = ["M", "F", "F", "M"])
end


function get_dict() :: Dict{Symbol, Int64}
    return Dict(:a => 123)
end


function post_df(df::DataFrames.DataFrame) :: Tuple{DataFrames.DataFrame, Dict{String, String}}
    return df, Dict("foo" => "bar")
end


function post_dict(params_dict::Dict{Symbol, Union{Float64, Int64, String}}, dict::Dict) :: Dict{String, Int64}
    for key in keys(dict)
        dict[key] = params_dict[:value]
    end
    return dict
end


route("/dict", get_dict; method=GET)
route("/dataframe", get_df; method=GET)
route(r"/post/dict/(?<value>\d{2})", post_dict)
route("/post/dataframe", post_df)
