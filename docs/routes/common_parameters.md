# Common Parameters

## 1 - Input Parameters

Dance being a web framework, routes can of course contain parameters.

Format must follow PCRE regex containing parameter names.

Example routes can be:

```julia
function dict_1(params_dict::Dict{Symbol, Int64}, headers::Dict{String, String}) :: Dict{Symbol, Int64}
    return Dict(:a => params_dict[:value])
end


function dict_2(params_dict::Dict{Symbol, Union{Float64, String}}, headers::Dict{String, String}) :: Dict{Symbol, Float64}
    return Dict(Symbol(params_dict[:key]) => params_dict[:value])
end


function post_dict(params_dict::Dict{Symbol, Int64}, dict::Dict, headers::Dict{String, String}) :: Dict{Symbol, Int64}
    for key in keys(dict)
        dict[key] = params_dict[:value]
    end
    return dict
end



route(r"/dict/(?<value>\d.)", dict_1; method=GET, endpoint=EP_HTML)
route(r"/dict/(?<key>\w+)/(?<value>\d*\.\d*)", dict_2; method=GET, endpoint=EP_HTML)
route(r"/post/dict/(?<value>\d{3})", post_2)
```

As you can see are supported:
- decimals
- integers
- strings

**Note that**:

- Function routes params dict is **first input parameter, in case of Regex type route.**
If non-Regex, this parameter is not passed.
- If HTTP POST body is supplied (for HTTP GET this parameter is not passed), this will be next parameter.
Format is subset of **Dict{Symbol, Union{Float64, Int64, String}}** or **DataFrames.DataFrame**.
That is depending on whether **JSON dict or array** was sent via request.
- Format of received HTTP Headers is **Dict{String, String}**.
**This last parameter must always be supplied to function**.

## 2 - Optional HTTP Header

One can set additional HTTP headers for both HTML and JSON API endpoints.

To do so simply add the desired headers as second output parameter of the function linked to route in question.
**Format must be `Dict{String, String}`**.

```julia
import DataFrames

using Dance.Router


function post_df(df::DataFrames.DataFrame, headers::Dict{String, String}) :: Tuple{DataFrames.DataFrame, Dict{String, String}}
    return df, Dict("foo" => "bar")
end

route("/dataframe", post_df)
```

This will set `foo` HTTP header to value of `bar`.
