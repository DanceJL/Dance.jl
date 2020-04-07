import DataFrames

using Dance.Router


function hello() :: String
    return "Hello World"
end


function hello_df() :: DataFrames.DataFrame
    return DataFrames.DataFrame(A = 1:4, B = ["M", "F", "F", "M"])
end


function hello_dict() :: Dict
    return Dict(:a => 123)
end


route("/", hello; method=GET, endpoint=HTML)
route("/dict", hello_dict; method=GET, endpoint=HTML)
route("/dataframe", hello_df; method=GET, endpoint=HTML)
