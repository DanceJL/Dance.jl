# Common Parameters

## 1 - Regex Parameters

Dance being a web framework, routes can of course contain parameters.

Format must follow  PCRE regex containing parameter names.

Example routes can be:

```julia
function dict_1(params_dict::Dict{Symbol, Union{Float64, Int64, String}}) :: Dict{Symbol, Float64}
    return Dict(:a => params_dict[:value])
end


function dict_2(params_dict::Dict{Symbol, Union{Float64, Int64, String}}) :: Dict{Symbol, Int64}
    return Dict(Symbol(params_dict[:key]) => params_dict[:value])
end


function post_dict(params_dict::Dict{Symbol, Union{Float64, Int64, String}}, dict::Dict) :: Dict{Symbol, Int64}
    for key in keys(dict)
        dict[key] = params_dict[:value]
    end
    return dict
end



route(r"/dict/(?<value>\d.)", dict_1; method=GET, endpoint=HTML)
route(r"/dict/(?<key>\w+)/(?<value>\d{3})", dict_2; method=GET, endpoint=HTML)
route(r"/post/dict/(?<value>\d{3})", post_2)
```

As you can see are supported:
- decimals
- integers
- strings

**Note that**:

- Function routes params dict is **first input parameter, in case of JSON post route type**.
- Format of the route params dict is **Dict{Symbol, Union{Float64, Int64, String}}**.

## 2 - Optional HTTP Header

One can set additional HTTP headers for both HTML and JSON API endpoints.

To do so simply add the desired headers as second output parameter of the function linked to route in question.
Format must be `Dict{String, String}`.

```julia
import DataFrames

using Dance.Router


function post_df(df::DataFrames.DataFrame) :: Tuple{DataFrames.DataFrame, Dict{String, String}}
    return df, Dict("foo" => "bar")
end

route("/dataframe", post_df)
```

This will set `foo` HTTP header to value of `bar`.
