# Common Parameters

## 2 - Optional HTTP Header

One can set additional HTTP headers for both HTML and JSON API endpoints.

To do so simply add the desired headers as second output parameter of the function linked to route in question.
Format must be `Dict{String, String}`.

```julia
import DataFrames

using Dance.Router


function post_df(df::DataFrames.DataFrame) :: Tuple{DataFrames.DataFrame, Dict}
    return df, Dict("foo" => "bar")
end

route("/dataframe", post_df)
```

This will set `foo` HTTP header to value of `bar`.
